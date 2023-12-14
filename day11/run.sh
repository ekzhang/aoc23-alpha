#!/bin/bash

set -e

if [ "main.kk" -nt "main" ]; then
  rm -f main # Koka doesn't return a non-zero exit code when it fails to compile
  koka -O2 -o main main.kk
  chmod +x main
fi

./main
