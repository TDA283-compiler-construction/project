TDA283 COMPILER CONSTRUCTION TESTER
===================================

For testing student submissions within a container.

INSTRUCTIONS
------------

1. Get Docker from e.g. https://www.docker.com/products/docker-desktop
2. Run make to build Docker image (this will take a while).
3. Run the test script with `bash runtest.sh`:

```
USAGE: runtest.sh <submission> [options]
OPTIONS:
  -h            this message
  -l            test LLVM backend
  -y            test x86-32 backend
  -Y            test x86-64 backend
  -x <ext>      test extension <ext>
                (pass many of these to test multiple extensions)
  -n            keep container and temporary files
  -i <image>    custom docker image
                (default: tda283/tester:latest)
```

Example:
```
bash runtest.sh partC-1.tar.gz -l -Y -x arrays1 -x pointers
```
will test the submission `partC-1.tar.gz` with the LLVM backend, the x64 backend,
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
