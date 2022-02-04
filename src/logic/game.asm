ANIM_FRAMERATE_LIMITER equ 32

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

	; set color palette
	ld r2, #color(29, 26, 15)
	st r2, [PPU_COLOR(0)]

	ld r2, #color(0, 8, 16)
	st r2, [PPU_COLOR(1)]

	ld r2, #color(31, 31, 31) | color_transparent
	st r2, [PPU_COLOR(2)]

	ld r2, #color(0, 0, 0)
	st r2, [PPU_COLOR(3)]

	ld r2, #color(9, 4, 0)
	st r2, [PPU_COLOR(4)]

	ld r2, #color(1, 8, 0)
	st r2, [PPU_COLOR(5)]

	ld r2, #color(0x1f, 1, 1)
	st r2, [PPU_COLOR(6)]

	ld r2, #color(0x19, 0xc, 4)
	st r2, [PPU_COLOR(7)]

	ld r2, #color(0x19, 0xb, 0x13)
	st r2, [PPU_COLOR(8)]

	ld r2, #color(0x12, 0x11, 0x15)
	st r2, [PPU_COLOR(9)]

	ld r2, #color(0x1b, 0x13, 0xa)
	st r2, [PPU_COLOR(10)]

	ld r2, #color(0x1f, 0x1f, 0)
	st r2, [PPU_COLOR(11)]

	ld r2, #color(0x1f, 0x1f, 0x1f)
	st r2, [PPU_COLOR(12)]

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
	goto init_player_a

	retf
.ends

init_player_a:
	ld r1, #ANIM_FRAMERATE_LIMITER
	st r1, [player_a_anim_counter]
	ld r1, #1
	st r1, [player_a_anim_current_tile]
	st r1, [player_a_anim_first_tile]
	ld r1, #2
	st r1, [player_a_anim_last_tile]
	retf

game_tick:
.scope
	pos_x equ -75
	pos_y equ -25
	pos_z equ 1

	;Test read controls
	ld r1, [GPIO_A_DATA]
	ld r1, [GPIO_A_DATA]
	ld r1, [GPIO_A_DATA]

	; Tick animation
	ld r1, [player_a_anim_counter]
	sub r1, #1
	st r1, [player_a_anim_counter]
	cmp r1, #0
	jnz ok
		; Reset counter
		ld r1, #ANIM_FRAMERATE_LIMITER
		st r1, [player_a_anim_counter]

		; Change anim frame
		ld r1, [player_a_anim_current_tile]
		add r1, #1
		st r1, [player_a_anim_current_tile]
		cmp r1, [player_a_anim_last_tile]
		jbe last_tile_set
			; We gone past the end, loop
			ld r1, [player_a_anim_first_tile]
			st r1, [player_a_anim_current_tile]
		last_tile_set:
	ok:


	; Place sprite
	ld r1, [player_a_anim_current_tile]
	st r1, [PPU_SPRITE_TILE(0)]

	ld r1, #pos_x
	st r1, [PPU_SPRITE_X(0)]

	ld r1, #pos_y
	st r1, [PPU_SPRITE_Y(0)]

	ld r1, #(pos_z << 12) | (SPRITE_SIZE_64 << 6) | (SPRITE_SIZE_64 << 4) | SPRITE_COLOR_DEPTH_4
	st r1, [PPU_SPRITE_ATTR(0)]
	retf
.ends
