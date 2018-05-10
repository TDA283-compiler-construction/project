# TDA283: Compiler Construction test suite

Test-suite for the course in Compiler Construction at the CSE dept.,
Chalmers University of Technology.
May, 2018.

*Please note that this test-suite is a work in progress. Report any bugs you
find.*

## Requirements

The test-suite requires Python version 3 to run. We assume that you are using a
UNIX-like operating system (e.g. macOS, Linux, BSD) and have access to the
following tools:

  * A reasonably recent version of the [LLVM toolchain](https://llvm.org) for
    the LLVM backend. The test-suite assumes that `llvm-as`, `llvm-link` and
    `llc` are on the path.
  * A reasonably recent version of [nasm](https://www.nasm.us) for the native
    x86 backends.

## Instructions

There are two ways to run the test-suite on your submission. The first is by
pointing the test program to the folder where your compiler executable exists:

    python3 tester.py [options] path/to/my/submission

Note that this does *not* build the test-suite.

The second way is by pointing the test program to an archive containing your
prepared submission:

    python3 tester.py [options] path/to/my-submission.tar.gz

This unpacks the archive and builds the submission prior to running the test.
The package should be created according to the instructions under "submission
format" below.

### Options

The test-suite accepts the following options:

| Option                              | Explanation                        |
| ----------------------------------- | ---------------------------------- |
| `-b (LLVM \| x86 \| x86_64)` | Test your LLVM/x86/x86_64 backend. |
| `-x <extension> [, extensions ...]` | Test one or more extensions.       |

As an example, the following tests the LLVM backend with extensions 'arrays1'
and 'pointers' on the submission `partC-1.tar.gz`:

    python3 tester.py -b LLVM -x arrays1 pointers partC-1.tar.gz

### Supported extensions

The test-suite will look for extensions in the directory `testsuite/extensions`.
These are the available extensions:

| Extension   | Explanation                                 |
| ----------- | ------------------------------------------- |
| arrays1     | Single-dimensional arrays                   |
| arrays2     | Multi-dimensional arrays                    |
| pointers    | Structs and pointers                        |
| objects1    | Objects, first extension                    |
| objects2    | Objects, second extension (method overload) |
| adv_structs | Additional struct tests                     |

## Submission format

We prefer if you name your submission according to the following pattern,
where `N` denotes the `N`th attempt at the submission.

    part(A|B|C)-N.tar.gz

For example, your first submission of assignment B should be named
`partB-1.tar.gz` according to this scheme. We also accept tar-balls compressed
with bzip, xz, as well as zip- and rar archives, and uncompressed tar-balls.

Your submission archive should adhere to the following structure:

| Item       | Explanation   |
| ---------- | ------------- |
|   doc/     |  Containing all documentation for the submission. (Not vital for the test-suite, but for your grade). |
|   lib/     |  Containing all runtime.ll or runtime.s files required by your compiler backend. |
|   src/     |  Containing the source code for your submission. |
|   Makefile |  A make file which builds your project. (Running `make` or `make all` should be sufficient to build your project). |

A common mistake seems to be to place these folders under some subdirectory
(often conspicuously named 'root'). The test-suite will not run properly if 
you do this.

## Compiler requirements

* Your compiler executable should be named `jlc`  for the LLVM backend,
  `jlc_x86` for the native 32bit x86 backend, and `jlc_x86_64` for the 64-bit
  x86 backend.
* Calling `jlc my_file.jl` to compile the input file `my_file.jl` should
  resulti in the following files appearing *in the same directory as the
  input file* `my_file.jl`:
  + `my_file.ll` containing LLVM source code (LLVM backend)
  + `my_file.s` containing assembly code (native x86 backends)
  Note that for x86 backends the test-suite expects NASM syntax.

- For correct programs your compiler should print `OK` to standard error and
  terminate with exit code 0.
- For incorrect programs, your compiler should print `ERROR` to standard error,
  and print an informative error message on standard output. Finally, it should
  terminate with a non-zero exit code.

