NS ?= tda283
IMAGE ?= tester
VERSION ?= latest
CONTAINER_NAME ?= tester
CONTAINER_INSTANCE ?= default

.PHONY: shell build

build: Dockerfile
	docker build -t $(NS)/$(IMAGE):$(VERSION) -f Dockerfile .

shell:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) \
	  -i -t $(NS)/$(IMAGE):$(VERSION) /bin/bash

dist: tda283-docker.tar.gz

tda283-docker.tar.gz: Makefile Dockerfile runtest.sh README.md
	tar cvzf $@ $^

default: build
