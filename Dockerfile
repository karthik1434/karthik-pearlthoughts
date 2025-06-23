# Base image
FROM node:22.15.0-alpine

# Set working directory
WORKDIR /app

# Copy package files first (for caching dependencies)
COPY package.json ./
COPY package-lock.json ./


# Install dependencies
RUN npm install

# Copy the rest of the app
COPY . .


# Build admin panel
RUN npm run build

# Expose default Strapi port
EXPOSE 1337

# Start the Strapi server
CMD ["npm", "start"]
