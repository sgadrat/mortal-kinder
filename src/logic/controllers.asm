; Initialize IO to be able to read controllers state
controllers_init:
.scope
	; Set IOC pins configuration
	ld r1, #0b1000100111000000 ; direction - 0 input, 1 output
	st r1, [GPIO_C_DIR]

	st r1, [GPIO_C_ATTRIB] ; attributes - same as direction make output non-inverted and input possibly pulled high/low

	; Debug
	; Copied form Pulkomandy's example, it says it puts IOC8 (CTS A) down to enable controller A
	;  1. Other part of the doc says that controllers are enabled when CTS is high (not down)
	;  2. IOC8 is effectively set high
	;  3. Mysteriously two bits are set down (IOC7 and IOC11)
	; Ideally both controllers should be disabled until the set their RTS bit, and enabled just the time needed to read their input
	ld r1, #0b1111011101111111
	st r1, [GPIO_C_DATA]

	// Enable Uart RX (controller input)
	ld r1, #0xa0
	st r1, [UART_BAUD_LO]
	ld r1, #0xfe
	st r1, [UART_BAUD_HI]

	;NOTE disable interrupts, will check it each frame (certainly a bad idea, but simpler implementation for a first draft
	ld r1, #0b11000000 ; 7: TxEn, 6: RxEn, 5: Mode, 4: MulPro, 3-2: bits per byte, 1: Tx Interrupt Enable, 0: Rx Interrupt Enable
	st r1, [UART_CTRL]

	ld r1, #3
	st r1, [UART_STATUS]

	; UART Tx and Rx in "special" mode
	;NOTE in the example, all values are ORed to ensure consistency, here I hardcode result to avoir reading the instruction set to do an OR
	ld r1, #0x6000 ; previous value | 0x6000 (but no way to know previous value, let's assume zero)
	st r1, [GPIO_C_MASK]

	ld r1, #0b1110100111000000 ; GPIO_C_ATTRIB | 0x6000
	st r1, [GPIO_C_ATTRIB]

	ld r1, #0b1100100111000000 ; GPIO_C_DIR | 0x4000
	st r1, [GPIO_C_DIR]

	; Set controllers state variable to "no button pressed"
	ld r1, #0
	st r1, [controller_a_state]
	st r1, [controller_b_state]

	retf
.ends

; Read message sent by controller A, and update its state variable (to be used by game's logic)
controllers_read_joystick_a:
.scope
	; Check if there is a byte in the RX buffer
	ld r1, [UART_STATUS]
	and r1, #0b00000001
	jz end

		; Read message from the controller
		ld r1, [UART_RXBUF]

		;TODO parse joystic position/color buttons and OK button (and ideally others)
		ld r2, #0x91 ; 0x91 = green button
		cmp r2, r1
		jz right_pressed
		ld r2, #0x90 ; 0x90 = color button released
		cmp r2, r1
		jz right_released

			unhandled_input:
				retf

			right_pressed:
				ld r1, [controller_a_state]
				ld r2, #INPUT_RIGHT
				or r1, r2
				st r1, [controller_a_state]

				retf

			right_released:
				ld r1, [controller_a_state]
				ld r2, #0xefff ; NOT INPUT_RIGHT
				and r1, r2
				st r1, [controller_a_state]

				retf

	end:
	retf
.ends
