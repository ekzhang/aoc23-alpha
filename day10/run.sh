#!/bin/bash

if [ "Main.j" -nt "Main.class" ]; then
  jasmin Main.j
fi

java Main
