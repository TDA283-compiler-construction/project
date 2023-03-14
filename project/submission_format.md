Submission format
=================

Your submission should contain the following directories and files:
* Subdirectories `src`, `lib`, `doc`.
* A `Makefile` for building your compiler.

Submission contents
-------------------

1. The `Makefile` should contain the targets `all` and `clean`.
   * The target `all` should build your compiler, and should create the following executables in the submission root:
     * (Assignment A): An executable `jlc`.
     * (Assignment A, B): An executable `jlc` for the LLVM backend.
     * (Optional, Assignment C): Executables `jlc_x86` or `jlc_x64` for the native 32/64-bit backends.
   * The target `clean` should remove all build artefacts.
2. The subdirectory `src` should contain:
   * all source code required to build your submission;
   * the grammar file you used (e.g. Javalette.cf); and
   * _nothing else_ (esp. no build artefacts, generated code, etc).
3. The subdirectory `lib` should contain:
   * (Assignment B, C): The [`runtime.ll`](/resources/runtime.ll) needed for your LLVM backend.
   * (Optional, Assignment C): The [`runtime.s`](/resources/runtime.s) needed for your x86-32 or x86-64 backend.
4. The subdirectory `doc` should contain one plain ascii file with the following content:
    * An explanation of how the compiler is used (what options, what output, etc)
    * A specification of the Javalette language (if produced by BNF converter, you may just refer to your BNFC source file).
    * A list of shift/reduce conficts in your parser, if you have such conflicts, and an analysis of them.
    * For submission C, an explicit list of extensions implemented.
    * If applicable, a list of features *not* implemented and the reason why.

Testing your submission
-----------------------

Please test your compiler before submission; see [the section on testing](testing.md).
A submission that does not pass the test suite will be rejected immediately.
