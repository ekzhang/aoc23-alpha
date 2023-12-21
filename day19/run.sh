#!/bin/bash
set -e

if [ "main.swift" -nt "main" ]; then
  swiftc main.swift
fi

./main
