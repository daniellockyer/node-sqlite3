#!/usr/bin/env bash

set -e -u

source ./scripts/publish.sh

platform=$(uname -s | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")

if [[ $(uname -s) == "Linux" ]]; then
    sudo apt-get install libavahi-compat-libdnssd-dev libzmq3-dev
fi

echo "building binaries for publishing"
CFLAGS="${CFLAGS:-} -include $(pwd)/src/gcc-preinclude.h" CXXFLAGS="${CXXFLAGS:-} -include $(pwd)/src/gcc-preinclude.h" V=1 npm install --build-from-source  --clang=1
nm lib/binding/*/node_sqlite3.node | grep "GLIBCXX_" | c++filt  || true
nm lib/binding/*/node_sqlite3.node | grep "GLIBC_" | c++filt || true

npm test

publish

# now test building against shared sqlite
echo "building from source to test against external libsqlite3"
export NODE_SQLITE3_JSON1=no
if [[ $(uname -s) == 'Darwin' ]]; then
    brew update
    brew install sqlite
    brew --prefix
    export LDFLAGS="-L/usr/local/opt/sqlite/lib"
    export CPPFLAGS="-I/usr/local/opt/sqlite/include"
    npm install --build-from-source --sqlite=$(brew --prefix) --clang=1
else
    npm install --build-from-source --sqlite=/usr --clang=1
fi

npm test

export NODE_SQLITE3_JSON1=yes
