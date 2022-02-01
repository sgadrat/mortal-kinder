#!/bin/bash

set -e

asm="${NAKEN_BIN:-naken_asm}"

"$asm" -type bin mortal_kuties.asm -o mortal_kuties.bin
