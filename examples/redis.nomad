job "redis" {
  datacenters = ["dev"]
  type        = "service"

  group "redis" {
    count = 1

    network {
      port "redis" {
        to = 6379
      }
    }

    service {
      name = "redis-server"
      tags = ["cache", "redis"]
      port = "redis"
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6"
        ports = ["redis"]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
