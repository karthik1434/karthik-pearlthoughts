# 🚀 Strapi Docker Deployment via EC2 and Docker Hub

This project builds a custom Strapi Docker image, pushes it to Docker Hub, and deploys it on an AWS EC2 instance using a user data script.

---

## 📦 Docker Image Build & Push (PowerShell Script)

Use the following PowerShell script to build and push the Docker image to your Docker Hub account.

### 🔧 `build-and-push.ps1`

```powershell
# Step 1: Build the local Docker image
docker build -t strapi-app:latest .

# Step 2: Tag the image for Docker Hub
docker tag strapi-app:latest duggana1994/strapi-app:latest

# Step 3: Login to Docker Hub
docker login

# Step 4: Push the image to Docker Hub
docker push duggana1994/strapi-app:latest

Run it with:

.\build-and-push.ps1

☁️ EC2 Deployment (User Data Script)
Use this bash script in your EC2 instance's user_data field (in Terraform or AWS Console) to pull and run the Dockerized Strapi app.

🔧 EC2 User Data Script
#!/bin/bash
apt update -y
apt-get install -y docker.io
systemctl start docker
systemctl enable docker


docker pull duggana1994/strapi-app:latest
docker run -d -p 1337:1337 --name strapi-app duggana1994/strapi-app:latest
🌐 Access Strapi
Once the EC2 instance is running and the container is up, you can access Strapi at:

http://<EC2_PUBLIC_IP>:1337
Make sure the EC2 security group allows inbound traffic on port 1337.