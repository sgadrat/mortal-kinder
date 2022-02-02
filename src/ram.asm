; allocate space for the tilemap, which is stored in standard RAM
; put the tilemap somewhere other than 0 (unununium crashes with tilemap at 0)
.org 0x0001
tilemap:
.resw (512/8)*(256/8) ; 8x8 sized tiles = 64*32 sized tilemap
tilemap_end:

; Player A
player_a_anim_counter: .resw 1
player_a_anim_current_tile: .resw 1
player_a_anim_first_tile: .resw 1
player_a_anim_last_tile: .resw 1
