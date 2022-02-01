; allocate space for the tilemap, which is stored in standard RAM
; put the tilemap somewhere other than 0 (unununium crashes with tilemap at 0)
.org 0x0001
tilemap:
.resw (512/8)*(256/8) ; 8x8 sized tiles = 64*32 sized tilemap
tilemap_end:
