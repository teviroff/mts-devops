terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "net" {
  name = "net"
  driver = "bridge"
}

resource "docker_volume" "data" {
  name = "volume"
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.name
  name = "nginx"

  networks_advanced {
    name = docker_network.net.name
  }

  volumes {
    host_path = abspath("${path.module}/html")
    container_path = "/usr/share/nginx/html"
    read_only = true
  }

  ports {
    internal = 80
    external = 18080
    ip = "0.0.0.0"
  }

  restart = "unless-stopped"
}
