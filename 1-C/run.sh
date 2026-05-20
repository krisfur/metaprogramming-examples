#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cc -std=c11 -Wall -Wextra main.c -o user
./user
