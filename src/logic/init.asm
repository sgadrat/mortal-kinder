int off ; turn off interrupts as soon as possible

ld r1, #0

; initialize system ctrl
st r1, [SYSTEM_CTRL]

; clear watchdog just to be safe
ld r2, #0x55aa
st r2, [WATCHDOG_CLEAR]

; set background scroll values for bg 1
st r1, [PPU_BG1_SCROLL_X] ; scroll X offset of bg 1 = 0
st r1, [PPU_BG1_SCROLL_Y] ; scroll Y offset of bg 1 = 0

; set attribute config for bg 1
; bit 0-1: color depth (0 = 2-bit)
; bit 2: horizontal flip (0 = no flip)
; bit 3: vertical flip (0 = no flip)
; bit 4-5: X size (0 = 8 pixels)
; bit 6-7: Y size (0 = 8 pixels)
; bit 8-11: palette (0 = palette 0, colors 0-3 for 2-bit)
; bit 12-13: depth (0 = bottom layer)
st r1, [PPU_BG1_ATTR] ; set attribute of bg 1

; set control config for bg 1
; bit 0: bitmap mode (0 = disable)
; bit 1: attribute map mode or register mode (1 = register mode)
; bit 2: wallpaper mode (0 = disable)
; bit 3: enable bg (1 = enable)
; bit 4: horizontal line-specific movement (0 = disable)
; bit 5: horizontal compression (0 = disable)
; bit 6: vertical compression (0 = disable)
; bit 7: 16-bit color mode (0 = disable)
; bit 8: blend (0 = disable)
ld r2, #00001010b
st r2, [PPU_BG1_CTRL]

st r1, [PPU_BG2_CTRL] ; disable bg 2 since bit 3 = 0

st r1, [PPU_FADE_CTRL] ; clear fade control

ld r2, #1
st r2, [PPU_SPRITE_CTRL] ; enable sprites

ld r2, #sprite_data/64
st r2, [PPU_SPRITE_SEGMENT_ADDR]
