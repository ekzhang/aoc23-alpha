#!/bin/bash

if [ ! -f "CBQN/BQN" ]; then
  make -C CBQN
fi

./CBQN/BQN main.bqn
