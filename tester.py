# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# Test-suite for the course in Compiler Construction at the CSE dept.,       #
# Chalmers University of Technology.                                         #
# May, 2018.                                                                      @
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# REQUIREMENTS
#
#   The test-suite requires Python version 3 to run.
#
# INSTRUCTIONS
#
#   The test-suite accepts two types of input: either the directory where your
#   built submission (i.e. the `jlc' executable, `src' and `lib' directories)
#   resides, or a compressed file containing your input:
#
#   > python3 tester.py path/to/your/submission
#   > python3 tester.py path/to/partB-2.tar.gz
#
#   The package should be created according to the instructions under
#   "submission format" below.
#
#   The test-suite accepts a number of options:
#
#      -b (LLVM|x86|x86_64)    Test your LLVM/x86/x86_64 backend.
#      -x <extension>
#         [, extensions ...]   Test one or more extensions.
#
#   As an example, the following tests the LLVM backend with extensions
#   `arrays1' and `pointers' on the submission partC-1.tar.gz:
#
#   > python3 tester.py -b LLVM -x arrays1 pointers partC-1.tar.gz
#
# LIST OF EXTENSIONS
#
#   The test-suite will look for extensions in the directory
#   `testsuite/extensions'. These are the available extensions:
#
#     - arrays1      Single-dimensional arrays
#     - arrays2      Multi-dimensional arrays
#     - pointers     Structs and pointers
#     - objects1     Objects, first extension
#     - objects2     Objects, second extension (method overload)
#     - adv_structs  Something?
#
# SUBMISSION FORMAT
#
#   Your Nth attempt at a submission should be a gzipped tar-ball named
#   according to the following pattern:
#
#     part(A|B|C)-N.tar.gz
#
#   For example, your first submission of assignment B should be named
#   partB-1.tar.gz. We also accept tar-balls compressed with bzip, xz,
#   as well as zip- and rar- archives and uncompressed tar-balls.
#
#   In your submission archive should be the following directories and files.
#
#     doc/       Containing all documentation for the submission.
#                (This is not vital for the test-suite to work).
#     lib/       Containing all runtime.ll or runtime.s files required
#                by your compiler backend.
#     src/       Containing the source code for your submission.
#     Makefile   A make file which builds your project. (Running `make` or
#                `make all` should be sufficient to build your project).
#
#   Note that the things above  should NOT be placed inside an additional
#   directory -- calling tar -xzf partB-1.tar.gz should create these files in
#   the place where the command was called.
#
# COMPILER REQUIREMENTS
#
#   - Your compiler should be named `jlc' (without quotes) for the LLVM backend,
#     and `jlc_x86' or `jlc_x86_64' for the 32-bit and 64-bit x86 backends,
#     respectively.
#   - Calling `jlc my_file.jl' should compile the input file `my_file.jl'
#     resulting in the following files appearing **in the same directory as the
#     input file**:
#
#       + my_file.ll containing LLVM source code (LLVM backend)
#       + my_file.s  containing assembly code    (native x86 backends)
#
#     Note that for x86 backends the test-suite expects NASM syntax.
#
#   - For correct programs your compiler should output `OK' (without quotes) on
#     standard error and terminate with exit code 0.
#   - For incorrect programs, your compiler should output `ERROR' (without
#     quotes) on standard error and an informative error message on standard
#     output, and terminate with a non-zero exit code.
#
#   - IMPORTANT: Your submission must be callable from other directories than
#     the one it lives in. Please ensure that the test suite can be run on your
#     packaged submission before submitting.

import argparse
import os
import subprocess
import sys

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# Utility/Misc                                                               #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

class Struct:
    def __init__(self, **kwds):
        self.__dict__.update(kwds)

class TestSuiteException(Exception):
    def __init__(self, msg):
        self.msg = msg
        Exception.__init__(self, 'TestSuiteException: %s' % msg)

def do_check(check, path, msg):
    if not check (path):
        raise TestSuiteException(msg + ": " + path)

def indent_with(spaces, string):
    return '\n'.join(map (lambda s: " " * spaces + s, string.splitlines()))

# Build list of files for run_tests.
def build_list(tests, path, is_good):
    for f in os.listdir(path):
        if os.path.isfile(path + "/" + f):
            base, ext = os.path.splitext(f)
            if ext == ".jl":
                tests.append((path + "/" + base, is_good))

