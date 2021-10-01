FROM ubuntu:20.04

LABEL maintainer="Karan Sharma <https://github.com/mr-karan>"
EXPOSE 4646 4647 4648 4648/udp

ARG NOMAD_VERSION=1.1.5

# Create directories for data/config.
RUN mkdir -p /opt/nomad/data && \
    mkdir -p /etc/nomad.d

# Packages required for nomad.
RUN apt-get update && apt-get install -y \
  unzip \
  curl \
  iproute2 \
  vim \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Install Nomad
WORKDIR /tmp
RUN curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip \
    && unzip nomad.zip \
    && mv nomad /usr/bin/nomad

# Install CNI (https://www.nomadproject.io/docs/integrations/consul-connect)
RUN curl -L -o cni-plugins.tgz \ 
    "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz && \
    mkdir -p /opt/cni/bin && \
    tar -C /opt/cni/bin -xzf cni-plugins.tgz

# Copy a default config.
COPY configs/nomad.hcl /etc/nomad.d/nomad.hcl

CMD ["/usr/bin/nomad", "agent", "-config", "/etc/nomad.d"]
