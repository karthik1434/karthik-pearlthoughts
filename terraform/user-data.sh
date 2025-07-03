#!/bin/bash

# Update system and install dependencies
apt update
# apt upgrade -y

apt install -y apt-transport-https ca-certificates curl gnupg lsb-release conntrack

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
> /etc/apt/sources.list.d/docker.list

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

usermod -aG docker ubuntu

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Start minikube with docker driver
sudo -u ubuntu minikube start --driver=docker --container-runtime=docker --ports=31337:31337,32000:32000,32001:32001


# Set ownership for kube and minikube configs
chown -R ubuntu:ubuntu /home/ubuntu/.kube /home/ubuntu/.minikube

# Create strapi deployment YAML
cat <<EOF > /home/ubuntu/strapi.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: strapi
spec:
  replicas: 1
  selector:
    matchLabels:
      app: strapi
  template:
    metadata:
      labels:
        app: strapi
    spec:
      containers:
      - name: strapi
        image: duggana1994/strapi-app:0fe98fd9babc51b638182c939f2571bde76db924
        ports:
        - containerPort: 1337
---
apiVersion: v1
kind: Service
metadata:
  name: strapi-service
spec:
  type: NodePort
  selector:
    app: strapi
  ports:
    - protocol: TCP
      port: 1337
      targetPort: 1337
      nodePort: 31337
EOF

# Apply strapi deployment
sudo -u ubuntu kubectl apply -f /home/ubuntu/strapi.yaml


# Install Helm (still okay as root)
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Add Helm repo and install Prometheus as `ubuntu`
sudo -u ubuntu helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
sudo -u ubuntu helm repo update


# Install Prometheus + Grafana stack
sudo -u ubuntu helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=32000 \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=32001 \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# Wait for Prometheus operator to be ready
echo "Waiting for Prometheus & Grafana pods to be ready..."
sudo -u ubuntu kubectl wait --for=condition=available --timeout=300s deployment/prometheus-kube-prometheus-stack-operator -n monitoring
sudo -u ubuntu kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode