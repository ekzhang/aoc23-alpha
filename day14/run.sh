#!/bin/bash

if [ "main.nim" -nt "main" ]; then
  nim c -d:release main.nim
fi

./main
