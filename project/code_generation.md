Code generation: LLVM
=====================

Once the [front end](frontend.md) is complete, your next task is to
implement code generation for LLVM, i.e. your task is to make your
compiler generate LLVM code for the given Javalette source code.

LLVM
----

LLVM (Low Level Virtual Machine) is both an intermediate
representation language and a compiler infrastructure, i.e. a
collection of software components for manipulating (e.g. optimizing)
LLVM code and backends for various architectures.  LLVM has a large
user base and is actively developed. A lot of information and code to
download can be found at the LLVM web site `http://www.llvm.org`. Make
sure your LLVM version is compatible with the one used in the testing
[Docker](/tester/Docker) has only guaranteed support for this
particular version.

Also LLVM code comes in two formats, a human-readable assembler format (stored
in `.ll` files) and a binary bitcode format (stored in`.bc` files). Your
compiler will produce the assembler format and you will use the LLVM assembler
`llvm-as` to produce binary files for execution.

In addition to the assembler, the LLVM infrastructure consists of a large number
of tools for optimizing, linking, JIT-compiling and manipulating bitcode. One
consequence is that a compiler writer may produce very simple-minded LLVM code
and leave to the LLVM tools to improve code when needed. Of course, similar
remarks apply to JVM code.


LLVM code
---------

The LLVM virtual machine is a *register machine*, with an infinite supply of
typed, virtual registers. The LLVM intermediate language is a version of
*three-address code* with arithmetic instructions that take operands from two
registers and place the result in a third register. LLVM code must be in SSA
(static single assignment) form, i.e. each virtual register may only be assigned
once in the program text.

The LLVM language is typed, and all instructions contain type information. This
"high-level" information, together with the "low-level" nature of the virtual
machine, gives LLVM a distinctive flavour.

The LLVM web site provides a wealth of information, including language
references, tutorials, tool manuals etc. There will also be lectures focusing on
code generation for LLVM.


The structure of a LLVM file
----------------------------

There is less overhead in the LLVM file. But, since the language is typed, we
must inform the tools of the types of the primitive functions:

```llvm
declare void @printInt(i32)
declare void @printDouble(double)
declare void @printString(i8*)
declare i32 @readInt()
declare double @readDouble()
```

Here `i32` is the type of 32 bit integers and `i8*` is the type of a pointer to
an 8 bit integer (i.e., to a character). Note that function names in LLVM always
start with `@`.

Before running a compiled Javalette program, `myfile.bc` must be linked with
`runtime.bc`, a file implementing the primitive functions, which we will
provide. In fact, this file is produced by giving `clang` a simple C file with
definitions such as

```c
void printInt(int x) {
  printf("%d\n",x);
}
```


An example
----------

