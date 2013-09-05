#!/bin/bash

# in case we're run from out of git repo
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$DIR" 1>/dev/null

# now change to the git root
ROOT_DIR="$(git rev-parse --show-toplevel)"
pushd "$ROOT_DIR" 1>/dev/null

echo '$ git submodule update --init --recursive'
git submodule update --init --recursive
pushd coq-HoTT
echo '$ ./configure -prefix "'"$COQBIN"'" -debug -no-native-compiler'
./configure -prefix "$COQBIN" -debug -no-native-compiler
echo '$ make coqlight'
make coqlight
echo '$ sudo make install-coqlight'
sudo make install-coqlight
popd

popd 1>/dev/null
popd 1>/dev/null
