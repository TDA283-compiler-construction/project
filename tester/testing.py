#!/usr/local/bin/python3
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# Test-suite for the Javalette compiler project in the                        #
# Compiler Construction course at the Department of Computer Science and      #
# Engineering, Chalmers University of Technology and Gothenburg University.   #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# REQUIREMENTS
#
#   testing.py requires Python 3.
#
# INSTRUCTIONS
#
#   The test-suite accepts a compressed tar-ball containing your submission.
#   The tar-ball should be compressed with gzip, bzip2, or xz. The submission
#   should be created according to 'SUBMISSION FORMAT' below (see also course
#   web-page).
#
#   Example:
#     > ./testing.py path/to/partA-2.tar.gz --llvm
#
#   The following command line options are available:
#
#     -h, --help              Show help message.
#     -s                      Set compiler prefix (default is 'jlc')
#         --llvm              Test the LLVM backend
#         --x86               Test the 32-bit x86 backend
#         --x64               Test the 64-bit x86 backend
#         --riscv             Test the RISC-V backend
#         --wasm              Test the WASM JS backend
#     -x <ext> [ext ...]      Test one or more extensions
#         --noclean           Do not clean up temporary files
#
#
#   As an example, the following tests the x86-32 backend with extensions
#   'arrays1' and 'pointers' on the submission partC-1.tar.gz:
#
#     > ./testing.py partC-1.tar.gz --x86 -x arrays1 pointers
#
#   If neither of the options '--llvm', '--x86', '--x64', or '--riscv'
#   are present, only parsing and type checking is tested.
#
# EXTENSIONS
#
#   Here is a list of the extensions supported:
#
#   * arrays1      Single-dimensional arrays
#   * arrays2      Multi-dimensional arrays
#   * pointers     Structures and pointers
#   * objects1     Objects, first extension
#   * objects2     Objects, second extension (method overloading)
#   * advstructs  Optional structure tests
#   * functions    Higher order functions
#
# SUBMISSION FORMAT
#
#   Naming
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Your Nth attempt at a submission should be a compressed tar-ball named
#   according to this pattern:
#
#     part(A|B|C)-N.tar.gz
#
#   where (A|B|C) is one of A, B, or C. For example, your first attempt at
#   assignment B should be named partB-1.tar.gz.
#
#   Contents
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   The submission should contain the following directories and files,
#   _at the top level_.
#
#     doc/      All documentation for the submission (see course webpage).
#     lib/      The runtime.ll and/or runtime.s files required by your
#               compiler backend(s).
#     src/      All source-code for your submission.
#     Makefile  A makefile that builds your compiler. Running `make` or
#               `make all` should be sufficient to build your project, and
#               `make clean` should remove all build artefacts.
#
# COMPILER REQUIREMENTS
#
#   Naming
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Your compiler should be named `jlc` (without quotes) for the LLVM backend,
#   `jlc_x86` for the 32-bit x86 backend, `jlc_x64` for the 64-bit x86 backend,
#   and `jlc_riscv` for the RISC-V backend.
#
#   Input/output format
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   * Your compiler should read its input from standard input (stdin), and
#     write its output (LLVM, or assembly) to standard out (stdout).
#   * If your program succeeds (there are no errors), then it should print
#     `OK` (without quotes) to standard error (stderr), and terminate with
#     exit code 0.
#   * If your program does not succeed (there are some errors), it should print
#     a line containing the word `ERROR` to standard error (stderr) and
#     terminate with a non-zero exit code.
#

import argparse
import os
import shutil
import subprocess
import sys
import re
import platform
import tempfile
import traceback
from shutil import which

##
## Configuration record.
##
class Struct:
    def __init__(self, **kwds):
        self.__dict__.update(kwds)

##
## Exception.
##
class TestingException(Exception):
    def __init__(self, msg):
        self.msg = msg
        Exception.__init__(self, 'TestingException: %s' % msg)

##
## Indent text.
##
def indent_with(spaces, string):
    return '\n'.join(map (lambda s: " " * spaces + s, string.splitlines()))
##
## Given a list of files, remove those that exist.
##
def clean_files(files):
    for name in files:
        if os.path.isfile(name):
            os.remove(name)

##
## Run some command with some arguments and raise an exception
## if there was a failure. Optionally redirect stdout and stdin.
##
def run_command(cmd, args, stdi=None, stdo=None):
    args.insert(0, cmd)
    child = subprocess.run(
            args,
            input=stdi if stdi != None else None,
            encoding="utf-8" if stdi != None else None,
            stdout=stdo if stdo != None else subprocess.PIPE,
            stderr=subprocess.PIPE)
    if child.returncode != 0:
        err = child.stderr if stdi != None else child.stderr.decode("utf-8")
        raise TestingException(cmd + " failed with:\n" + err)

##
## Assemble and link files with LLVM.
##
def link_llvm(path, source_str):
    runtime = os.path.join(path, 'lib', 'runtime.bc')
    fd, tmp = tempfile.mkstemp(
            prefix='test_llvm_', suffix='.bc', dir=os.getcwd())
    try:
        with open(tmp, 'w+') as f:
            run_command("llvm-as", [], source_str, f)
        run_command("llvm-link", [tmp, runtime, "-o=main.bc"])
        run_command("clang", ["main.bc"])
    finally:
        os.close(fd)
        clean_files([tmp, "main.bc"])

##
## Assemble and link files with NASM for 32/64-bit x86.
##
def link_x86(path, source_str, is_x64, is_macho):
    fds, tmp_s = tempfile.mkstemp(
            prefix='test_x86_', suffix='.s', dir=os.getcwd())
    fdo, tmp_o = tempfile.mkstemp(
            prefix='test_x86_', suffix='.o', dir=os.getcwd())
    suff = 'x64' if is_x64 else 'x86'
    runtime = os.path.join(path, 'lib', 'runtime' + suff + '.o')

    if is_macho:
        arch = "macho64" if is_x64 else "macho32"
    else:
        arch = "elf64" if is_x64 else "elf32"

    try:
        with open(tmp_s, 'w+') as f:
            f.write(source_str)
        run_command("nasm", ["-f " + arch, tmp_s, "-o " + tmp_o])
        run_command("clang", ["-no-pie", tmp_o, runtime])
    finally:
        os.close(fds)
        os.close(fdo)
        clean_files([tmp_s, tmp_o])

##
## Assemble and link files with GCC for RISCV64.
##
def link_riscv(path, source_str):
    fds, tmp_s = tempfile.mkstemp(
            prefix='test_riscv_', suffix='.s', dir=os.getcwd())
    fdo, tmp_o = tempfile.mkstemp(
            prefix='test_riscv_', suffix='.o', dir=os.getcwd())
    runtime = os.path.join(path, 'lib', 'runtime-riscv.o')

    try:
        with open(tmp_s, 'w+') as f:
            f.write(source_str)
        run_command('riscv64-none-elf-gcc', ['-c', tmp_s, '-o' + tmp_o])
        run_command('riscv64-none-elf-gcc', [tmp_o, runtime])
    finally:
        os.close(fds)
        os.close(fdo)
        clean_files([tmp_s, tmp_o])

##
## Assemble and link files with WABT for WASM.
##
def link_wasm(path, source_str):
    fds, tmp_wat = tempfile.mkstemp(
            prefix='test_wasm', suffix='.wat', dir=os.getcwd())
    try:
        with open(tmp_wat, 'w+') as f:
            f.write(source_str)
        run_command('wat2wasm', [tmp_wat, '-o', 'a.out'])
    finally:
        os.close(fds)
        clean_files([tmp_wat])

##
## Compile a Javalette source file with the Javalette compiler.
##   exe       is the compiler executable
##   src_file  is the Javalette source file (with extension .jl)
##   is_good   is a boolean telling us whether the test-case is expected to
##             succeed or not
##
## Note: The Javalette compiler should take its input on stdin.
##
def run_compiler(exe, src_file, is_good):
    try:
        infile = open(src_file)
        child = subprocess.run(
                [exe],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                stdin=infile)
        stdout = child.stdout.decode("utf-8")
        stderr = child.stderr.decode("utf-8").strip()
    except OSError as exc:
        raise TestingException(
                "Unable to execute " + exe + " for some reason, " +
                "here is the errno: " + str(exc.errno) + ": " +
                exc.strerror)

    returncode_info = None
    if is_good:
        stderr_expected = "OK"
        check = lambda s: s == stderr_expected and child.returncode == 0
        if child.returncode != 0:
            returncode_info = ("compiler return code: %d, 0 expected"
                    % child.returncode)
    else:
        stderr_expected = "ERROR"
        check = lambda s: stderr_expected in s and child.returncode != 0
        if child.returncode == 0:
            returncode_info = "compiler return code: 0, nonzero expected"

    return check(stderr), Struct(
            stderr_actual = stderr,
            stderr_expected = stderr_expected,
            stdout_expected = "",
            stdout_actual = "",
            stdout_compiler = stdout,
            returncode_info = returncode_info)

##
## Execute one test.
##   exe       is the compiler executable
##   filename  is the basename of the source file
##   is_good   is a boolean telling us whether the test-case is expected to
##             succeed or not
##   linker    is the linker for whatever particular backend we're using
##             (or None, if we're only type checking)
##
def exec_test(exe, filename, is_good, linker, runner):
    input_file  = filename + ".input"
    output_file = filename + ".output"
    source_file = filename + ".jl"

    # Try to run the compiler on the source file.
    compiler_success, data = run_compiler(exe, source_file, is_good)

    # If compilation failed, or if the test is expected to fail,
    # or if we're only running the type checker, then quit here.
    if not compiler_success or not is_good or linker == None:
        return compiler_success, data

    # Assemble and link executable from the output produced by
    # the compiler.
    linker(data.stdout_compiler)

    # Check if there are input and output files associated with this
    # test.
    infile = open(input_file) if os.path.isfile(input_file) else None
    if os.path.isfile(output_file):
        with open(output_file) as f:
            stdout_expected = f.read()
    else:
        stdout_expected = ""

    # Attempt to run the program.
    try:
        command = runner + ['./a.out'] if runner else ['./a.out']
        child = subprocess.run(
                command,
                stdin=infile if infile != None else subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE)
        stdout_actual = child.stdout.decode("utf-8")
    except OSError as exc:
        raise TestingException(
                "Unable to execute ./a.out for some reason, " +
                "here is the errno: " + str(exc.errno) + ": " +
                exc.strerror)

    success = stdout_actual == stdout_expected
    return success, Struct(
            stderr_expected = data.stderr_expected,
            stderr_actual = data.stderr_actual,
            stdout_expected = stdout_expected,
            stdout_actual = stdout_actual,
            stdout_compiler = data.stdout_compiler,
            returncode_info = data.returncode_info)

##
## Build list of files for the test-cases in 'do_tests'.
##
def build_list(tests, path, is_good):
    for fname in os.listdir(path):
        if os.path.isfile(os.path.join(path, fname)):
            base, ext = os.path.splitext(fname)
            if ext == ".jl":
                tests.append((os.path.join(path, base), is_good))

##
## Initialize the argument parser.
##
def init_argparser():
    parser = argparse.ArgumentParser(
            prog="tester.py")
    parser.add_argument(
            "submission",
            metavar="<submission>",
            help="path to submission (directory or archive)")
    parser.add_argument(
            "-v", "--version",
            action="version",
            version="%(prog)s 1.0",)
    parser.add_argument(
            "-s",
            metavar="<name>",
            default="jlc",
            help="set compiler prefix (default: 'jlc')")
    parser.add_argument(
            "--llvm",
            action="store_true",
            help="test LLVM backend")
    parser.add_argument(
            "--x86",
            action="store_true",
            help="test 32-bit x86 backend")
    parser.add_argument(
            "--x64",
            action="store_true",
            help="test 64-bit x86 backend")
    parser.add_argument(
            "--riscv",
            action="store_true",
            help="test RISC-V backend")
    parser.add_argument(
            "--wasm",
            action="store_true",
            help="test WASM JS backend")
    parser.add_argument(
            "-x",
            metavar="<ext>",
            nargs="+",
            default=[],
            help="test extensions (one or several)")
    parser.add_argument(
            "--noclean",
            action="store_true",
            help="do not clean up temporary files ")
    parser.add_argument(
            "--list",
            action="store_true",
            help="list extensions")
    return parser

##
## Check archive (attempt to unpack).
##
def check_archive(path, target):
    _, fname = os.path.split(path)

    # Create target directory if it does not exist, and attempt to
    # unpack.
    sys.stdout.write("- Unpacking " + fname + " to " + target + " ... ")
    sys.stdout.flush()
    if not os.path.exists(target): # TODO redundant; Python created the file
        os.makedirs(target)
    try:
        shutil.unpack_archive(path, target)
        print("Ok.")
    except shutil.ReadError as exc:
        print("Failed.")
        raise TestingException("Unpacking failed with" + str(exc))

##
## Check submission contents.
##
def check_contents(path):
    # Check that all the contents are there.
    if not os.path.isdir(os.path.join(path, 'doc')):
        raise TestingException("Submission lacks directory: \"doc\"")
    if not os.path.isdir(os.path.join(path, 'lib')):
        raise TestingException("Submission lacks directory: \"lib\"")
    if not os.path.isdir(os.path.join(path, 'src')):
        raise TestingException("Submission lacks directory: \"src\"")
    if not os.path.isfile(os.path.join(path, 'Makefile')):
        raise TestingException("Submission lacks Makefile in root")

##
## Attempt to build submission.
##
def check_build(path, prefix, backends):
    # Attempt to run 'make'.
    make_cmd = shutil.which('make')
    sys.stdout.write("- Running make in " + path + " ... ")
    sys.stdout.flush()
    child = subprocess.run(
            [make_cmd, "-C", path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
    if not child.returncode == 0:
        print("Failed.")
        err = child.stderr.decode("utf-8")
        raise TestingException("make failed with:\n" + err)
    print("Ok.")

    # Check that 'make' produced the desired executables.
    sys.stdout.write("- Checking for executable(s) ...")
    sys.stdout.flush()
    suffices = ['llvm'] if backends == [] else backends
    for suffix in suffices:
        exec_name = prefix + ('_' + suffix if suffix != 'llvm' else '')
        full_path = os.path.join(path, exec_name)
        if not os.path.isfile(full_path):
            raise TestingException(
                    "Build did not produce the executable \"" +
                    exec_name + "\"")
        if not os.access(full_path, os.X_OK):
            raise TestingException(
                    "The file \"" + exec_name + "\" is not executable")
    print("Ok.")

    # Check that there is a runtime.ll (and optionally, runtime.s)
    # if we're testing the backend(s). Build the files if they exist.
    # TODO Lots of duplication here.
    runtime = os.path.join(path, 'lib', 'runtime')
    sys.stdout.write("- Checking for runtime(s) ... ")
    sys.stdout.flush()
    for suff in backends:
        if suff == 'llvm':
            if not os.path.isfile(runtime + '.ll'):
                print("Failed.")
                raise TestingException(
                        "\"runtime.ll\" is missing from \"lib\"")
            run_command('llvm-as', [runtime + '.ll', '-o=' + runtime + '.bc'])
        if suff == 'riscv':
            if not os.path.isfile(runtime + '-riscv.s'):
                print("Failed.")
                raise TestingException(
                        "\"runtime-riscv.s\" is missing from \"lib\"")
            run_command('riscv64-none-elf-gcc', ['-c', runtime + '-riscv.s', '-o' + runtime + '-riscv.o'])
        elif suff == 'x86' or suff == 'x64':
            if not os.path.isfile(runtime + '.s'):
                print("Failed.")
                raise TestingException(
                        "\"runtime.s\" is missing from \"lib\"")
            if platform.system() == 'Darwin':
                arch = "macho64" if suff == 'x64' else "macho32"
            else:
                arch = "elf64" if suff == 'x64' else "elf32"
            run_command('nasm',
                    ['-f ' + arch,
                     runtime + '.s',
                     '-o ' + runtime + suff + '.o'])
    print("Ok.")

## Status message.
def status_msg(filename, curr, tot):
    msg = '[{:3d}/{:3d}] {:25s} ... '
    sys.stdout.write(msg.format(curr, tot, filename))
    sys.stdout.flush()

##
## Run tests. For each backend, test all regular tests, and all extensions.
## If the list of backends is empty, only run type-checking.
##
def run_tests(path, backends, prefix, exts):
    # Print banner.
    print("About to run tests with these settings:")
    print("  Prefix:     " + prefix)
    print("  Backends:   " +
            ("None (type checking only)" if backends == [] else str(backends)))
    print("  Extensions: " + ("None" if exts == [] else str(exts)))
    print("")

    # Build a list of test cases based on the chosen extensions.
    test_files = []
    build_list(test_files, "testsuite/good", True)
    build_list(test_files, "testsuite/bad", False)
    ext_dir = "testsuite/extensions/"
    for dirname in [dirname for dirname in os.listdir(ext_dir) if os.path.isdir(os.path.join(ext_dir, dirname))]:
        ext_dir_parts = dirname.split('_')
        if set(ext_dir_parts).issubset(exts):
            build_list(test_files, "testsuite/extensions/" + dirname, True)
            bad_dir = "testsuite/extensions/" + dirname + "/bad"
            if os.path.isdir(bad_dir):
                build_list(test_files, bad_dir, False)
    tests_ok    = 0
    tests_bad   = 0
    tests_total = len(test_files)
    failures    = []
    exceptions  = []

    # If there is no backend then run the type checking.
    if backends == []:
        full_name = os.path.join(path, prefix)
        for filename, is_good in test_files:
            status_msg(filename, tests_ok + tests_bad + 1, tests_total)
            is_ok, data = exec_test(full_name, filename, is_good, None, None)
            if is_ok:
                tests_ok += 1
                print('OK')
            else:
                tests_bad += 1
                failures.append((filename, data))
                print('FAILED')
    else:
        link_macho = platform.system() == 'Darwin'
        for suffix in backends:
            tests_ok    = 0
            tests_bad   = 0
            # Pick the right assembler/linker.
            if suffix == "llvm":
                linker = lambda s: link_llvm(path, s)
                runner = None
            elif suffix == "riscv":
                linker = lambda s: link_riscv(path, s)
                runner = ['spike', which('pk')]
            elif suffix == "wasm":
                linker = lambda s: link_wasm(path, s)
                runner = ['node', os.path.join(path, 'lib', 'runtime-wasm.js')]
            elif suffix == "x86":
                linker = lambda s: link_x86(path, s, False, link_macho)
                runner = None
            else :
                linker = lambda s: link_x86(path, s, True, link_macho)
                runner = None
            exec_name = prefix + ('' if suffix == 'llvm' else '_' + suffix)
            full_name = os.path.join(path, exec_name)
            for filename, is_good in test_files:
                status_msg(filename, tests_ok + tests_bad + 1, tests_total)
                try:
                    is_ok, data = exec_test(full_name, filename, is_good, linker, runner)
                    if is_ok:
                        tests_ok += 1
                        print('OK')
                    else:
                        tests_bad += 1
                        failures.append((filename, data))
                        print('FAILED')
                except TestingException as exc:
                    tests_bad += 1
                    exceptions.append((filename, exc.msg))
                    print('FAILED')
            print()
    print()

    # Show results.
    success = tests_ok == tests_total
    if success:
        print("All tests succeeded.")
    if failures:
        print("Some tests failed:")
        for name, data in failures:
            print("---------- !!! " + name + ".jl failed !!! ----------\n")
            if data.stderr_expected != data.stderr_actual:
                print("- stderr expected:")
                print(indent_with(4, data.stderr_expected))
                print("- stderr actual:")
                print(indent_with(4, data.stderr_actual))

            if data.returncode_info:
                print("- compiler return code info:")
                print("    " + data.returncode_info)

            if len(backends) > 0:
                if len(data.stdout_expected) > 0:
                    print("- stdout expected:")
                    print(indent_with(4, data.stdout_expected))
                    print("- stdout actual:")
                    print(indent_with(4, data.stdout_actual))
            print("")
    if exceptions:
        print("Some tests caused build failures:")
        for name, msg in exceptions:
            print("---------- !!! " + name + ".jl failed !!! ----------\n")
            print(indent_with(4, msg))
            print()

##
## Do some initialization (parse arguments, etc) and
## run the tester.
##
def main():
    args = init_argparser()
    ns = args.parse_args()

    # List available extensions if --list was passed.
    avail_exts = os.listdir("testsuite/extensions")
    if ns.list:
        print("Available extensions:")
        for s in sorted(avail_exts):
            print("  * " + s)
        sys.exit(0)

    # Check that the extensions exist.
    for ext in ns.x:
        if not ext in avail_exts:
            print("Not a valid extension: " + ext, file=sys.stderr)
            sys.exit(1)

    # Check submission path exists.
    path = ns.submission
    if not os.path.exists(path):
        print("Path does not exist: " + path, file=sys.stderr)
        sys.exit(1)

    # Pick up backends.
    backends = []
    if ns.llvm:
        backends.append("llvm")
    if ns.x86:
        backends.append("x86")
    if ns.wasm:
        backends.append("wasm")
    if ns.x64:
        backends.append("x64")
    if ns.riscv:
        backends.append("riscv")

    did_unpack = False
    failure = False
    tmpdir = ''
    try:
        # If the path points to a file, treat as archive and try to unpack.
        if os.path.isfile(path):
            tmpdir = tempfile.mkdtemp(prefix='testing_', dir=os.getcwd())
            check_archive(path, tmpdir)
            did_unpack = True
            path = tmpdir

        check_contents(path)              # Check submission contents.
        check_build(path, ns.s, backends) # Attempt a build, and check that
                                          # executables were produced.

        # Run tests.
        run_tests(path, backends, ns.s, ns.x)

    except TestingException as exc:
        failure = True
        print("\ntesting.py failed with:\n" +
                indent_with(4, exc.msg),
                file=sys.stderr)
    except Exception as exc:
        failure = True
        print("\nUncaught exception: " + type(exc).__name__, file=sys.stderr)
        print(traceback.format_exc(), file=sys.stderr)
    finally:
        if not ns.noclean and os.path.isdir(tmpdir):
            print("Removing temporary files in: " + tmpdir)
            shutil.rmtree(tmpdir)
        clean_files(['a.out'])
        if failure:
            sys.exit(1)
        else:
            sys.exit(0)

if __name__ == '__main__':
    main()
