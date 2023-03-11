Extensions
==========

This section describes optional extensions that you may implement to
learn more, get credits and thus a higher final grade. You may choose
different combinations of the extensions.

This page specifies the requirements on the extensions. Some
implementation hints are given on a separate page for [extension
hints](hints.md) and in the lecture notes.

**Credits for extensions:** each of the standard extensions gives one
credit point. Extensions that are non-standard in this sense are the
_native x86 code generation_ and some projects within the _further
possibilities_ section.  The _native x86 code generation_ is special
in that it gives two credits in itself and an extra credit for each
of the standard extensions that are ported to the x86 code
generator. Example: a student can collect 5 credits as follows.

 - one-dimensional arrays for LLVM code generator (1 credit)
 - multi-dimensional arrays for LLVM code generator (1 credit)
 - native x86 code generation (2 credits)
 - one-dimensional arrays for x86 code generator (1 credit)

The course homepage explains how credits translate into course grades.

One-dimensional arrays and for loops (arrays1)
----------------------------------------------

The basic Javalette language has no heap-allocated data, so memory management
consists only of managing the run-time stack. In this extension you will add
one-dimensional arrays to basic Javalette. To get the credit, you must implement
this in the front end and in the respective back end.

Arrays are Java-like: variables of array type contain a reference to the actual
array, which is allocated on the heap. Arrays are explicitly created using a
`new` construct and variables of array type have an attribute, `length`, which
is accessed using dot notation. The semantics follows Java arrays.

Some examples of array declarations in the extension are

```java
int[] a ;
double[] b;
```

Creating an array may or may not be combined with the declaration:

```java
a = new int[20];
int[] c = new int[30];
```

After the above code, `a.length` evaluates to 20 and `a` refers to an array of
20 integer values, indexed from 0 to 19 (indexing always starts at 0). It is not
required to generate bounds-checking code.

Functions may have arrays as arguments and return arrays as results:

```java
int[] sum (int[] a, int[] b) {
  int[] res = new int [a.length];
  int i = 0;
  while (i < a.length) {
    res[i] = a[i] + b[i];
    i++;
  }
  return res;
}
```

One new form of expressions is added, namely indexing, as shown in the example.
Indexed expressions may also occur as L-values, i.e., as left hand sides of
assignment statements. An array can be filled with values by assigning each
individual element, as in function `sum`. But one can also assign references as
in C or Java:

```java
c = a;
```

Arrays can be passed as parameters to functions, and returned from functions.
When passed or returned, or assigned to a variable as above, it is a reference
that is copied, not the contents of the array. The following function returns
3.

```java
int return3 (void) {
  int[] arr = new int [1];
  int[] arr2 = new int [2];

  arr2 = arr;
  arr2[0] = 3;
  return arr[0];
}
```

The extension also includes implementation of a simple form of `foreach`-loop to
iterate over arrays. If `expr` is an expression of type  `t[]`, the following
is a new form of statement:

```
for (t var : expr) stmt
```

The variable `var` of type `t` assumes the values `expr[0]`, `expr[1]` and so on
and the `stmt` is executed for each value. The scope of `var` is just `stmt`.

This form of loop is very convenient when you want to iterate over an array and
access the elements, but it is not useful when you need to assign values to the
elements. For this, we still have to rely on the `while` loop. The traditional
`for`-loop would be attractive here, but we cannot implement everything.

The length of an array is of type int. The `new` syntax for creating a new
array is an expression. It can take any (integer type) expression as the new
length, and it can be used in other locations than initialisers.

The array type does not support any other operations. There is no need for an
equality or less-than test for the array type, for instance.

Test files for this extension are in subdirectory `extensions/arrays1`.

Multi-dimensional arrays (arrays2)
----------------------------------

In this extension you add arrays with an arbitrary number of indices.  Just as
in Java, an array of type `int[][]` is a one-dimensional array, each of whose
elements is a one-dimensional array of integers.  Declaration, creation and
indexing is as expected:

```java
int[][] matrix = new int[10][20];
int[][][] pixels;
...
matrix[i][j] =  2 * matrix[i][j];
```

You must specify the number of elements in each dimension when creating an
array. For a two-dimensional rectangular array such as `matrix`, the number of
elements in the two dimensions are `matrix.length` and `matrix[0].length`,
respectively.

Dynamic data structures (pointers)
----------------------------------

In this extension you will implement a simple form of dynamic data structures,
which is enough to implement lists and trees.  The source language extensions
are the following:

