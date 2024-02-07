#!/usr/bin/env python
import json
import struct
import sys

#
# FIXME
# This is a dummy script generating the tilemap knowing that all tiles are just flat in original tileset
# Must be replaced by a proper tilemap generation from the .tmx file in tools/
#

with open('/tmp/gecko.json', 'rt') as f:
	index_map = json.loads(f.read())

tilemap = b''
for i in range(2048):
	tile_index = index_map.get(str(i), i) + 1 # Beware: +1 cause the first tile is unusable so tilemaps are effectively 1-indexed while original data is 0-indexed
	tilemap += struct.pack('<H', tile_index)

sys.stdout.buffer.write(tilemap)
