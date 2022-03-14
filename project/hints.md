Hints for the extensions
========================

The two simplest extensions are:
the one-dimensional arrays extension and
the dynamic structures (i.e. the pointers) extension.

One-dimensional arrays
----------------------

To implement this extension, the expression `new int[e]` will need to allocate
memory on the heap for the array itself and for the length attribute. Further,
the array elements must be accessed by indexing.

LLVM provides support for built-in arrays, but these are not automatically
heap-allocated. Instead, explicit pointers must be used. Thus, an array will
have the LLVM type `{i32, [0 x t]}`, where `t` is the LLVM type of the
elements. The first `i32` component holds the length; the second the array
elements themselves. The number of elements in the array is here indicated to
be 0; it is thus your responsibility to make sure to allocate enough memory. For
memory allocation you should use the C function `calloc`, which initializes
allocated memory to 0. You must add a type declaration for `calloc`, but you do
not need to worry about it at link time; LLVM:s linker includes `stdlib`.

Indexing uses the `getelementptr` instruction, which is discussed in detail in
the lectures.

The LLVM does not include a runtime system with garbage collection. Thus, this
extension should really include some means for reclaiming heap memory that is no
longer needed. The simplest would be to add a statement form `free(a)`, where
`a` is an array variable. This would be straightforward to implement, but is
*not* necessary to get the credit.

More challenging would be to add automatic garbage collection. LLVM offers some
support for this. If you are interested in doing this, we are willing to give
further credits for that task.

Multidimensional arrays
-----------------------

This extension involves more work than the previous one. In particular, you must
understand the `getelementpointer` instruction fully and you must generate code
to iteratively allocate heap memory for subarrays.

Structures/pointers and object-orientation
------------------------------------------

Techniques to do these extensions are discussed in the lectures.

From an implementation point of view, we recommend that you start with the
extension with pointers and structures. You can then reuse much of the machinery
developed to implement also the first OO extension. In fact, one attractive way
to implement the object extension is by doing a source language translation to
Javalette with pointers and structures.

The full OO extension requires more sophisticated techniques, to properly deal
with dynamic dispatch.

Native code generation
----------------------

The starting point for this extension could be your LLVM code, but you could
also start directly from the abstract syntax. Of course, within the scope of
this course you will not be able to produce a code generator that can compete
with `llc`, but it may anyhow be rewarding to do also this final piece of the
compiler yourself.

One major addition here is to handle function calls properly. Unlike LLVM (or
the Java virtual machine (JVM), which provides some support for function calls,
you will now have to handle all the machinery with activation records, calling
conventions, and jumping to the proper code before and after the call.

There are several assemblers for x86 available and even different syntax
versions. We recommend that you use the NASM assembler and that you read Paul
Carter's PC assembly [tutorial](/resources#documentation) before you start the
project, unless you are already familiar with x86 architecture. We do not have
strong requirements on code quality for your code generator. However, you must
implement some form of quality improving optimisiation, e.g. a simple version
of register allocation.

An introduction to x86 assembler will be given in the lectures.
