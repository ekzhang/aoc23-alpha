#!/bin/bash
set -e
cargo build -q --target wasm32-wasi --release
wasmtime target/wasm32-wasi/release/day23.wasm
