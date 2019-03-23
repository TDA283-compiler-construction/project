Extensions, credits and grades
------------------------------

The options for extending the project are to extend the source language with
e.g.  arrays and `for`-loops, structures and pointers, object-oriented features
or to generate native x86 code. There is also one essay project you can do which
involves studying optimizations in the LLVM framework. You do not need to decide
in advance how ambitious you want to be; instead you should finish each stage
before you attempt an extension.

In submission C, each of the seven tasks described in the
"[extensions](extensions.md)" section gives one credit if implemented as
described, with the exception of [x86 code generation](#x86).  Implementing a
code generator gives *two* credits, but also requires you to implement some
optimization for your code generator, such as register allocation or peephole
optimization.

*To pass the course* and get grade 3 (or G, if you are a GU student), you need
to submit working solutions in *all submissions*, implement at least *one
language extension* in submission C, and pass the *oral exam*. To get grade 4,
you must earn three credits; grade 5 (VG for GU students) requires five credits.

If you are only looking to pass the course and only get one credit then the
project extension of [studying an LLVM optimization](#optstudy) is not enough.
You must implement at least one language extension to Javalette in order to pass
the course.

Part of the goal of a project course, like this course, is that you shall
deliver working code *on time*. Thus, credits will be awarded for working
extensions submitted before the deadline. We may allow resubmissions for minor
bugfixes, but no partial credits will be awarded for partial solutions.

Finally, we note that we are making major simplifications in a compiler project
by using virtual machines like LLVM as targets, rather than a real machine. This
means that you can produce simple-minded code and rely on the respective target
tools to do optimization and JIT compilation to machine code.  The final
lectures in the course will discuss these issues, but they will not be covered
in depth. On the other hand, for most compiling purposes the road we take is the
most effective. This leaves fine-tuning of optimization to LLVM tools, allowing
many source languages and front-ends to profit from this effort.

Collaboration and academic honesty
----------------------------------

As mentioned before, you work individually or in groups of two to three in this
project. You must develop your own code, and you are *not* allowed to share your
code with other students or to get, or even look at, code developed by them. On
the other hand, we encourage discussions among participants in the course about
the project. As long as you follow the simple and absolute rule not to share
code, we have no objections to questions asked and answered at a conceptual
level.

If you do get significant help from some other participant, it is natural to
acknowledge this in your documentation file.

Don't be a cheater.
