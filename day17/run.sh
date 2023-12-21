#!/bin/bash
set -e

if [ ! -f "build/qi" ]; then
  cmake -S qi/src -B build
  make -j8 -C build
fi

# Append a final line to the input, due to limitations of Qi.
# Also split lines in half because of a bug. :/
cat <(cat | fold -w 80) <(echo "完毕") | build/qi main.qi
