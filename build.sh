#!/bin/bash

set -e

asm="${NAKEN_BIN:-naken_asm}"

tools/build_sprites.py data/spritesheets/dora.png > data/sprites.built.bin
"$asm" -l -type bin mortal_kuties.asm -o mortal_kuties.bin
