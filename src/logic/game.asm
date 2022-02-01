game_init:
.scope
	; clear tilemap
	ld r2, #' ' ; ASCII space
	ld r3, #tilemap
	ld r4, #tilemap_end
	clear_tilemap_loop:
	st r2, [r3++]
	cmp r3, r4
	jb clear_tilemap_loop

	 ;set address of bg 1 tilemap
	ld r2, #tilemap
	st r2, [PPU_BG1_TILE_ADDR]

	; set address of tile graphics data
	; the register only stores the 16 most significant bits of a 22-bit address
	; lowest 6 bits are expected to be zero, graphics therefore need to be 64-word aligned.
	ld r2, #(font >> 6)
	st r2, [PPU_BG1_SEGMENT_ADDR]

	; set color 0 of palette
	ld r2, #color(29,26,15)
	st r2, [PPU_COLOR(0)]

	; set color 1 of palette
	ld r2, #color(0,8,16)
	st r2, [PPU_COLOR(1)]

	; current palette also uses color 2 and 3
	; though our graphics only use color 0-1

	; write string into tilemap

	; the position of a specific tile can be calculated by:
	; tilemap start address + (row * number of columns) + column
	; where row and column values are 0-indexed
	; number of columns is 512 / horizontal size
	; number of rows is 256 / vertical size

	; start string in row 2, column 3
	ld r3, #(tilemap + 64*2 + 3)

	; the start address of the sprite to draw is determined by
	; graphics start address + sprite size in words * tile ID
	; where sprite size in words is calculated by:
	; (vertical size * horizontal size * color depth in bits) / 16

	ld r2, #'H' ; write some characters
	st r2, [r3++]

	ld r2, #'e'
	st r2, [r3++]

	ld r2, #'y'
	st r2, [r3++]

	ld r2, #'!'
	st r2, [r3++]

	ld r2, #' '
	st r2, [r3++]

	ld r2, #'V'
	st r2, [r3++]

	ld r2, #'.'
	st r2, [r3++]

	ld r2, #'S'
	st r2, [r3++]

	ld r2, #'m'
	st r2, [r3++]

	ld r2, #'i'
	st r2, [r3++]

	ld r2, #'l'
	st r2, [r3++]

	ld r2, #'e'
	st r2, [r3++]

	ld r2, #'!'
	st r2, [r3++]

	retf
.ends

game_tick:
	retf
