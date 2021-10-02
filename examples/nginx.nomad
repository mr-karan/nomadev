job "nginx" {
  datacenters = ["dev"]
  type        = "service"

  group "nginx" {
    count = 1

    network {
      port "proxy" {
        to = 8000
      }
    }

    service {
      name = "nginx-proxy"
      tags = ["proxy", "nginx"]
      port = "proxy"
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "nginx" {
      driver = "docker"
      template {
        data        = <<EOF
server {
    listen       8000;
    server_name  nomad.local;

    location / {
      add_header Content-Type text/plain;
      return 200 'nomad is cool!';
    }
}
EOF
        change_mode = "restart"
        destination = "local/proxy.conf"
      }
      config {
        image = "nginx:1.21.3"
        ports = ["proxy"]

        mount {
          type     = "bind"
          source   = "local/proxy.conf"
          target   = "/etc/nginx/conf.d/proxy.conf"
          readonly = true
        }
      }

      resources {
        cpu    = 400
        memory = 200
      }
    }
  }
}
