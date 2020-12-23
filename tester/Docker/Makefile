NS ?= tda283
IMAGE ?= tester
VERSION ?= latest
CONTAINER_NAME ?= tester
CONTAINER_INSTANCE ?= default

.PHONY: build shell dist

default: build

build: Dockerfile
	docker build -m 4096M -t $(NS)/$(IMAGE):$(VERSION) -f $< .

shell:
	docker run -m 4096M --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) \
	  -i -t $(NS)/$(IMAGE):$(VERSION) /bin/bash

dist: tda283-docker.tar.gz

tda283-docker.tar.gz: Makefile Dockerfile* runtest.sh README.md
	tar cvzf $@ $^

