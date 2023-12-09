#!/bin/bash

if [ "src/day7.gleam" -nt "build/dev/erlang/day7/ebin/day7.beam" ]; then
  gleam build
fi

export ERL_LIBS=build/dev/erlang
erl -noshell -s day7 main -s erlang halt
