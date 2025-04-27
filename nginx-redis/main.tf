# Specify the required provider and its version
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"  # Docker provider from the Terraform Registry
      version = "~> 3.0"              # Allow any compatible 3.x version
    }
  }
}

# Configure the Docker provider to use Colima's socket
provider "docker" {
  host = "unix:///Users/edgar/.colima/default/docker.sock"
}

# Define a Docker network for both containers to communicate on
resource "docker_network" "app_network" {
  name = "nginx_redis_net"  # Custom network name
}

# Pull the nginx image from Docker Hub
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# Pull the redis image from Docker Hub
resource "docker_image" "redis" {
  name = "redis:latest"
}

# Deploy the NGINX container
resource "docker_container" "nginx" {
  name  = "web-nginx"  # Name of the container
  image = docker_image.nginx.name

  ports {
    internal = 80     # Port inside the container
    external = 8081   # Port exposed on the host (http://localhost:8081)
  }

  volumes {
    host_path      = abspath("${path.module}/html")
    container_path = "/usr/share/nginx/html"
  }

  # Attach to the custom Docker network
  networks_advanced {
    name = docker_network.app_network.name
  }
}

# Deploy the Redis container
resource "docker_container" "redis" {
  name  = "db-redis"
  image = docker_image.redis.name

  ports {
    internal = 6379   # Redis default port
    external = 6379   # Exposed to host (can use redis-cli locally)
  }

  # Attach to the same network as NGINX
  networks_advanced {
    name = docker_network.app_network.name
  }
}

# Output Redis container IP for debugging or future use
#output "redis_ip" {
#  value = docker_container.redis.ip_address
#}

# Build Python App Docker Image
resource "docker_image" "python_app" {
  name = "python-redis-app"
  
  build {
    context = "${path.module}/python-app"
  }
}

# Create Python App Container
resource "docker_container" "python_app" {
  name  = "python-redis-app-container"
  image = docker_image.python_app.name

  networks_advanced {
    name = docker_network.app_network.name
  }
}

# Build Node.js App Docker Image
resource "docker_image" "nodejs_app" {
  name = "nodejs-redis-app"
  
  build {
    context = "${path.module}/nodejs-app"
  }
}

# Create Node.js App Container
resource "docker_container" "nodejs_app" {
  name  = "nodejs-redis-app-container"
  image = docker_image.nodejs_app.name

  networks_advanced {
    name = docker_network.app_network.name
  }
}
