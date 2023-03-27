NS ?= tda283
IMAGE ?= tester
VERSION ?= latest
CONTAINER_NAME ?= tester
CONTAINER_INSTANCE ?= default

.PHONY: build shell dist rust ocaml riscv zig

default: build

build: Dockerfile
	docker build -m 8192M -t $(NS)/$(IMAGE):$(VERSION) -f $< .

rust: Dockerfile-rust
	docker build -m 8192M -t $(NS)/$(IMAGE):rust -f $< .

ocaml: Dockerfile-ocaml
	docker build -m 8192M -t $(NS)/$(IMAGE):ocaml -f $< .

zig: Dockerfile-zig
	docker build -m 8192M -t $(NS)/$(IMAGE):zig -f $< .

python: Dockerfile-python
	docker build -m 8192M -t $(NS)/$(IMAGE):python -f $< .

agda: Dockerfile-agda
	docker build -m 8192M -t $(NS)/$(IMAGE):agda -f $< .

kotlin: Dockerfile-kotlin
	docker build -m 8192M -t $(NS)/$(IMAGE):kotlin -f $< .

racket: Dockerfile-racket
	docker build -m 8192M -t $(NS)/$(IMAGE):racket -f $< .

shell:
	docker run -m 4096M --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) \
	  -i -t $(NS)/$(IMAGE):$(VERSION) /bin/bash

dist: tda283-docker.tar.gz

tda283-docker.tar.gz: Makefile Dockerfile* runtest.sh README.md
	tar cvzf $@ $^
