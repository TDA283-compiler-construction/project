The Javalette test programs are in (subdirectories of) directory examples.

This directory contains a test driver (Grade.hs, RunCommand.hs and KompTest.hs) that
can be used to run the tests for your project.

Prerequisites
----------

We expect that you are using a Unix-like system (including Linux and
Mac OS X) and have the Haskell compiler ghc in your path.
You will then just have to do 

make

in this directory to compile  the test program. This  gives the executable program 
Grade in this same directory.

Running the tests
-----------------

Assume that your submission directory is dir and that your
compiler is called jlc. Assume also that dir/lib 
contains the runtime support file (runtime.bc and/or runtime.o).

The test driver takes a number of options and one directory or tarball as
command line arguments. The possible options are:

-s <name>          The name of your compiler (in directory dir) is <name> (default is "jlc")
-b LLVM            Target files are LLVM .bc files
-b x86             Target files are 32-bit x86 .o files
-b x86_64          Target files are 64-bit x86_64 .o files
-b custom          Target file is an executable `a.out'
-g <flag>          Pass <flag> as an option to GCC when linking.
                   Using `-g-no-pie` may be necessary on certain
                   Linux distributions.
-l <ver>           Use LLVM version <ver> (only useful with `-b LLVM')
-t <dir>           Look for the test suite in directory <dir>.
-k                 Keep around any temporary directories. Only relevant when
                   the specified submission is a tarball.
-x <extension>     Implemented extensions

The -t flag specifies where to find the directory examples which contains the
testsuite (it is in this directory). If not given, it is assumed to be in the
current working directory.

The mandatory argument is your submission directory, or a compressed archive
containing your submission.

From the directory where you unpacked the test suite, directory you may thus
run:

  ./Grade <submission>

where <submission> is the directory or tarball which contains your submission,
to compile all the basic javalette programs. The test driver will not 
attempt to run the good programs, so you may do the above
already when you have the parser working, and then when you 
have the typechecker working. 

To also run the good programs, you must specify the backend as
indicated above, i.e. for submission B:

  ./Grade -b LLVM . dir

The test driver will report its activities in compiling the test
programs and running the good ones. If your compiler is correct, 
output will end as follows:

  Summary:
   0 Compiling core programs (48/48)
   0 Running core programs (22/22)
  
  Credits total: 0

All 48 test programs were compiled and gave correct indication OK or
ERROR to stderr. The 22 correct programs were run and gave correct output.


Preparing a submission
-------------------

Your submission must be structured as specified in the project description.
We suggest that, after having prepared your tar ball, run the following
command:

  ./Grade -b LLVM partX-Y.tar.gz

The grading program, starts by extracting and building your
compiler, before running the test suite. This is how we test your
submission, so you can check whether building and testing succeeds 
before you submit. Note that if the tester does not succeed on your 
submission, we will reject it without further checks, and you will
anyhow have to redo the submission according to specification. 
