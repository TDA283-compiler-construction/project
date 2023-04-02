The Javalette language
======================

Javalette is a simple imperative language. It is almost a subset of C
(see below). It can also be easily translated to Java (see below).

Javalette is not a realistic language for production use. However, it is big
enough to allow for a core compiler project that illustrates all phases in
compilation. It also forms a basis for extensions in several directions.

The basic language has no heap-allocated data. However, the extensions involve
(Java-like) arrays, structures and objects, all of which are allocated on the
heap. The extended language is designed to be garbage-collected, but you will
not implement garbage collection as part of your project.

The description in this document is intentionally a bit vague and based on
examples; it is part of your task to define the language precisely.  However,
the language is also partly defined by a collection of test programs (see
below), on which the behaviour of your compiler is specified.

Example programs
-----------------------------

Let's start with a couple of small programs. First, here is how to say hello to
the world:

```java
// Hello world program

int main () {
  printString("Hello world!") ;
  return 0 ;
}
```

A program that prints the even numbers smaller than 10 is

```java
int main () {
  int i = 0 ;
  while (i < 10) {
    if (i % 2 == 0) printInt(i) ;
    i++ ;
  }
  return 0 ;
}
```

Finally, we show the factorial function in both iterative and recursive style:

```java
int main () {
  printInt(fact(7)) ;
  printInt(factr(7)) ;
  return 0 ;
}

// iterative factorial

int fact (int n) {
  int i,r ;
  i = 1 ;
  r = 1 ;
  while (i <= n) {
    r = r * i ;
    i++ ;
  }
  return r ;
}

// recursive factorial

int factr (int n) {
  if (n < 2)
    return 1 ;
  else
    return n * factr(n-1) ;
}
```

Program structure
-----------------

A Javalette program is a sequence of *function definitions*.

A function definition has a *return type*, a *name*, a *parameter list*, and a
*body* consisting of a *block*.

The names of the functions defined in a program must be different (i.e, there is
no overloading).

One function must have the name `main`. Its return type must be `int` and its
parameter list empty. Execution of a program consists of executing `main`.

A function whose return type is not `void` *must* return a value of its return
type. The compiler must check that it is not possible that execution of the
function terminates without passing a `return` statement. This check may be
conservative, i.e. reject as incorrect certain functions that actually would
always return a value.  A typical case could be to reject a function ending with
an `if`-statement where only one branch returns, without considering the
possibility that the test expression might always evaluate to the same value,
avoiding the branch without `return`. A function, whose return type is `void`, may, on the other hand, omit
the `return` statement completely.

Functions can be *mutually recursive*, i.e., call each other. There is no
prescribed order between function definitions (i.e., a call to a function may
appear in the program before the function definition).

There are no modules or other separate compilation facilities; we consider only
one-file programs.

Types
-----

Basic Javalette types are `int`, `double`, `boolean` and `void`.  Values of
types `int`, `double` and `boolean` are denoted by literals (see below). `void`
has no values and no literals.

No coercions (casts) are performed between types. Note this: it is NOT
considered an improvement to your compiler to add implicit casts. In fact, some
of the test programs check that you do not allow casts.

In the type checker, it is useful to have a notion of a *function type*, which
is a pair consisting of the value type and the list of parameter types.

Statements
----------

The following are the forms of statements in Javalette; we indicate syntax using
BNFC notation, where we use `Ident`, `Exp` and `Stmt` to indicate a variable,
expression and statement, respectively. Terminals are given within quotes. For
simplicity, we sometimes deviate here from the actual provided [grammar
file](/resources/Javalette.cf).

* *Empty statement*: `";"`
* *Variable declarations*: `Type Ident ";"`

    Comment: Several variables may be declared simultaneously, as in
    `int i, j;` and initial values may be specified, as in
    `int n = 0;`
* *Assignments*: `Ident "=" Exp ";"`
* *Increments and decrements*: `Ident "++" ";"` and `Ident "--" ";"`

    Comment: Only for variables of type `int`; can be seen as sugar for assignments.
* *Conditionals*:  `"if" "(" Exp ")" Stmt "else" Stmt`

    Comment: Can be without the `else` part.
