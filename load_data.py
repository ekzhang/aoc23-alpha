#!/usr/bin/env python3
"""Loads data from the AOC website."""

import os
import sys
from urllib.request import Request, urlopen

if len(sys.argv) != 2:
    print("Usage: ./load_data.py <day1|day2|...>", file=sys.stderr)
    sys.exit(1)

session = os.environ.get("SESSION")
if session is None:
    print("Error: Missing session token. Did you set the SESSION variable in .env?")
    sys.exit(1)

day = sys.argv[1]
assert day.startswith("day")

if not os.path.exists(day):
    os.makedirs(day)

file_path = os.path.join(day, "input.txt")
if not os.path.exists(file_path):
    num = int(day[3:])
    req = Request(f"https://adventofcode.com/2023/day/{num}/input")
    req.add_header("Cookie", f"session={session}")
    with urlopen(req) as resp:
        data = resp.read().decode("utf-8")
        with open(file_path, "w") as file:
            file.write(data)
