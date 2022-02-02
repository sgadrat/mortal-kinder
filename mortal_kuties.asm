.include "src/spg2xx.inc"

;.define VBI_INTERRUPT

.unsp
.low_address 0
.high_address 0x1ffff

.include "src/ram.asm"
.include "src/rom.asm"
