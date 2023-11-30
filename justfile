set dotenv-load := true

list:
  just -l

load DAY:
  ./load_data.py {{DAY}}

run DAY: (load DAY)
  cd {{DAY}} && ./run.sh < input.txt

run-all:
  #!/usr/bin/env sh
  set -e
  for i in $(seq 1 25); do
    echo "[just run day$i]"
    just run "day$i" 2> /dev/null
  done
