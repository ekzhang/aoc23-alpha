#!/bin/bash

if [ "main.ml" -nt "main" ]; then
  ocamlopt main.ml -o main
fi

./main
