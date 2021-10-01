NOMAD_VERSION := 1.1.5

.PHONY: build
build:
	docker-compose build

.PHONY: up
up:
	docker-compose up

.PHONY: clean
clean:
	docker-compose down ; sudo rm -rf /opt/nomad/data ; sudo rm -rf /opt/consul/data

.PHONY: gc
gc:
	curl -XPUT http://127.0.0.1:4646/v1/system/gc

.PHONY: fresh
fresh: clean build up
