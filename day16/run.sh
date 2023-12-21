#!/bin/bash
set -e

if [ "main.pony" -nt "day16" ]; then
  ponyc
fi

./day16 --ponypin
