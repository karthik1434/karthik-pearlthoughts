# build-and-push.ps1

# Step 1: Build the local Docker image
docker build -t strapi-app:latest .

# Step 2: Tag the image for Docker Hub
docker tag strapi-app:latest duggana1994/strapi-app:latest

# Step 3: Login to Docker Hub
docker login

# Step 4: Push the image to Docker Hub
docker push duggana1994/strapi-app:latest

