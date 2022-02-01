.include "src/spg2xx.inc"
.define color(r,g,b) ((r << 10) | (g << 5) | (b << 0))

.unsp
.low_address 0
.high_address 0x1ffff

.include "src/ram.asm"
.include "src/rom.asm"
