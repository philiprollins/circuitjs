# Multi-stage build for CircuitJS1
# Stage 1: Build the application
FROM gradle:8.7-jdk17 AS builder

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Build the application using the existing Gradle tasks
RUN gradle clean compileGwt makeSite --no-daemon --console verbose

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the built site from the makeSite task
COPY --from=builder /app/site /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]