<!-- PROJECT LOGO -->
<br />
<p align="center">
  <h2 align="center">nomadev</h2>
  <p align="center">
    <i>Docker based development workflow with Nomad and Consul</i>
    <br/>
  </p>
</p>

---

**nomadev** is an attempt to simplify setting up a [Nomad](https://www.nomadproject.io/) + [Consul](https://www.consul.io/) agents intended for **local development workflows**.

The setup is based on `docker-compose` and is configured to spawn a single `docker `container for each Nomad and Consul agent. Both agents are configured to run in `server` + `client` mode.

This simplifies the setup for local use. It's possible to add more containers for additional servers/clients if required.

## Getting Started

You will need `docker` and `docker-compose` installed.

### Start Agents

```bash
make docker-build && make docker-up
```

### Accessing via UI

You should be able to access the following endpoints:

- http://localhost:4646/ui/jobs (Nomad UI)
- http://localhost:8500/ui/dev/services (Consul UI)

### Accessing via CLI

(Grab the binaries for [nomad](https://www.nomadproject.io/downloads) and [consul](https://www.consul.io/downloads))
```bash
$ nomad server members
Name         Address       Port  Status  Leader  Protocol  Build  Datacenter  Region
iris.global  192.168.69.4  4648  alive   true    2         1.1.5  dev         global

$ consul members       
Node  Address         Status  Type    Build   Protocol  DC   Segment
iris  127.0.0.1:8301  alive   server  1.10.3  2         dev  <all>
```

## Running Jobs

You can checkout [examples](./examples) directory to explore a few [Job](https://www.nomadproject.io/docs/job-specification) examples.

For example:

### Spawn a Redis Job

```bash
nomad job run examples/redis.nomad
```

### Connecting via Host Network

The sample `redis` job exposes a random port on the host. Since we use `net=host` (Host Network) to run our `docker` containers, the same should be directly accesible from the host machine.

```bash
> nomad alloc status {{uuid}}
...
Allocation Addresses
Label   Dynamic  Address
*redis  yes      192.168.69.4:23509 -> 6379
...

# Verify
❯ docker run --rm --net=host redis:6 redis-cli -h 192.168.69.4 -p 23509 ping
PONG
```

## Considerations

Some important things to note:

### Host Paths and Template

Nomad configures the destination of `artifact`, `template` etc relative to the task working directory. If you're using `template` stanza, Nomad passes the `/allocl/<id>/<task>/local/` path as a `bind` mount option to the Docker daemon. What this means is that unless this exact path is present on your host machine, the task will fail to run.

The only way around is to mount `/opt/nomad/data` (or whatever path you choose inside `[nomad.hcl](configs/nomad.hcl)`)

The data directory path inside container and outside on the host **should be exactly the same**.

This can be verified by `docker inspect` on any container which is spawned by `nomad`.:

```
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/opt/nomad/data/alloc/23d6cc4e-a7bd-d9df-b912-05256ef8a672/nginx/local/proxy.conf",
                "Destination": "/etc/nginx/conf.d/proxy.conf",
                "Mode": "",
                "RW": false,
                "Propagation": "rprivate"
            }
        ]
```

This is the `alloc` directory that Nomad creates where templates are rendered and the same paths are provided to `docker` daemon when the task runs.

Refer [docs](https://www.nomadproject.io/docs/internals/filesystem#templates-artifacts-and-dispatch-payloads) for more details.

### Security

While this setup works fine for local development, it requires high privileges to function properly which include running the container as `root` user with `--privileged=true`.
Additionally, `docker` socket needs to be mounted if you want to use the [`docker` task driver](https://www.nomadproject.io/docs/drivers/docker).

Goes without saying, do not use this in production.
