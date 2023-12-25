#!/bin/bash
set -e

YUE_PATH=Yuescript/bin/release/yue

if [ ! -f $YUE_PATH ]; then
  echo "Yue not found, building..."
  make -C Yuescript -j8 release LUAI=/opt/homebrew/include/lua LUAL=/opt/homebrew/lib/lua
fi

$YUE_PATH -e day24.yue
