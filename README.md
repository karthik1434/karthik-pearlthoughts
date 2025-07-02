# 🚀 Strapi on Kubernetes (Minikube) - EC2 Auto Provisioning

This project automates the provisioning and deployment of a **Strapi CMS** application on an **AWS EC2 Ubuntu 22.04 instance** using **Minikube (Kubernetes)** and **Docker**.

The setup is done via EC2 **user-data script**, enabling a fully automated infrastructure on launch.

---

## 📌 Features

- Installs Docker, Kubectl, Minikube, and all dependencies
- Sets up Minikube with Docker as the container runtime
- Deploys a custom Strapi Docker image to a Kubernetes cluster
- Exposes the app via NodePort on port `31337`
- Generates logs and test info for verification

---

## 🛠️ Technologies Used

- **Ubuntu 22.04 (EC2)**
- **Docker & Docker Compose Plugin**
- **Minikube (Kubernetes in Docker driver)**
- **Kubectl (CLI for Kubernetes)**
- **Custom Strapi Docker image**
- **Cloud-init (EC2 user-data script)**

---

## 🚧 Prerequisites

- AWS EC2 instance with Ubuntu 22.04
- Instance Type: t2.medium or higher (for Minikube performance)
- A Security Group with the following **inbound rule**:
