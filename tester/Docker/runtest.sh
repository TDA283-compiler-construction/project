#!/bin/bash

function helpmsg {
  echo "USAGE: $1 [options] [--] <submission>" >&2
  echo "OPTIONS:" >&2
  echo "  -h            this message" >&2
  echo "  -l            test LLVM backend" >&2
  echo "  -y            test x86-32 backend" >&2
  echo "  -Y            test x86-64 backend" >&2
  echo "  -v            test risc-v backend" >&2
  echo "  -w            test wasm backend" >&2
  echo "  -x <ext>      test extension <ext>" >&2
  echo "                (pass many of these to test multiple extensions)"
  echo "  -n            keep container and temporary files" >&2
  echo "  -i <image>    custom docker image" >&2
  echo "                (default: tda283/tester:latest)" >&2
}

if [[ $# -eq 0 ]]; then
  helpmsg $0
  exit 1
fi

test_llvm=false
test_x86=false
test_x64=false
test_riscv=false
test_wasm=false

# Default docker image, can be overridden with -i
image="tda283/tester:latest"

while getopts ":hlyYvwx:i:n" opt; do
  case $opt in
    n)
      noclean="--noclean"
      ;;
    h)
      helpmsg $0
      exit 1
      ;;
    l)
      if [[ "$test_llvm" = false ]]; then
        backends="--llvm $backends"
        test_llvm=true
      fi
      ;;
    y)
      if [[ "$test_x86" = false ]]; then
        backends="--x86 $backends"
        test_x86=true
      fi
      ;;
    Y)
      if [[ "$test_x64" = false ]]; then
        backends="--x64 $backends"
        test_x64=true
      fi
      ;;
    v)
      if [[ "$test_riscv" = false ]]; then
        backends="--riscv $banckends"
        test_riscv=true
      fi
      ;;
    w)
      if [[ "$test_wasm" = false ]]; then
        backends="--wasm $backends"
        test_wasm=true
      fi
      ;;
    x)
      exts="$OPTARG $exts"
      ;;
    i)
      image="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      helpmsg $0
      exit 1
      ;;
  esac
done

shift $(($OPTIND - 1))

submission="$1"

if [[ ! -d "$submission" ]]; then
  if [[ ! -f "$submission" ]]; then
    echo "$1 is not a file or directory" >&2
    exit 1
  fi
fi

if [[ -n "$exts" ]]; then
  exts="-x $exts"
fi

echo "Running tests with:" >&2
echo "  submission:    $submission" >&2
echo "  backend(s):    $backends" >&2
echo "  extensions(s): $exts" >&2
echo "  image:         $image" >&2

base=`basename $submission`
name="tda283-test-$base"

if [[ -z `docker ps -q -a -f name="$name"` ]]; then
  cont=`docker run -m 4096M --name "$name" -td -h "$name" "$image"`
else
  cont=`docker run -m 4096M -td -h tda283-test "$image"`
fi

if [[ $? -ne 0 ]]; then
  echo "Failed to create container" >&2
fi

name=`docker ps --filter id="$cont" --format '{{.Names}}'`
echo "Running in container $name ($cont)"

docker cp "$submission" "$cont:/home/user/subm/"
docker exec -u root "$cont" chown -R user /home/user/subm

docker exec -u user "$cont" python3 testing.py /home/user/subm/$base \
                                               $backends \
                                               $exts \
                                               $noclean

if [[ "$noclean" == "" ]]; then
  docker kill "$cont"
  docker rm "$cont"
else
  echo "Container ID: $cont" >&2
  echo "Container name: $name" >&2
  echo "Attach with: docker exec -ti $name /bin/bash"
fi

