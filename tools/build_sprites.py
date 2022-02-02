#!/usr/bin/env python

import sys

#TODO find spritesheets and build it
#     for now, just hardocde some things

sprite_w = 32
sprite_h = 32

def print_sprite(color):
	global sprite_w, sprite_h
	sys.stdout.buffer.write(color*sprite_w*sprite_h)

print_sprite(b'\0')
print_sprite(b'\0')
print_sprite(b'\1')
print_sprite(b'\2')
print_sprite(b'\3')
print_sprite(b'\4')
print_sprite(b'\5')
print_sprite(b'\6')
