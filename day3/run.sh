#!/bin/bash

if [ ! -d carp-v0.5.5-x86_64-macos ]; then
  wget -O carp.zip https://github.com/carp-lang/Carp/releases/download/v0.5.5/carp-v0.5.5-x86_64-macos.zip && \
    unzip carp.zip </dev/null
  rm -f carp.zip
fi

export CARP_DIR="$(pwd)/carp-v0.5.5-x86_64-macos"

if [ "main.carp" -nt "out/Untitled" ]; then
  $CARP_DIR/bin/carp -x main.carp
else
  out/Untitled
fi
