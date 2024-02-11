#!/bin/bash

set -e

asm="${NAKEN_BIN:-naken_asm}"

# Build sprites' tileset from spritesheets
tools/build_sprites.py data/spritesheets/dora.png > data/sprites.built.bin
tools/build_sprites.py data/spritesheets/ryu_hadoken.png >> data/sprites.built.bin

# Build backgrounds
tools/compile_background.py data/backgrounds/gecko/background.tmx data/backgrounds/gecko/

# Build sounds
tools/compile_sounds.py data/audio/index.toml data/audio/

# Assemble the game
"$asm" -l -type bin mortal_kinder.asm -o mortal_kinder.bin
