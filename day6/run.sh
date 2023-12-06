#!/bin/bash

set -e

if [ ! -f "flix.jar" ]; then
  wget https://github.com/flix/flix/releases/download/v0.42.0/flix.jar
fi

if [ "src/Main.flix" -nt "artifact/day6.jar" ]; then
  java -jar flix.jar build
  java -jar flix.jar build-jar
fi

java -jar artifact/day6.jar