* *While loops* : `"while" "(" Exp ")" Stmt`
* *Returns*: `"return" Exp ";"`

    Comment: No `Exp` for type `void`.
* *Expressions of type* `void`: `Exp ";"`

    Comment: The expression here will be a call to a void function (no other
    expressions have type `void`).
* *Blocks*: `"{" [Stmt] "}"`

    Comment: A function body is a statement of this form.

Declarations may appear anywhere within a block, but a variable must be declared
before it is used.

A variable declared in an outer scope may be redeclared in a block; the new
declaration then shadows the previous declaration for the rest of the block.

A variable can only be declared once in a block.

If no initial value is given in a variable declaration, the value of the
variable is initialized to `0` for type `int`, `0.0` for type `double` and
`false` for type `boolean`.  Note that this is different from Java, where local
variables must be explicitly initialized.

Expressions
-----------

Expressions in Javalette have the following forms:

* *Literals*: Integer, double, and Boolean literals (see below).
* *Variables*.
* *Binary operators*: `+`, `-`, `*`, `/` and
    `%`. Types are as expected; all except `%` are
    overloaded. Precedence and associativity as in C and Java.
* *Relational expressions*: `==`, `!=`,
    `<`, `<=`, `>` and `>=`. All overloaded
    as expected.
* *Disjunctions and conjunctions*: `||` and `&&`.
    These operators have *lazy semantics*, i.e.,

    * In `a && b`, if `a` evaluates to `false`,
        `b` is not evaluated and the value of the whole expression is `false`.
    * In `a || b`, if `a` evaluates to `true`,
        `b` is not evaluated and the value of the whole expression is `true`.
* *Unary operators*: `-` and `!`
    (negation of `int` and `double`, negation of `boolean`).
* Function calls.

Lexical details
---------------

Some of the tokens in Javalette are

* *Integer literals*: sequence of digits, e.g. `123`.
* *Float (double) literals*: digits with a decimal point, e.g. `3.14`,
possibly with an exponent (positive or negative), e.g. `1.6e-48`.
* *Boolean literals*:  `true` and `false`.
* *String literals*: ASCII characters in double quotes, e.g. `"Hello world"`
(escapes as usual: \verb#\n \t \" \\#). Can only be used in calls of
primitive function `printString`.
* *Identifiers*: a letter followed by an optional
sequence of letters, digits, and underscores.
* *Reserved words*: These include `while`,
  `if`, `else` and `return`.

Comments in Javalette are enclosed between `/*` and `*/` or extend from `//`
to the end of line, or from `#` to the end of line (to treat C preprocessor
directives as comments).

Primitive functions
-------------------

For input and output, Javalette programs may use the following functions:

```java
void printInt (int n)
void printDouble (double x)
void printString (String s)
int readInt ()
double readDouble ()
```

Note that there are no variables of type string in Javalette, so the only
argument that can be given to `printString` is a string literal.

The print functions print their arguments terminated by newline and the read
functions will only read one number per line. This is obviously rudimentary, but
enough for our purposes.

These functions are not directly implemented in the virtual machines we use. We
will provide them using other means, as detailed [below](#code_generation).

Parameter passing
-----------------

All parameters are passed by value, i.e., the value of the actual parameter is
computed and copied into the formal parameter before the subroutine is executed.
Parameters act as local variables within the subroutine, i.e., they can be
assigned to.

Javalette, C and Java
----------------------

Javalette programs can be compiled by a C compiler (`gcc`) if prefixed by
suitable preprocessor directives and macro definitions, e.g.

```c
#include <stdio.h>
#define printInt(k) printf("%d\n", k)
#define boolean int
#define true 1
```

In addition, function definitions must be reordered so that definition precedes
use, mutual recursion must be resolved by extra type signatures and variable
declarations moved to the beginnings of blocks.

Javalette programs can be compiled by a Java compiler (`javac`) by wrapping all
functions in a class as `public static` methods and adding one more `main`
method that calls your `main`:

```java
public static void main (String[] args) {
  main();
}
```

Using a C compiler or Java compiler is a good way to understand what a program
means even before you have written the full compiler. It can be useful to test
the programs produced by your compiler with the result of the C- and/or Java
compiler.
