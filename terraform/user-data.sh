#!/bin/bash
# Update system and install dependencies
sudo apt update
sudo apt upgrade -y

sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

sudo usermod -aG docker ubuntu
newgrp docker # Apply the group change immediately

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

sudo apt install conntrack -y

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

minikube start --driver=docker --container-runtime=docker --ports=31337:31337

echo "$USER" > test.txt
pwd >> test.txt

echo "$USER"
pwd

# Set permissions
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube /home/ubuntu/.minikube

# Create Strapi Deployment YAML
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
        # OLD: image: strapi/strapi:4-full
        # NEW: Use your own Docker image
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

# Deploy Strapi to Kubernetes
sudo -u ubuntu kubectl apply -f /home/ubuntu/strapi.yaml
