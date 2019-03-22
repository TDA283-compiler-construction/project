Testing the project
===================

Needless to say, you should test your project extensively. We provide a
[test suite](/testsuite) of programs and will run your compiler on
these. You can download the test suite from the course web site and run it
locally or on a Chalmers machine (e.g., `remote11` or a Linux lab machine). The
test suite contains both correct programs (in subdirectory `testsuite/good`) and
illegal programs (in subdirectory `testsuite/bad`). For the good programs the
correct output is provided in files with suffix `.output`. The bad programs
contain examples of both lexical, syntactical and type errors.

Already after having produced the parser you should therefore write a main
program and try to parse all the test programs. The same holds for the type
checker and so on. When you only have the parser, you will of course pass some
bad programs; those that are syntactically correct but have type errors.

Summarizing, your compiler must:

* accept and be able to compile all of the files `testsuite/good/*.jl`. For
  these files, the compiler must print a line containing only `OK` to  standard
  error, optionally followed by arbitrary output, such as a syntax tree or other
  messages. The compiler must then exit with  the exit code 0.
* reject all of the files in `testsuite/bad/*.jl`. For these files, the compiler
  must print  `ERROR` as the first line to standard error and then give an
  informative error message. The compiler must then exit with an exit code
  other than 0.

Furthermore, for correct programs, your compiled programs, must run and give
correct output.


Automated testing
-----------------

Before submission you **must** run that program to verify that your compiler
behaves correctly. Our first action when we receive your submission is to run
these tests. If this run fails, we will reject your submission without further
checks, so you must make sure that this step works. Unfortunately, we cannot
supply a working test driver for the Windows platform. If you have a Windows
machine, you may do most of the development, including manual testing, on that
machine, but for final testing you should transfer your project to our lab (or
remote) machines and run the test driver.

The test driver runs each good program and compares its output with the
corresponding  `.output` file. If the program needs input, this is taken from
the `.input` file. Note that the test driver handles this; your generated code
should read from `stdin` and write to `stdout`.

The tests are of course not exhaustive. It is quite possible that the grader
will discover bugs in your code even if it passes all tests.

[The tester](/resources#testsuite) is provided as a gzipped tar ball, which can
be downloaded from the course web site. You can use it to run the tests for your
project. This archive contains a test driver `Grade.hs` with supporting files,
and a subdirectory `testsuite` containing Javalette test programs.


### Installation

The tester requires a Linux (or Mac OS X, or other Unix) environment and a
recent version of the [Haskell Platform](http://haskell.org/platform). If you
work on your own Windows machine, we cannot assist you in making the tester
work. You should anyhow download the tester to get access to the testsuite in
directory `testsuite`. Before submitting, you must upload your project to a
lab machines and verify the submission.


### Running the tests

Assume that your submission directory is `dir` and that your compiler is called
`jlc`. Assume also that `dir/lib` contains the runtime support file
(`runtime.bc` for submission B, and possibly `runtime.o` for submission C).

The test driver takes a number of options:

| Flag           | Effect                                                      |
|:---------------|:------------------------------------------------------------|
| `-s <name>`    | Name of your compiler binary                                |
| `-b <backend>` | Backend to use. One of `LLVM`, `x86`, `x86_64` and `custom` |
| `-l <ver>`     | LLVM version to use for with LLVM backend (only \$llvmversion\$ has guaranteed support).                  |
| `-x <ext>`     | Implemented extensions. May be given multiple times.        |
| `-t <dir>`     | Directory in which the Javalette test programs are found.   |
| `-k`           | Keep any temporary directories created by the tester.       |
| `-h`           | Print detailed help and usage instructions.                 |

In addition, it takes one mandatory argument: a directory or tarball in which to
find your submission.

Thus, if you have placed your submission directory, `dir`, in the directory
containing `Grade.hs`, you can test your compiler as follows:

```
runhaskell Grade.hs dir
```

The above command will compile all the basic Javalette programs. The tester will
*not* attempt to run the good programs, so this is suitable for testing your
compiler for submission A. Note that it is essential that your compiler writes
one line to `stderr`, containing `OK` for correct programs and `ERROR` for
incorrect programs.

To also *run* the good programs and test them for submission B:

```
runhaskell Grade.hs -b LLVM dir
```

The test driver will report its activities in compiling the test programs and
running the good ones. If your compiler is correct, output will end as follows:

```
Summary:
 0 Compiling core programs (101/101)
 0 Running core programs (35/35)

Credits total: 0
```

All 101 test programs were compiled and gave correct indication OK or ERROR to
stderr. The 35 correct programs were run and gave correct output. Note that the
actual numbers can be different, since we may add tests.

To test the extensions for submission, run the test suite with the `-x` flag
for each extension you have implemented. The following command will run the
tests for the two array extensions.

```
runghc Grade.hs -b LLVM -x arrays1 -x arrays2 dir
```

The following extensions are supported by the test suite: `arrays1`, `arrays2`,
`pointers`, `objects1`, `objects2`. If you have implemented the x86 code
generation extension, use `-b x86` (or `-b x86_64`) to run all tests using that
instead of the LLVM backend. If your x86 compiler has a different name than
`jlc`, don't forget to specify it using `-s <compiler>`.