# Try to run a command, raise an exception if it does not terminate with
# exit code 0.
def try_run_cmd(args):
    try:
        child = subprocess.run(
                    args,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE)
    except OSError as exc:
        raise TestSuiteException(
                "failed when trying to run " + str(args) + " with " +
                str(exc.errno) + ": " + exc.strerror)
    if child.returncode != 0:
        raise TestSuiteException("failed when trying to run: " + str(args) +
                                 ":\n" + child.stderr.decode("utf-8").strip())

    return

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# Parsing command-line arguments                                             #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

def init_argparser():
    parser = argparse.ArgumentParser(
            prog="python tester.py")

    parser.add_argument(
            "submission",
            metavar="<submission>",
            help="path to the submission directory")

    parser.add_argument(
            "-v", "--version",
            action="version",
            version="%(prog)s 1.0",)

    parser.add_argument(
            "-s",
            metavar="<name>",
            default="jlc",
            help="the name of your compiler executable (default is 'jlc')")

    parser.add_argument(
            "-b",
            choices=["LLVM", "x86", "x64"],
            help="specify backend (only type checking is done when omitted)")

    parser.add_argument(
            "-x",
            metavar="<extension>",
            nargs="+",
            default=[],
            help="specify implemented extensions (one or several)")

    parser.add_argument(
            "--noclean",
            action="store_true",
            help="do not clean up temporary files after running")

    return parser

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# Assembling, linking and running for various backends                       #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

def link_llvm(filename):
    try_run_cmd(["llvm-as", filename + ".ll"])
    try_run_cmd(["llvm-link", filename + ".bc", "lib/runtime.bc", "-o=main.bc"])
    try_run_cmd(["llc", "-filetype=obj", "main.bc"])
    try_run_cmd(["cc", "main.o"])

def link_x86(filename):
    try_run_cmd(["nasm", "-f elf32", filename + ".s", "-o " + filename + ".o"])
    try_run_cmd(["cc", filename + ".o", "lib/runtime.o"])

def link_x86_64(filename):
    try_run_cmd(["nasm", "-f elf64", filename + ".s", "-o " + filename + ".o"])
    try_run_cmd(["cc", filename + ".o", "lib/runtime.o"])

def run_compiler(exe, src_file, is_good):
    try:
        child = subprocess.run(
                    [exe, src_file],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE)
        stdout = child.stdout.decode("utf-8")
        stderr = child.stderr.decode("utf-8").strip()
    except OSError as exc:
        raise TestSuiteException(
                "failed when trying to run compiler with errno=" +
                str(exc.errno) + ": " + exc.strerror)

    if is_good:
        stderr_expected = "OK"
        check = lambda s: s == stderr_expected and child.returncode == 0
    else:
        stderr_expected = "ERROR"
        check = lambda s: stderr_expected in s and child.returncode != 0

    return check(stderr), Struct(stderr_compiler = stderr,
                                 stderr_expected = stderr_expected,
                                 stdout_expected = "",
                                 stdout_program  = "",
                                 stdout_compiler = stdout)

