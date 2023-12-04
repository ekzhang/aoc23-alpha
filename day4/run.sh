#!/bin/bash

if [ ! -d "node_modules" ]; then
  npm ci
fi

DAFNY_PATH=~/.vscode/extensions/dafny-lang.ide-vscode-*/out/resources/4.3.0/github/dafny/Dafny.dll
export PATH="/opt/homebrew/Cellar/openjdk/21.0.1/bin:$PATH"

if [ "main.dfy" -nt "main.out.js" ]; then
  dotnet $DAFNY_PATH build main.dfy -t js
  if [ $? -ne 0 ]; then
    exit 1
  fi

  cat <<EOF > main.out.js
AdventOfCode = {
  GetInput() {
    return _dafny.Seq.UnicodeFromString(require('fs').readFileSync('/dev/stdin').toString());
  },
};
EOF
  cat main.js >> main.out.js
fi

node main.out.js
