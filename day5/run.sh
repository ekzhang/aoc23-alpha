#!/bin/bash

set -e

if [ "main.erl" -nt "main.beam" ]; then
  erl -compile main
fi

erl -noshell -s main -s erlang halt
