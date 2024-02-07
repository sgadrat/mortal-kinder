#!/usr/bin/env python
import json
import struct
import sys

with open('/tmp/gecko.json', 'rt') as f:
	index_map = json.loads(f.read())

tilemap = b''
for i in range(2048):
	tile_index = index_map.get(str(i), i)
	tilemap += struct.pack('<H', tile_index)

sys.stdout.buffer.write(tilemap)
