#!/usr/bin/env python
import sys

# Convert hex colors to V.Smile color space (5 bits per pixel)

def convert(orig):
	return int(orig, 16) // (2**3)

for color in sys.argv[1:]:
	print('{}: 0x{:02x}, 0x{:02x}, 0x{:02x}'.format(
		color,
		convert(color[0:2]),
		convert(color[2:4]),
		convert(color[4:6])
	))
