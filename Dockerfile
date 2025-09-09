# Multi-stage Dockerfile for CircuitJS1
# Stage 1: Build the GWT application
FROM openjdk:8-jdk-alpine AS builder

# Install required packages
RUN apk add --no-cache wget unzip

# Set working directory
WORKDIR /app

# Copy source code
COPY src/ /app/src/
COPY .classpath /app/
COPY .project /app/

# Download and install GWT SDK 2.7.0
RUN wget -q https://storage.googleapis.com/gwt-releases/gwt-2.7.0.zip && \
    unzip gwt-2.7.0.zip && \
    rm gwt-2.7.0.zip

# Set GWT home
ENV GWT_HOME=/app/gwt-2.7.0
ENV PATH=$PATH:$GWT_HOME

# Create war directory structure
RUN mkdir -p war/WEB-INF/classes

# Copy existing war files (if any) - these contain static assets
COPY war/ /app/war/

# Build the GWT application
RUN java -cp "$GWT_HOME/gwt-dev.jar:$GWT_HOME/gwt-user.jar:src" \
    com.google.gwt.dev.Compiler \
    -war war \
    -logLevel INFO \
    com.lushprojects.circuitjs1.circuitjs1

# Stage 2: Serve the application with Nginx
FROM nginx:alpine

# Copy the built application from the builder stage
COPY --from=builder /app/war/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]