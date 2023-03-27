TDA283 COMPILER CONSTRUCTION TESTER
===================================

For testing student submissions within a container. Requires [Docker](https://www.docker.com/products/docker-desktop).

Build from source (preferred)
-----------------------------

1. Get Docker (see above).
2. Run `make` to build the base Docker image (this will take a while). (Optionally, build the other images; e.g., `make riscv`, ...)
3. Run the test script with `./runtest.sh` (see below).

Using `docker pull`
-------------------

1. Get Docker (see above).
2. Run `docker pull tda283/tester:latest` to get the testing image with the base setup (Haskell and Java). (See [here](https://hub.docker.com/repository/docker/tda283/tester/tags) for some other options.)
3. Run the test script with `./runtest.sh` (see below).

Usage: `runtest.sh`
-------------------

```
USAGE: runtest.sh [options] [--] <submission>
OPTIONS:
  -h            this message
  -l            test LLVM backend
  -y            test x86-32 backend
  -Y            test x86-64 backend
  -v            test risc-v backend
  -x <ext>      test extension <ext>
                (pass many of these to test multiple extensions)
  -n            keep container and temporary files
  -i <image>    custom docker image
                (default: tda283/tester:latest)
```

Example:
```
bash runtest.sh -l -Y -x arrays1 -x pointers -- path/to/submission
```
will test the submission located in `path/to/submission` with the LLVM backend, the x64 backend,
and the extensions `arrays1` and `pointers`.

Optionally, add `-n` to keep the container alive after testing is completed.
This will result in a message in this style, describing how to log into
the container to inspect the built submission:
```
Container ID: 1ea00c6e7a467a1d052222ec4fbe94c82ff6904e74db3082965e31c09992c420
Container name: optimistic_wright
Attach with: docker exec -ti optimistic_wright /bin/bash
```

This means you should type (on the command line):
```
> docker exec -ti optimistic_wright /bin/bash
```

You can leave the container by calling `exit` or `^D`. Finally, kill and remove
the container when you are finished:
```
> docker kill 1ea00c6e7a467a1d
> docker rm 1ea00c6e7a467a1d
```
