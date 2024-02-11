audio_init:
.scope
	; Configure GPIO (turn on V.Smile audio output)
	ld r2, #0b0000_0000_0110_000
	ld r3, #0b1111_1111_1001_111

	ld r1, [GPIO_C_DATA]
	and r1, r3
	st r1, [GPIO_C_DATA]

	ld r1, [GPIO_C_DIR]
	or r1, r2
	st r1, [GPIO_C_DIR]

	ld r1, [GPIO_C_ATTRIB]
	or r1, r2
	st r1, [GPIO_C_ATTRIB]

	ld r1, #0
	st r1, [GPIO_C_MASK]

	; Initialize SPU, highest volume level, interpolation off
	; uuuuuu_n_l_vv_s_i_p_uu
	; u: unused
	; n: No Interpolation
	; l: LP Enable
	; v: High Volume
	; s: SOF
	; i: Init
	ld r1, #0b0000000_1_1_10_0_1_0_00
	st r1, [SPU_CTRL]

	; Main volume
	; uuuuuuuuu_vvvvvvv
	;  u: unused
	;  v: volume
	ld r1, #0b000000000_1111111
	st r1, [SPU_MAIN_VOLUME]

	retf
.ends

; Play a music on a channel
;  r1 - music index
;  r2 - channel index ;TODO (hardcoded to zero for now)
play_music:
.scope
	; Channel specific configuration
	;{
		; Get music address in r2,ds
		and sr, #0b000000_1_1_1_1_111111 ; DS N Z S C CS
		or sr, #(audio_musics_lsw >> 6) & 0b111111_0_0_0_0_000000 ;TODO add music index to audio_musics_lsw
		ld r4, #audio_musics_lsw & 0xffff ;TODO add music index to audio_musics_lsw
		ld r2, D:[r4]

		and sr, #0b000000_1_1_1_1_111111 ; DS N Z S C CS
		or sr, #(audio_musics_msw >> 6) & 0b111111_0_0_0_0_000000 ;TODO add music index to audio_musics_msw
		ld r3, #audio_musics_msw & 0xffff ;TODO add music index to audio_musics_msw
		ld r1, D:[r3]
		ld r3, #1024
		mul.us r1, r3
		and sr, #0b000000_1_1_1_1_111111 ; DS N Z S C CS
		or sr, r3

		; Set phase of sample
		ld r1, D:[r2++]
		st r1, [SPU_CH_PHASE_HI(0)]
		ld r1, D:[r2++]
		st r1, [SPU_CH_PHASE_LO(0)]

		ld r1, #0
		st r1, [SPU_CH_PHASE_ACCUM_HI(0)]
		st r1, [SPU_CH_PHASE_ACCUM_LO(0)]

		; Set address and loop point
		ld r1, D:[r2++]
		st r1, [SPU_CH_WAVE_ADDR(0)]

		ld r1, D:[r2++]
		st r1, [SPU_CH_LOOP_ADDR(0)]

		; Channel control
		; ff_tt_llllll_ssssss
		;  u: unused
		;  f: sample format (0=8-bit, 1=16-bit, 2=adpcm, 3=???)
		;  t: Tone Mode (0=software PCM, 1=one shot PCM, 2=Manual loop PCM, 3=???)
		;  l: Loop address segment
		;  s: Sample address segment
		ld r1, D:[r2++]
		st r1, [SPU_CH_MODE(0)]

		; Reset channel wave data to zero point
		ld r1, D:[r2]
		st r1, [SPU_CH_WAVE_DATA_PREV(0)]
		st r1, [SPU_CH_WAVE_DATA(0)]

		; Volume
		; uu_ppppppp_vvvvvvv
		;  u: unused
		;  p: panning (To be determined: is it "0 = full left, 127 = full right"?)
		;  v: volume
		ld r1, #0b00_1000000_1111111
		st r1, [SPU_CH_PAN_VOL(0)]

		; Set envelope volume to full
		; ccccccccc_ddddddd
		;  c: Envelope count
		;  d: Direct data
		ld r1, #0b000000000_1111111
		st r1, [SPU_CH_ENVELOPE_DATA(0)]

		; Set envelope loop (is that value means no loop as we use direct data?)
		; rrrrrrr_aaaaaaaaa
		;  r: Rampdown offset
		;  a: Envelope address offset
		ld r1, #0b0000000_000000000
		st r1, [SPU_CH_ENVELOPE_LOOP_CTRL(0)]
	;}

	; Changes in global audio configuration
	;{
		; Disable rampdown, 1 bit per channel
		ld r2, #0b1111_1111_1111_1110
		ld r1, [SPU_ENV_RAMP_DOWN]
		and r1, r2
		st r1, [SPU_ENV_RAMP_DOWN]

		; Channel envelope repeat, 1 bit per channel
		; Actually we never use enveloppe repeat, so there is no real need to reset that bit (it will never be 1)
		;ld r2, #0b1111_1111_1111_1110
		;ld r1, [SPU_CHANNEL_REPEAT]
		;and r1, r2
		;st r1, [SPU_CHANNEL_REPEAT]

		; Channel envelope mode, 1 bit per channel
		ld r2, #0b0000_0000_0000_0001
		ld r1, [SPU_CHANNEL_ENV_MODE]
		or r1, r2
		st r1, [SPU_CHANNEL_ENV_MODE]

		; Channel stop, 1 bit per channel
		ld r2, #0b0000_0000_0000_0001
		ld r1, [SPU_CHANNEL_STOP]
		or r1, r2
		st r1, [SPU_CHANNEL_STOP]

		; Channel enable, 1 bit per channel
		ld r2, #0b0000_0000_0000_0001
		ld r1, [SPU_CHANNEL_ENABLE]
		or r1, r2
		st r1, [SPU_CHANNEL_ENABLE]
	;}

	retf
.ends
