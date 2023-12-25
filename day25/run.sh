#!/bin/bash
set -e

if [ "main.zig" -nt "main" ]; then
  zig build-exe main.zig -O ReleaseSafe
fi

./main
