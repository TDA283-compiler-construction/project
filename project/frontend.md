The front end
=============

Your first task is to implement a compiler front end for Javalette:

1. Define suitable data types/classes for representing Javalette abstract syntax.
2. Implement a lexer and parser that builds abstract syntax from strings.
3. Implement a type checker that checks that programs are type-correct.
4. Implement a main program that calls lexer, parser and type checker, and reports errors.

These tasks are very well understood; there is a well-developed theory and, for
steps 1 and 2, convenient tools exist that do most of the work. You should be
familiar with these theories and tools and we expect you to complete the front
end during the first week of the course.

We recommend that you use the [BNF converter](https://bnfc.digitalgrammars.com/)
to build your lexer and parser. We also recommend you use `Alex` and `Happy` (if you
decide to implement your compiler in Haskell) or `JLex` and `Cup` (if you use Java).
We may also allow other implementation languages and tools, but we can not
guarantee support, and you must discuss your choice with the lecturer before you
start. This is to make sure that we will be able to run your compiler and that
you will not use inferior tools.

We provide a BNFC source file [Javalette.cf](/files/Javalette.cf) that you may
use. If you already have a BNFC file for a similar language that you want to
reuse you may do so, but you must make sure that you modify it to pass the test
suite for this course.

We will accept a small number of shift/reduce conflicts in your parser; your
documentation must describe these and argue that they are harmless.
Reduce/reduce conflicts are not allowed. The provided BNFC file has the standard
dangling-else shift/reduce conflict.

One thing to note is that it may be useful to implement the type checker as a
function, which traverses the syntax *and returns its input* if the program is
type correct.  The reason for this is that you may actually want to modify this
and decorate the syntax trees with more information during type checking for
later use by the code generator. One example of such decoration can be to
annotate all subexpressions with type information; this will be useful during
code generation. To do this, you can add one further form of expression to your
BNFC source, namely a type-annotated expression.

