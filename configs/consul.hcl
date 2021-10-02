datacenter     = "dev"
data_dir       = "/opt/consul/data"
server         = true
advertise_addr = "127.0.0.1"
bind_addr      = "127.0.0.1"
ui_config {
  enabled = true
}
bootstrap = true
connect {
  enabled = true
}
telemetry {
  disable_compat_1.9 = true
}