* Two new forms of top-level definitions are added (in the basic
    language there are only function definitions):
    1. *Structure definitions*, as examplified by
        ```c
        struct Node {
           int elem;
           list next;
        };
        ````
    2. *Pointer type definitions*, as examplified by
        ```c
        typedef struct Node *list;
        ```
        Note that this second form is intended to be very restricted. We can
        only use it to introduce new types that represent pointers to
        structures. Thus this form of definition is completely fixed except for
        the names of the structure and the new type. Note also that, following
        the spirit of Javalette, the order of definitions is arbitrary.
* Three new forms of expression are introduced:
    1. *Heap object creation*, examplified by `new Node`,
        where `new` is a new reserved word.  A new block of heap
        memory is allocated and the expression returns a pointer to that
        memory. The type of this expression is thus the type of pointers
        to `Node`, i.e. `list`.
    2. *Pointer dereferencing*,
        examplified by `xs->next`. This returns the content of the
        field `next` of the heap node pointed to by `xs`.
    3. *Null pointers*, examplified by `(list)null`. Note that
        the pointer type must be explicitly mentioned here, using syntax
        similar to casts (remember that there are no casts in Javalette).
* Finally, pointer dereferencing may also be used as L-values and thus occur to
    the left of an assignment statement, as in
    ```c
    xs->elem = 3;
    ```

Here is an example of a complete program in the extended language:

```c
typedef struct Node *list;

struct Node {
  int elem;
  list next;
};


int main () {
  printInt (length (fromTo (1, 100)));
  return 0;
}

list cons (int x, list xs) {
  list n;
  n = new Node;
  n->elem = x;
  n->next = xs;
  return n;
}

list fromTo (int m, int n) {
  if (m>n)
    return (list)null;
  else
    return cons (m, fromTo (m + 1, n));
}

int length (list xs) {
  int res = 0;
  while (xs != (list)null) {
    res++;
    xs = xs->next;
  }
  return res;
}
```

This and a few other test programs can be found in the `extensions/pointers`
subdirectory of the test suite.

Object-orientation (objects1)
-----------------------------

This extension adds classes and objects to basic Javalette. From a language
design point of view, it is not clear that you would want both this and the
previous extension in the same language, but here we disregard this.

Here is a first simple program in the proposed extension:

```java
class Counter {
  int val;

  void incr () {
    val++;
    return;
  }

  int value () {
    return val;
  }
}

int main () {
  Counter c;
  c = new Counter;
  c.incr ();
  c.incr ();
  c.incr ();
  int x = c.value ();
  printInt (x);
  return 0;
}
```

We define a class `Counter`, and in `main` create an object and call its methods
a couple of times. The program writes 3 to `stdout`.

The source language extensions, from basic Javalette, are

* A new form of top-level definition: a *class declaration*.
    A class has a number of instance variables and a number of methods.

    Instance variables are private and are *only* visible within the methods of
    the class. We could not have written `c.val` in `main`.

    All methods are public; there is no way to define private methods.  It would
    not be difficult in principle to allow this, but we must limit the task.

    There is always only one implicit constructor method in a class, with no
    arguments.  Instance variables are, as all variables in Javalette,
    initialized to default values: numbers to 0, booleans to false and object
    references to null.

    We support a simple form of single inheritance: a class may extend another
    one:

    ```java
    class Point2 {
      int x;
      int y;

      void move (int dx, int dy) {
         x = x + dx;
         y = y + dy;
      }

      int getX () { return x; }

      int getY () { return y; }
    }

    class Point3 extends Point2 {
      int z;

      void moveZ (int dz) {
        z = z + dz;
      }

      int getZ () { return z; }

    }

    int main () {
      Point2 p;

      Point3 q = new Point3;

      q.move (2,4);
      q.moveZ (7);
      p = q;

      p.move (3,5);

      printInt (p.getX());
      printInt (p.getY());
      printInt (q.getZ());

      return 0;
    }
    ```

    Here `Point3` is a subclass of `Point2`. The program above prints 5, 9 and 7.

    Classes are types; we can declare variables to be (references to) objects of
    a certain class. Note that we have subtyping: we can do the assignment `p =
    q;`. The reverse assignment, `q = p;` would be a type error. We have a
    strong  restriction, though: we will *not* allow overriding of methods. Thus
    there is no need for dynamic dispatch; all method calls can be statically
    determined.
* There are four new forms of expression:

    1. `"new" Ident` creates a new object, with fields initialized as described
        above.
    2. `Expr "." Expr`, is a method call; the first expression must evaluate to
        an object reference and the second to a call of a method of that object.
    3. `"(" Ident ") null"` is the null reference of the indicated class/type.
    4. `"self"` is, within the methods of a class, a reference to the current
        object. All calls to other, sibling methods of the class must be
        indicated as such using `self`, as in `self.isEmpty()` from one of the
        test files. This requirement is natural, since the extended Javalette,
        in contrast to Java, has free functions that are not methods of any
        class.

Object orientation with dynamic dispatch (objects2)
---------------------------------------------------

The restriction not to allow method override is of course severe. In this
extension the restriction is removed and subclassing with inheritance and method
override implemented. This requires a major change of implementation as compared
to the previous extension. It is no longer possible to decide statically which
code to run when a message is sent to an object. Thus, each object at runtime
must have a link to a class descriptor, a struct with pointers to the code of
the methods of the class. These class descriptor are linked together in a list,
where a class descriptor has a link to the descriptor of its superclass. This
list is searched at runtime for the proper method to execute. All this is
discussed more during the lectures.

Higher-order functions (functions)
----------------------------------

This extension adds non-polymorphic function values to Javalette. Functions
become first class, i.e., functions can take functions as arguments and return
functions as results. Javalette remains call-by-value.

```java
int apply(fn(int) -> int f, int x) {
  return f(x);
}

