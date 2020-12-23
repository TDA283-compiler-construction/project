# testing.py

Test-suite for the Javalette compiler project in the Compiler Construction
course at the Department of Computer Science and Engineering, Chalmers
University of Technology and Gothenburg University.

## Requirements

testing.py requires Python 3 and `make`. The test suite should work on
Linux and macOS. If you are using Windows, see e.g.
[Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

## Instructions

The test-suite accepts a compressed tar-ball containing your submission.
The tar-ball should be compressed with gzip, bzip2, or xz. The submission
should be created according to 'SUBMISSION FORMAT' below (see also course
web-page).

Example:
```sh
> python3 testing.py path/to/partA-2.tar.gz --llvm
```

The following command line options are available:

| Option                        | Description                           |
|-------------------------------|---------------------------------------|
| `-h, --help`                  | Show help message.                    |
| `-s`                          | Set compiler prefix (default is `jlc`)|
| `    --llvm`                  | Test the LLVM backend                 |
| `    --x86`                   | Test the 32-bit x86 backend           |
| `    --x64`                   | Test the 64-bit x86 backend           |
| `    --riscv`                 | Test the RISC-V backend               |
| `-x <ext> [ext ...]`          | Test one or more extensions           |
| `    --noclean`               | Do not clean up temporary files       |

As an example, the following tests the x86-32 backend with extensions
`arrays1` and `pointers` on the submission `partC-1.tar.gz`:
```sh
> python3 testing.py partC-1.tar.gz --x86 -x arrays1 pointers
```

If neither of the options `--llvm`, `--x86`, `--x64`, or `--riscv` are present, only
parsing and type checking is tested.

## Extensions

Here is a list of the extensions supported:

| Extension      | Description                                     |
|----------------|-------------------------------------------------|
| arrays1        | Single-dimensional arrays                       |
| arrays2        | Multi-dimensional arrays                        |
| pointers       | Structures and pointers                         |
| objects1       | Objects, first extension                        |
| objects2       | Objects, second extension (method overloading)  |
| adv_structs    | Optional struct tests                           |

## Submission format

### Naming

Your Nth attempt at a submission should be a compressed tar-ball named according
to this pattern:

    part(A|B|C)-N.tar.gz

where (A|B|C) means one of A, B, or C. For example, your first attempt at
assignment B should be named `partB-1.tar.gz`.

### Contents

The submission should contain the following directories and files, at the top
level.

| Item            | Description |
|-----------------|-------------|
| doc/ | All documentation for the submission (see course webpage). |
| lib/ | The runtime.ll and/or runtime.s files required by your compiler backend(s). |
| src/     | All source-code for your submission. |
| Makefile | A makefile that builds your compiler. Running `make` or `make all` should be sufficient to build your project, and `make clean` should remove all build artefacts. |

## Compiler requirements

###   Naming

Your compiler should be named `jlc` (without quotes) for the LLVM backend,
`jlc_x86` for the 32-bit x86 backend, `jlc_x64` for the 64-bit x86 backend,
 and `jlc_riscv` for the RISC-V backend.

### Input/output format

* Your compiler should read its input from standard input (stdin), and write
  its output (LLVM, or assembly) to standard out (stdout).
* If your program succeeds (there are no errors), then it should print `OK` to
   standard error (stderr), and terminate with exit code 0.
* If your program does not succeed (there are some errors), it should print a
  line containing the word `ERROR` to standard error (stderr), and terminate
  with a non-zero exit code.

