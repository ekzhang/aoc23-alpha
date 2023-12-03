#!/bin/bash

DAFNY_PATH=~/.vscode/extensions/dafny-lang.ide-vscode-*/out/resources/4.3.0/github/dafny/Dafny.dll

if [ "main.dfy" -nt "main.jar" ]; then
  dotnet $DAFNY_PATH build main.dfy -t java
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

java -jar main.jar
