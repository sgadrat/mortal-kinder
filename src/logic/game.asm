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

	; set address of bg 1 tilemap
	ld r2, #tilemap
	st r2, [PPU_BG1_TILE_ADDR]

	; set address of tile graphics data
	; the register only stores the 16 most significant bits of a 22-bit address
	; lowest 6 bits are expected to be zero, graphics therefore need to be 64-word aligned.
	ld r2, #(font >> 6)
	st r2, [PPU_BG1_SEGMENT_ADDR]

	; set color palette
	;  0 and 1 are used by background
	;  16 to 31 are used by player 1 sprites
	ld r2, #color(29, 26, 15)
	st r2, [PPU_COLOR(0)]

	ld r2, #color(0, 8, 16)
	st r2, [PPU_COLOR(1)]

	ld r2, #color(31, 31, 31) | color_transparent
	st r2, [PPU_COLOR(16+0)]

	ld r2, #color(0, 0, 0)
	st r2, [PPU_COLOR(16+1)]

	ld r2, #color(9, 4, 0)
	st r2, [PPU_COLOR(16+2)]

	ld r2, #color(1, 8, 0)
	st r2, [PPU_COLOR(16+3)]

	ld r2, #color(0x1f, 1, 1)
	st r2, [PPU_COLOR(16+4)]

	ld r2, #color(0x19, 0xc, 4)
	st r2, [PPU_COLOR(16+5)]

	ld r2, #color(0x19, 0xb, 0x13)
	st r2, [PPU_COLOR(16+6)]

	ld r2, #color(0x12, 0x11, 0x15)
	st r2, [PPU_COLOR(16+7)]

	ld r2, #color(0x1b, 0x13, 0xa)
	st r2, [PPU_COLOR(16+8)]

	ld r2, #color(0x1f, 0x1f, 0)
	st r2, [PPU_COLOR(16+9)]

	ld r2, #color(0x1f, 0x1f, 0x1f)
	st r2, [PPU_COLOR(16+10)]

	ld r2, #color(0x1b, 0x19, 0x16)
	st r2, [PPU_COLOR(16+11)]

	ld r2, #color(0x12, 0x1b, 0x1e)
	st r2, [PPU_COLOR(16+12)]

	ld r2, #color(0x1e, 0x1b, 0x14)
	st r2, [PPU_COLOR(16+13)]

	ld r2, #color(0x1c, 0x1c, 0x19)
	st r2, [PPU_COLOR(16+14)]

	ld r2, #color(0x1e, 0x1f, 0x1f)
	st r2, [PPU_COLOR(16+15)]

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

	; Players
	call init_player_a

	retf
.ends

init_player_a:
.scope
	; Animation
	ld bp, #player_a_anim
	ld r1, #anim_info
	call animation_init

	; State
	ld r1, #-75
	st r1, [player_a_pos_x]

	retf

	anim_info:
	.dw 16 ; nb frames skipped between steps
	.dw 1 ; animation's first tile
	.dw 2 ; animation's last tile
.ends

game_tick:
.scope
	pos_y equ -25

	; Apply inputs
	ld r1, [controller_a_state]
	and r1, #INPUT_RIGHT
	jz ok_right
		ld r2, [player_a_pos_x]
		add r2, #1
		st r2, [player_a_pos_x]
	ok_right:

	ld r1, [controller_a_state]
	and r1, #INPUT_LEFT
	jz ok_left
		ld r2, [player_a_pos_x]
		sub r2, #1
		st r2, [player_a_pos_x]
	ok_left:

	; Tick animation
	ld bp, #player_a_anim
	call animation_tick

	; Place sprite
	ld bp, #player_a_anim
	ld r1, [player_a_pos_x]
	ld r2, #pos_y
	call animation_display

	retf
.ends
