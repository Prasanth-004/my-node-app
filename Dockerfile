# Production multi-stage hardened Dockerfile for Node.js Microservice
FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# Copy package manifests first to leverage Docker layer caching
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy application source code
COPY . .

# Install curl for container health check (used by ECS health check)
RUN apk add --no-cache curl

# Security best practice: Create non-root user and group to run container safely
RUN addgroup -S nodejs && \
    adduser -S nodejs -G nodejs && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose HTTP port
EXPOSE 3000

# Set default runtime environment variables
ENV NODE_ENV=production
ENV APP_VERSION=1.0.0

# Start command
CMD ["node", "app.js"]
