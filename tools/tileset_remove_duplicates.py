#!/usr/bin/env python

import argparse
import json
import libtile
import sys
from PIL import Image

# Parse command line
tile_w = 8
tile_h = 8
depth = 2
out_tileset = '-'
out_index = ''
show_stats = 'stderr'

parser = argparse.ArgumentParser(description='Generate a tileset from an image, removing duplicated tiles.', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('src-file', help='Image of the original tileset')
parser.add_argument('--tiles-width', type=int, default=tile_w, help='Width of the tiles in pixels')
parser.add_argument('--tiles-height', type=int, default=tile_h, help='Height of the tiles in pixels')
parser.add_argument('--depth', type=int, default=depth, help='Bit depth of pixels')
parser.add_argument('--out-tiles', type=str, default=out_tileset, help='Destination file for tileset')
parser.add_argument('--out-index', type=str, default=out_index, help='Destination file for index map')
parser.add_argument('--show-stats', type=str, default=show_stats, help='Display stats about tiles (stderr, stdout, none)')
args = parser.parse_args()

src_file = getattr(args, 'src-file')
tile_w = args.tiles_width
tile_h = args.tiles_height
depth = args.depth
out_tileset = args.out_tiles
out_index = args.out_index
show_stats = args.show_stats

# Read tileset
img = Image.open(src_file)
assert img.mode == 'P', 'input image must be paletized, current mode "{}"'.format(img.mode)

set_w = img.size[0]
set_h = img.size[1]
assert set_w % tile_w == 0, 'tileset should contain an exact number of tiles'
assert set_h % tile_h == 0, 'tileset should contain an exact number of tiles'

n_tiles_x = set_w // tile_w
n_tiles_y = set_h // tile_h
n_tiles = n_tiles_x * n_tiles_y

# Read tiles, removing dumplicates
tiles = []
index_map = {}
for source_tile_index in range(n_tiles):
	# Get tile's position on source tileset
	tile_pos_y = (source_tile_index // n_tiles_x) * tile_h
	tile_pos_x = (source_tile_index % n_tiles_x) * tile_w
	print(f" => {source_tile_index} => {tile_pos_x} x {tile_pos_y}")

	# Extract tile
	new_tile = libtile.extract_tile(
		img,
		position=(tile_pos_x, tile_pos_y),
		size=(tile_w, tile_h),
		depth=depth
	)

	# Check if we already have an equivalent tile (we want to use operator "==" and not check on object ID)
	stored_tile_index = None
	for ref_tile_index, ref_tile in enumerate(tiles):
		if ref_tile == new_tile:
			stored_tile_index = ref_tile_index
			break

	if stored_tile_index is not None:
		# Tile already exists, pur it in the reference map
		index_map[source_tile_index] = stored_tile_index
	else:
		# Tile is new, add it to tiles list
		tiles.append(new_tile)

# Output serialized tile
tile_blob = libtile.serialize_tiles(tiles)
if out_tileset == '-':
	sys.stdout.buffer.write(tile_blob)
else:
	with open(out_tileset, 'wb') as tileset_file:
		tileset_file.write(tile_blob)

# Output index map
if out_index == '-':
	json.dump(index_map, sys.stdout)
elif out_index != '':
	with open(out_index, 'wt') as index_file:
		json.dump(index_map, index_file)

# Show stats
if show_stats != 'none':
	stats_file = sys.stdout if show_stats == 'stdout' else sys.stderr
	stats_file.write(f'original number of tiles: {n_tiles}\n')
	stats_file.write(f'trimed number of tiles:   {len(tiles)}\n')
	stats_file.write(f'removed tiles:            {n_tiles - len(tiles)}\n')