def run_all(exe, filename, is_good, linker):
    input_file  = filename + ".input"
    output_file = filename + ".output"
    source_file = filename + ".jl"

    # Try running compiler
    compiler_success, data = run_compiler(exe, source_file, is_good)
    if not compiler_success or not is_good or linker == None:
        return compiler_success, data

    # Assemble and link executable
    linker(filename)

    # Check for input and output files
    infile = open(input_file) if os.path.isfile(input_file) else None
    if os.path.isfile(output_file):
        with open(output_file) as f:
            stdout_expected = f.read()
    else:
        stdout_expected = ""

    # Try to run program
    try:
        child = subprocess.run(["./a.out"],
                               stdin=infile if infile != None else subprocess.PIPE,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
        stdout_program = child.stdout.decode("utf-8")
    except OSError as exc:
        raise TestSuiteException(
                "failed when trying to run a.out with errno=" +
                str(exc.errno) + ": " + exc.strerror)

    success = stdout_program == stdout_expected
    return success, Struct(stderr_expected = data.stderr_expected,
                           stderr_compiler = data.stderr_compiler,
                           stdout_expected = stdout_expected,
                           stdout_program  = stdout_program,
                           stdout_compiler = data.stdout_compiler)

def run_typecheck(exe, filename, is_good):
    return run_compiler(exe, filename + ".jl", is_good)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# Running and/or unpacking tests                                             #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

def run_tests(config):
    # Check choice of backend is ok
    has_backend = config.backend != None
    if has_backend:
        if config.backend == "LLVM":
            linker = link_llvm
        elif config.backend == "x86":
            linker = link_x86
        elif config.backend == "x64":
            linker = link_x86_64
        else: # This should not be possible as other strings are not accepted
            raise TestSuiteException("unsupported backend: " + config.backend)
    else:
        linker = None

    # Check if choice of extensions is good (just check if the directory exists)
    for ext in config.exts:
        do_check(os.path.isdir,
                "testsuite/extensions/" + ext,
                "cannot find extension:")

    # Fetch contents of the lib/ folder if has_backend and compile runtime
    if has_backend:
        sys.stdout.write("Fetching lib files...")
        sys.stdout.flush()
        lib_path = config.path + "/lib"
        do_check(os.path.isdir, lib_path, "no lib directory at")
        child = subprocess.run(["cp", "-R", lib_path, "."],
                                stderr=subprocess.PIPE)
        stderr = child.stderr.decode("utf-8").strip()
        if child.returncode != 0:
            raise TestSuiteException(
                    "could not copy lib files: " + lib_path +
                    "\n" + stderr)
        print("OK")

        sys.stdout.write("Compiling runtime...")
        sys.stdout.flush()
        if config.backend == "LLVM":
            cmd, opt, arg = "llvm-as", "", lib_path + "/runtime.ll"
        elif config.backend == "x86":
            cmd, opt, arg = "nasm", "-f elf32", lib_path + "/runtime.s"
        else:
            cmd, opt, arg = "nasm", "-f elf64", lib_path + "/runtime.s"
        child = subprocess.run(
                    [cmd, opt, arg] if opt != "" else [cmd, arg],
                    stderr=subprocess.PIPE)
        stderr = child.stderr.decode("utf-8").strip()
        if child.returncode != 0:
            raise TestSuiteException("could not build runtime:\n" + stderr)
        print("OK")

    # Print banner
    print("About to run tests:")
    print("- executable: " + config.exec_name)
    print("- backend:    " + str(config.backend))
    print("- extensions: " + str(config.exts))
    print("")

    # Build list of tests
    test_files = []
    build_list(test_files, "testsuite/good", True)
    build_list(test_files, "testsuite/bad", False)
    if not config.exts == None:
        for ext in config.exts:
            build_list(test_files, "testsuite/extensions/" + ext, True)

    tests_ok    = 0
    tests_bad   = 0
    tests_total = len(test_files)
    failed      = []

    print("- Running tests:")
    for filename, is_good in test_files:

        is_ok, data = run_all(config.exec_path, filename, is_good, linker)
        if is_ok:
            tests_ok += 1
        else:
            tests_bad += 1
            failed.append((filename, data))

        msg = '\r  ok: {:d}, failed: {:d}, progress: {:d}/{:d}'
        msg = msg.format(tests_ok, tests_bad, tests_ok + tests_bad, tests_total)
        sys.stdout.write(msg)
    print("\n")

    # Show results
    success = tests_ok == tests_total
    if success:
        print("All tests ok!")
    else:
        for name, data in failed:
            print("!!! " + name + " failed !!!")
            print("- expected output on stderr: " + data.stderr_expected)
            print("- compiler output to stderr: " + data.stderr_compiler)
            print("- compiler output to stdout: " + data.stdout_compiler)
            if has_backend:
                if len(data.stdout_expected) > 0:
                    print("- expected output on stdout:")
                    print(indent_with(2, data.stdout_expected))
                    print("- program output to stdout:")
                    print(indent_with(2, data.stdout_program))

    # Clean up libpath
    if has_backend:
        sys.stdout.write("Cleaning up runtime...")
        sys.stdout.flush()
        child = subprocess.run(
                    ["rm", "-rfv", "lib"],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE)
        print("OK")

    return success

def run_unpack(config):
    subloc = "tmp"
    did_unpack = False
    try:
        _, ext = os.path.splitext(config.path)

        # Check extension
        if ext == ".tar":
            cmd, opt, epi = "tar", "xf", "-C"
        elif ext == ".gz":
            cmd, opt, epi = "tar", "xzf", "-C"
        elif ext == ".bz2":
            cmd, opt, epi = "tar", "xjf", "-C"
        elif ext == ".xz":
            cmd, opt, epi = "tar", "xJf", "-C"
        elif ext == ".zip":
            cmd, opt, epi = "unzip", "", ""
        elif ext == ".rar":
            cmd, opt, epi = "unrar", "x", ""
        else:
            raise TestSuiteException("unsupported extension: " + ext)

        # Unpack submission to "tmp/"
        sys.stdout.write("Unpacking submission...")
        sys.stdout.flush()
        if not os.path.exists(subloc):
            os.makedirs(subloc)
        child = subprocess.run(
                    [cmd, opt, config.path, epi, subloc + "/"],
                    stderr=subprocess.PIPE)
        if not child.returncode == 0:
            print("FAILED")
            raise TestSuiteException("unpacking failed:\n" +
                    child.stderr.decode("utf-8"))
        print("OK")
        did_unpack = True

        # Go into "tmp/src" and run "make"
        sys.stdout.write("Building submission...")
        sys.stdout.flush()
        if not os.path.exists(subloc + "/src"):
            print("FAILED")
            raise TestSuiteException("submission did not contain folder `src'")
        child = subprocess.run(
                    ["sh", "-exec", "make -C " + subloc + "/src/"],
                    stderr=subprocess.PIPE)
        if not child.returncode == 0:
            print("FAILED")
            raise TestSuiteException(
                    "make failed:\n" + child.stderr.decode("utf-8"))
        print("OK")

        # Check that this produced an executable
        do_check(os.path.isfile,
                subloc + "/" + config.exec_name,
                "executable does not exist")
        do_check(lambda path: os.access(path, os.X_OK),
                subloc + "/" + config.exec_name, "not an executable")

        return run_tests(
                 Struct(
                     path      = subloc,
                     exec_path = subloc + "/" + config.exec_name,
                     exec_name = config.exec_name,
                     backend   = config.backend,
                     exts      = config.exts,
                     no_clean  = config.no_clean))
    finally:
        if did_unpack and not config.no_clean:
            sys.stdout.write("Cleaning up package contents...")
            sys.stdout.flush()
            child = subprocess.run(["rm", "-rfv", subloc])
            print("DONE")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# Initialization                                                             #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

def main():
    # -- Process command line arguments --------------------------------------
    args = init_argparser()
    ns   = args.parse_args()

    # -- Settings ------------------------------------------------------------
    config = Struct(
               path      = ns.submission,
               exec_path = ns.submission + "/" + ns.s,
               exec_name = ns.s,
               backend   = ns.b,
               exts      = ns.x,
               no_clean  = True if ns.noclean != None else False)

    is_package = False
    print("- path to submission: " + config.path)
    print("- name of executable: " + config.exec_name)

    # -- Perform some checks -------------------------------------------------
    try:
        sys.stdout.write("Performing checks...")
        sys.stdout.flush()
        do_check(os.path.isdir,
                "testsuite",
                "testsuite does not exist at")
        do_check(os.path.isdir,
                "testsuite/good",
                "testsuite does not exist at")
        do_check(os.path.isdir,
                "testsuite/bad",
                "testsuite does not exist at")
        do_check(os.path.isdir,
                "testsuite/extensions",
                "testsuite does not exist at")

        # If its not a directory, check if its a file, and send it to run_unpack
        try:
            do_check(os.path.isdir, config.path, "")
        except:
            do_check(os.path.isfile, config.path, "submission does not exist")
            is_package = True

        if not is_package:
            do_check(os.path.isfile, config.exec_path, "executable does not exist")
            do_check(lambda path: os.access(path, os.X_OK),
                    config.exec_path, "not an executable")
        print("OK")

        # Run tests
        success = False
        if is_package:
            success = run_unpack(config)
        else:
            success = run_tests(config)

        # Exit with non-zero unless success
        if success:
            sys.exit(0)
        else:
            sys.exit(1)

    except TestSuiteException as exc:
        print ("")
        print ("ERROR: " + exc.msg, file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()

