#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# C++26 reflection (P2996) needs the bloomberg/clang-p2996 fork.
# Point CLANG_P2996 at its install prefix, or symlink clang++ there.
: "${CLANG_P2996:?set CLANG_P2996 to your clang-p2996 install prefix, e.g. /opt/clang-p2996}"
export CC="$CLANG_P2996/bin/clang"
export CXX="$CLANG_P2996/bin/clang++"

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build -j
./build/app
