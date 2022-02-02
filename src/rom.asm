; put the program code in suitable ROM area
.org 0x8000

start:
.include "src/logic/init.asm"

call game_init

loop:
.scope
	call game_tick


	wait_loop:
		ld r1, [PPU_IRQ_STATUS]
		and r1, #0b0000_0000_0000_0001 ; bit 2: DMA, bit 1: VDO, bit 0: blanking
		jz wait_loop
	st r1, [PPU_IRQ_STATUS] ; Clear VBI flag (note: r1's value is ensured to be "0x0001" here)

	jmp loop
.ends

.include "src/logic/game.asm"

; configure interrupt vector
; we disabled interrupts, but still need to set the start address
.org 0xfff5
.dw 0 ;break
.dw 0 ;fiq
.dw start ;reset
.dw 0 ;irq 0 ; PPU vblank/vpos/dma
.dw 0 ;irq 1 ; Audio
.dw 0 ;irq 2 ; TimerA TimerB
.dw 0 ;irq 3 ; UART, ADC, SPI
.dw 0 ;irq 4 ; Audio
.dw 0 ;irq 5 ; extint1, extint2
.dw 0 ;irq 6 ; 1024Hz, 2048HZ, 4096HZ
.dw 0 ;irq 7 ; TMB1, TMB2, 4Hz, key change

; the graphics data needs to be 64-word aligned
.align_bits 64*16
font:
.binfile "data/font.bin"

.align_bits 64*16
sprite_data:
.binfile "data/sprites.built.bin"
