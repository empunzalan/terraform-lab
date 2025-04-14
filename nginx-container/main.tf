# Tell Terraform what providers are needed
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"   # Docker provider from the registry
      version = "~> 3.0"               # Use any 3.x version
    }
  }
}

# Configure the Docker provider to talk to Colima's socket
provider "docker" {
  host = "unix:///Users/edgar/.colima/default/docker.sock"  # Colima's Docker endpoint
}

# Pull the official nginx image from Docker Hub
resource "docker_image" "nginx" {
  name = "nginx:latest"  # Tag to use when pulling the image
}

# Create a container from the nginx image
resource "docker_container" "nginx" {
  image = docker_image.nginx.name   # Use the image we just pulled
  name  = "terraform-nginx"         # Container name

  ports {
    internal = 80   # Inside container
    external = 8080 # Exposed to host at localhost:8080
  }
}