fn(int) -> int compose(fn(int) -> int f, fn(int) -> int g) {
  return \(int x) -> int: f(g(x));
}

int main() {
  int inc(int x) {
    return x + 1;
  }
  fn(int) -> int times2 = \(int x) -> int: x * 2;

  printInt(apply(compose(inc, times2), 3));
  printInt(apply(compose(times2, inc), 3));

  return 0;
}
```

This language extension adds:
- function definitions as non-top-level definitions e.g. `inc` above
- function types e.g. `fn(int) -> int`
- lambda expression e.g. `\(int x) -> int: x * 2`

It is recommended that this extension is done after the `pointers` extension.
The best way to implement function values is via closures, which are discussed
in the later lectures.

Native x86 code generation
--------------------------

This extension is to produce native assembler code for a real machine,
preferrably x86. We may accept code generators for other architectures, but
*you* need to think of how we can test your extension. Before you attempt to
write a backend for another architecture, discuss your choice with the lecturer
and explain the testing procedure.

Note that this extension gives you *two* credits, but it is not enough to just
implement a naïve code generator. You must also implement some sort of
optimization, such as register allocation or peephole optimization. Talk to
the lecturer about which optimization(s) to implement before attempting the x86
code generator. The x86 code generation extension acts also as a kind of
multiplier, that is, implementing another extension, for example arrays, will
give you two credits instead of one. This fair because you need to generate
code for both LLVM and x86.

Study of LLVM optimization
--------------------------

We offer one possibility to get a credit that does not involve implementing a
Javalette extension. This is to do a more thorough study of the LLVM framework
and write a report of 4-5 pages. More precisely the task is as follows.

Look at the list of available optimization passes and choose at least three of
these for further study. Email the lecturer to agree that your choice is suitable
(do this *before* you start to work on the extension!).

For each pass you must:

* Describe the optimization briefly; what kind of analysis is involved, how is
  code transformed?
* Find a Javalette program that is suitable to illustrate the optimization. List
  the program, the LLVM code generated by your compiler and the LLVM code that
  results by using `opt` to apply this pass (and only this pass). In addition to
  the code listing, explain how the general description in the previous item
  will actually give the indicated result. Part of the task is to find a program
  where the pass has an interesting effect.

We emphasize again that if you are only looking to pass the course and only get
one credit then this project is not enough. You have to implement at least one
extension to Javalette in order to pass the course.

Further possibilities
---------------------

We are willing to give credits also to other extensions, which are not as well
defined. If you want to do one of these and get credit, you must discuss it with
the lecturer in advance. Here are some possibilities:

* Implement an optimisation such as common-subexpression elimination, dead-code
  elimination, or loop-invaraint code motion as a Javelette-to-Javalette code
  transformation.
* Provide a predefined type of lists with list comprehensions, similar to what
  is available in Python.
* Allow functions to be statically nested.
* A simple module system. Details on module systems will be provided in the
  lectures.
* Implement exceptions, which can be thrown and caught.
* Implement some form of garbage collection.
* Implement a backend for another architecture, such as RISC-V. It is important
  that you provide some way for the grader to test programs.
