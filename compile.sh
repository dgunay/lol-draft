#!/bin/bash

# Make the /build dir if it doesn't already exist
mkdir -p ./build

# Compile the program and put the executable in ./build
pp -o build/lol_draft_linux64 -c -I lib -l libcrypto.so.1.1 -l -l libz.so.1 bin/lol_draft