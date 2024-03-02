; Allocate space for the tilemap, which is stored in standard RAM
.org 0x0000
tilemap:
; Memory usage of the tilemap: one word per tile
;  512x256 pixels: can't be changed
;  8x8 pixels per tile: configured in src/logic/init.asm (register PPU_BG1_CTRL)
;  this is a 64x32 tiles tilemap
.resw (512/8)*(256/8)
tilemap_end:

;
; Controllers
;

controller_a_state: .resw 1
controller_b_state: .resw 1

;
; Player A
;

player_a_anim: .resw 5 ;ANIMATION_STATE_SIZE
player_a_pos_x: .resw 1

player_b_anim: .resw 5 ;ANIMATION_STATE_SIZE
player_b_pos_x: .resw 1

;
; Generic use globals
; (may be more convenient to use the stack in most cases)
;

tmpfield1: .resw 1
tmpfield2: .resw 1
