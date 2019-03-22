Testing the project
===================

Needless to say, you should test your project extensively. We provide a
[test suite](/tester) of programs and will run your compiler on
these. 

You can download the test suite from the course web site and run it
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
  messages. The compiler must then exit with the exit code 0.
* reject all of the files in `testsuite/bad/*.jl`. For these files, the compiler
  must print  `ERROR` as the first line to standard error and then give an
  informative error message. The compiler must then exit with an exit code
  other than 0.

Furthermore, for correct programs, your compiled programs, must run and give
correct output.

Automated testing
-----------------

Please see the [test suite](/tester) for instructions on how to test your submission.
You **must** verify that your compiler passes the test suite before submission.
Any submission that does not pass the test suite will be rejected immediately.

