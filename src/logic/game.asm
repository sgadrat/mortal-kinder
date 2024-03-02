game_init:
.scope
	; set sprites color palette
	;  0 and 1 are used by background
	;  16 to 31 are used by player 1 sprites
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

	; p2 palette
	ld r2, #color(31, 31, 31) | color_transparent
	st r2, [PPU_COLOR(32+0)]
	ld r2, #color(0, 0, 0)
	st r2, [PPU_COLOR(32+1)]
	ld r2, #color(9, 0, 11)
	st r2, [PPU_COLOR(32+2)]
	ld r2, #color(17, 0, 17)
	st r2, [PPU_COLOR(32+3)]
	ld r2, #color(24, 0, 0)
	st r2, [PPU_COLOR(32+4)]
	ld r2, #color(24, 0, 31)
	st r2, [PPU_COLOR(32+5)]
	ld r2, #color(18, 12, 9)
	st r2, [PPU_COLOR(32+6)]
	ld r2, #color(31, 22, 18)
	st r2, [PPU_COLOR(32+7)]
	ld r2, #color(29, 27, 26)
	st r2, [PPU_COLOR(32+8)]

	; Load background
	call load_background_gecko

	; Players
	call init_player_a
	call init_player_b

	; Play music
	call audio_init

	ld r1, #0
	ld r2, #0
	call play_music

	retf
.ends

load_background_gecko:
.scope
	; DS = background's bank
	and sr, #0b000000_1_1_1_1_111111 ; DS N Z S C CS
	or sr, #(gecko_background_info >> 6) & 0b111111_0_0_0_0_000000

	; Set address of tile graphics data
	;  The register only stores the 16 most significant bits of a 22-bit address
	;  lowest 6 bits are expected to be zero, graphics therefore need to be 64-word aligned.
	ld r1, #(gecko_background_info & 0xffff) + 0
	ld r2, D:[r1]
	st r2, [PPU_BG1_SEGMENT_ADDR]

	; Copy tilemap from ROM to RAM
	;{
		; R2 = destination address of the copied tilemap (zero-page ensured, it is RAM)
		ld r2, #tilemap

		; R3 = tilemap address (DS bank)
		ld r1, #(gecko_background_info & 0xffff) + 1
		ld r3, D:[r1]

		; R4 = tile count
		ld r1, #(gecko_background_info & 0xffff) + 2
		ld r4, D:[r1]

		; Copy loop
		copy_tilemap_loop:
			ld r1, D:[r3++]
			st r1, [r2++]
			sub r4, #1
			jnz copy_tilemap_loop
	;}

	; Set color palette
	;{
		; R2 = destination address
		ld r2, #PPU_COLOR(0)

		; R3 = tilemap address (DS bank)
		ld r1, #(gecko_background_info & 0xffff) + 4
		ld r3, D:[r1]

		; R4 = words count
		ld r1, #(gecko_background_info & 0xffff) + 5
		ld r4, D:[r1]

		; Copy loop
		copy_palette_loop:
			ld r1, D:[r3++]
			st r1, [r2++]
			sub r4, #1
			jnz copy_palette_loop
	;}

	; Set attribute of bg 1
	ld r1, #(gecko_background_info & 0xffff) + 3
	ld r2, D:[r1]
	st r2, [PPU_BG1_ATTR]

	; Set address of bg 1 tilemap
	ld r2, #tilemap
	st r2, [PPU_BG1_TILE_ADDR]

	; Set control config for bg 1
	;   bit 0: bitmap mode (0 = disable)
	;   bit 1: attribute map mode or register mode (1 = register mode)
	;   bit 2: wallpaper mode (0 = disable)
	;   bit 3: enable bg (1 = enable)
	;   bit 4: horizontal line-specific movement (0 = disable)
	;   bit 5: horizontal compression (0 = disable)
	;   bit 6: vertical compression (0 = disable)
	;   bit 7: 16-bit color mode (0 = disable)
	;   bit 8: blend (0 = disable)
	ld r2, #000001010b
	st r2, [PPU_BG1_CTRL]

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
	; Dora
	.dw 16 ; nb frames skipped between steps
	.dw 1 ; animation's first tile
	.dw 2 ; animation's last tile
	; Ryu
	;.dw 16 ; nb frames skipped between steps
	;.dw 3 ; animation's first tile
	;.dw 7 ; animation's last tile
.ends

init_player_b:
.scope
	; Animation
	ld bp, #player_b_anim
	ld r1, #anim_info
	call animation_init

	; State
	ld r1, #40
	st r1, [player_b_pos_x]

	retf

	anim_info:
	; Dora
	.dw 16 ; nb frames skipped between steps
	.dw 8 ; animation's first tile
	.dw 9 ; animation's last tile
	; Ryu
	;.dw 16 ; nb frames skipped between steps
	;.dw 3 ; animation's first tile
	;.dw 7 ; animation's last tile
.ends

game_tick:
.scope
	pos_y equ -50

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

	ld r1, [controller_a_state]
	and r1, #INPUT_BUTTON
	jz ok_button
		ld r1, #0
		ld r2, #1
		call play_sound
	ok_button:

	; Tick animation
	ld bp, #player_a_anim
	call animation_tick

	; Place sprite
	ld bp, #player_a_anim
	ld r1, [player_a_pos_x]
	ld r2, #pos_y
	call animation_display

	; Tick animation
	ld bp, #player_b_anim
	call animation_tick

	; Place sprite
	ld bp, #player_b_anim
	ld r1, [player_b_pos_x]
	ld r2, #pos_y
	call animation_display2

	retf
.ends