The following LLVM code demonstrates some of the language features in LLVM. It
also serves as an example of what kind of code a Javalette compiler could
generate for the `fact` function described [here](javalette.md#example-programs).

```llvm
define i32 @main() {
entry:  %t0 = call i32 @fact(i32 7)             ; function call
        call void @printInt(i32 %t0)
        ret  i32 0

}

define i32 @fact(i32 %__p__n) {
entry:  %n = alloca i32                         ; allocate a variable on stack
        store i32 %__p__n , i32* %n             ; store parameter
        %i = alloca i32
        %r = alloca i32
        store i32 1 , i32* %i                   ; store initial values
        store i32 1 , i32* %r
        br label %lab0                          ; branch to lab0

lab0:   %t0 = load i32, i32* %i                 ; load i
        %t1 = load i32, i32* %n                 ; and n
        %t2 = icmp sle i32 %t0 , %t1            ; boolean %t2 will hold i <= n
        br i1 %t2 , label %lab1 , label %lab2   ; branch depending on %t2

lab1:   %t3 = load i32, i32* %r
        %t4 = load i32, i32* %i
        %t5 = mul i32 %t3 , %t4                 ; compute i * r
        store i32 %t5 , i32* %r                 ; store product
        %t6 = load i32, i32* %i                 ; fetch i,
        %t7 = add i32 %t6 , 1                   ; add 1
        store i32 %t7 , i32* %i                 ; and store
        br label %lab0

lab2:   %t8 = load i32, i32* %r
        ret  i32 %t8

}
```

We note several things:

* Registers and local variables have names starting with `%`.
* The syntax for function calls uses conventional parameter lists (with type
  info for each parameter).
* Booleans have type `i1`, one bit integers.
* After initialization, we branch explicitly to `lab0`, rather than just falling
  through.


LLVM tools
----------

Your compiler will generate a text file with LLVM code, which is conventionally
stored in files with suffix `.ll`. There are then several tools you might use:

* The *assembler* `llvm-as`, which translates the file to an equivalent binary
  format, called the *bitcode* format, stored in files with suffix `.bc` This is
  just a more efficient form for further processing. There is a *disassembler*
  `llvm-dis` that translates in the opposite direction.
* The *linker* `llvm-link`, which can be used to link together, e.g., `main.bc`
  with the bitcode file `runtime.bc` that defines the function `@printInt` and
  the other `IO` functions. By default, two files are written, `a.out` and
  `a.out.bc`.  As one can guess from the suffix, `a.out.bc` is a bitcode file
  which contains the definitions from all the input bitcode files.
* The *interpreter/JIT compiler* `lli`, which directly executes its bitcode file
  argument, using a Just-In-Time (JIT) compiler.
* The *static compiler* `llc`, which translates the file to a native assembler
  file for any of the supported architectures. It can also produce native object
  files using the flag `-filetype=obj`
* The *analyzer/optimizer* `opt`, which can perform a wide range of code
  optimizations of bitcode.
* The wrapper `clang` which uses various of the above tools together to provide
  a similar interface to `GCC`.

Note that some installations of LLVM require a version number after the tool
name, for example `llvm-as-3.8` instead of `llvm-as`.

Here are the steps you can use to produce an executable file from within your
compiler:

* Your compiler produces an LLVM file, let's call it `prog.ll`.
* Convert the file to bitcode format using `llvm-as`. For our example file,
  issue the command `llvm-as prog.ll`. This produces the file `prog.bc`.
* Link the bitcode file with the runtime file using `llvm-link`. This step
  requires that you give the name of the output file using the `-o` flag. For
  example we can name the output file `main.bc` like so: `llvm-link prog.bc
  runtime.bc -o main.bc`.
* Generate a native object file using `llc`. By default `llc` will produce
  assembler output, but by using the flag `-filetype=obj` it will produce an
  object file. The invocation will look like this: `llc -filetype=obj main.bc`
* Finally, produce an executable. The simplest way to do this is with
  `clang main.o`

A simpler alternative to the above steps is to let `clang` run the various
LLVM tools, with `clang prog.ll runtime.bc`

Also note that the [testing framework](/tester) will call LLVM itself, and
will link in the runtime library as well. For the purposes of assignment
submission, your compiler need only produce an LLVM file (the equivalent of
`prog.ll` above).

Optimizations
-------------

To whet your appetite, let us see how the LLVM code can be optimized:

```
> cat myfile.ll | llvm-as | opt -std-compile-opts | llvm-dis
```

```llvm
declare void @printInt(i32)

define i32 @main() {
entry:
	tail call void @printInt(i32 5040)
	ret i32 0
}

define i32 @fact(i32 %__p__n) nounwind readnone {
entry:
	%t23 = icmp slt i32 %__p__n, 1
	br i1 %t23, label %lab2, label %lab1

lab1:
	%indvar = phi i32 [ 0, %entry ], [ %i.01, %lab1 ]
	%r.02 = phi i32 [ 1, %entry ], [ %t5, %lab1 ]
	%i.01 = add i32 %indvar, 1
	%t5 = mul i32 %r.02, %i.01
	%t7 = add i32 %indvar, 2
	%t2 = icmp sgt i32 %t7, %__p__n
	br i1 %t2, label %lab2, label %lab1

lab2:
	%r.0.lcssa = phi i32 [ 1, %entry ], [ %t5, %lab1 ]
	ret i32 %r.0.lcssa
}
```

The first line above is the Unix command to do the optimization. We `cat` the
LLVM assembly code file and pipe it through the assembler, the optimizer and the
disassembler. The result is an optimized file, where we observe:

* In `main`, the call `fact(7)` has been completely computed to the result
  `5040`. The function `fact` is not necessary anymore, but remains, since we
  have not declared that `fact` is local to this file (one could do that).
* The definition of `fact` has been considerably optimized. In particular, there
  is no more any use of memory; the whole computation takes place in registers.
* We will explain the `phi` instruction in the lectures; the effect of the first
  instruction is that the value of `%indvar` will be 0 if control comes to
  `%lab1` from the block labelled `%entry` (i.e. the first time) and the value
  will be the value of `%i.01` if control comes from the block labelled `%lab1`
  (i.e. all other times). The `phi` instruction makes it possible to enforce the
  SSA form; there is only one assignment in the text to `%indvar`.

If we save the optimized code in `myfileOpt.bc` (without disassembling it), we
can link it together with the runtime using:

```
> llvm-link myfileOpt.bc runtime.bc -o a.out.bc
```

If we disassemble the resulting file `a.out.bc`, we get (we have edited the file
slightly in inessential ways):

```llvm
@fstr = internal constant [4 x i8] c"%d\0A\00"

define i32 @main() nounwind {
entry:
        %t0 = getelementptr [4 x i8]* @fstr, i32 0, i32 0
        %t1 = call i32 (i8*, ...)* @printf(i8* %t0, i32 5040) nounwind
        ret i32 0
}

declare i32 @printf(i8*, ...) nounwind
```

What remains is a definition of the format string `@fstr` as a global constant
(`\0A` is `\\n`), the `getelementpointer` instruction that returns a pointer to
the beginning of the format string and a call to `printf` with the result value.
Note that the call to `printInt` has been inlined, i.e., replaced by a call to
`printf`; so linking includes optimizations across files.

We can now run `a.out.bc` using the just-in-time compiler `lli`. Or, if we
prefer, we can produce native assembly code with `llc`. On a x86 machine, this
gives

```
        .text
        .align  4,0x90
        .globl  _main
_main:
        subl    $$12, %esp
        movl    $$5040, 4(%esp)
        movl    $$_fstr, (%esp)
        call    _printf
        xorl    %eax, %eax
        addl    $$12, %esp
        ret
        .cstring
_fstr:                          ## fstr
        .asciz  "%d\n"
```
