; put the program code in suitable ROM area
.org 0x8000
start:
.include "src/logic/init.asm"

call game_init
loop:
	call game_tick
	jmp loop

.include "src/logic/game.asm"

; configure interrupt vector
; we disabled interrupts, but still need to set the start address
.org 0xfff5
.dw 0 ;break
.dw 0 ;fiq
.dw start ;reset
.dw 0 ;irq 0
.dw 0 ;irq 1
.dw 0 ;irq 2
.dw 0 ;irq 3
.dw 0 ;irq 4
.dw 0 ;irq 5
.dw 0 ;irq 6
.dw 0 ;irq 7

; the graphics data needs to be 64-word aligned
.align_bits 64*16
font:
.binfile "data/font.bin"

.align_bits 64*16
sprite_data:
.binfile "data/sprites.built.bin"
