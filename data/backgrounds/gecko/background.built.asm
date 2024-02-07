; The graphics data needs to be 64-word aligned
.align_bits 64*16
gecko_background_tiles:
.resw (8*8*4)/16 ; tile 0 unusable, not in tileset files
.binfile "../data/backgrounds/gecko/background.built.tileset"

gecko_background_tilemap:
.binfile "../data/backgrounds/gecko/background.built.tilemap"
gecko_background_tilemap_end:

gecko_background_palette:
.include "../data/backgrounds/gecko/background.built.palette"
gecko_background_palette_end:

; Status bits
;   bit 0-1: color depth (0 = 2-bit)
;   bit 2: horizontal flip (0 = no flip)
;   bit 3: vertical flip (0 = no flip)
;   bit 4-5: X size (0 = 8 pixels)
;   bit 6-7: Y size (0 = 8 pixels)
;   bit 8-11: palette (0 = palette 0, colors 0-3 for 2-bit)
;   bit 12-13: depth (0 = bottom layer)
color_depth equ 1     ; 0=2-bit ; 1=4-bit ; 2=6-bit ; 3=8-bit
horizontal_flip equ 0 ; 0=no ; 1=yes
vertical_flip equ 0   ; 0=no ; 1=yes
x_size equ 0          ; 0=8-pixels ; ...
y_size equ 0          ; 0=8-pixels ; ...
palette_number equ 0
bg_depth equ 0        ; 0=bottom-layer ; ...

gecko_background_info:
.dw gecko_background_tiles >> 6       ; address of tiles (64 words aligned)
.dw gecko_background_tilemap & 0xffff ; address of tilemap (lsw) (msw is assumed to be the same as this structure)
.dw gecko_background_tilemap_end - gecko_background_tilemap ; tilemap size (in words)
.dw (bg_depth<<12) + (palette_number<<8) + (y_size<<6) + (x_size<<4) + (vertical_flip<<3) + (horizontal_flip<<2) + color_depth ; BG attributes
.dw gecko_background_palette & 0xffff
.dw gecko_background_palette_end - gecko_background_palette

;TODO ensure that all this file is in the same bank
