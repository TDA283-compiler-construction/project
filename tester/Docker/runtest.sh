#!/bin/bash

function helpmsg {
  echo "USAGE: $1 <submission> [options]" >&2
  echo "OPTIONS:" >&2
  echo "  -h            this message" >&2
  echo "  -l            test LLVM backend" >&2
  echo "  -y            test x86-32 backend" >&2
  echo "  -Y            test x86-64 backend" >&2
  echo "  -x <ext>      test extension <ext>" >&2
  echo "                (pass many of these for multiple extensions)"
  echo "  -a            expect submission to be archive" >&2
  echo "  -n            pass --noclean if archive" >&2
  echo "                (keeps temporary files, and keeps container alive)" >&2
  echo "  -i <image>    custom docker image" >&2
  echo "                (default: tda283/tester:latest)" >&2
}

if [[ $# -eq 0 ]]; then
  helpmsg $0
  exit 1
fi

submission="$1"

if [[ ! -d "$submission" ]]; then
  if [[ ! -f "$submission" ]]; then
    echo "$1 is not a file or directory" >&2
    exit 1
  fi
fi

shift 1

OPTIND=1

test_llvm=false
test_x86=false
test_x64=false

# Default docker image, can be overridden with -i
image="tda283/tester:latest"

while getopts ":hlyYx:i:an" opt; do
  case $opt in
    a)
      archive="--archive"
      ;;
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
  echo "Failed to create contained" >&2
fi

name=`docker ps --filter id="$cont" --format '{{.Names}}'`
echo "Running in container $name ($cont)"

docker cp "$submission" "$cont:/home/user/subm/"
docker exec -u root "$cont" chown -R user /home/user/subm

docker exec -u user "$cont" python3 testing.py /home/user/subm/$base \
                                               $backends \
                                               $exts \
                                               $archive \
                                               $noclean

if [[ "$noclean" == "" ]]; then
  docker kill "$cont"
  docker rm "$cont"
else
  echo "Container ID: $cont" >&2
  echo "Container name: $name" >&2
  echo "Attach with: docker exec -ti $name /bin/bash"
fi

