; First version of MultiMode 3 chip port to 12f629     1.0 - 19/08/2012
; 
; By Tulchan Gamps
; Many thanks to garyOPA for his port of the classic 4 wires modchip.
; Whithout him, this wouldn't have been possible.
; Many thanks to Hanimar for his PIC Disassembler.
; EUR version
;
;
; Don't refer to the following pinout, but to multimode 3 installation schematics.
; Names of variables & ports may be wrong. 
;                      _______  _________
;                      |       \/       |
;              	 Vdd --+ 1 <<      >> 8 +-- Vss
;  Memory Card         |                |
;  Connector Pin 3   --+ 2 <<      >> 7 +-- signal from door (gpio0)
;                      |                |
;           /        --+ 3         >> 6 +-- data stream (gpio1)
;                      |                |
; (gpio3) Reset Line --+ 4 <<      >> 5 +-- gate output (grio2)
;                      |                |
;                      +----------------+

	list    p=12f629
	include "p12f629.inc"
	radix   dec
	errorlevel  -302              ; suppress message 302 from list file;
	errorlevel  -224              ; suppress message 224 from list file ("Use of this instruction is not recommended.")

	__FUSES _MCLRE_OFF & _CP_OFF & _WDT_OFF &  _INTRC_OSC_NOCLKOUT

	cblock	0x27	;
		i
		j
		k
		x
		y
		xmit
		index
		loop1
		smflag
		reflag
		VAR_11
		VAR_12
		VAR_13
		VAR_14
		VAR_15
		VAR_16
		VAR_17
		VAR_18
		VAR_19
		VAR_1A
		VAR_1B
		m
		VAR_1D
		VAR_1E
		VAR_1F
	endc

#define memline	GPIO,4
#define	reset	GPIO,3
#define gate    GPIO,2
#define door    GPIO,0
#define stealthbit  smflag,0	; hope these work too....
#define resetbit    reflag,0    ; hope these work too....	

;***** VARIABLE DEFINITIONS
;
w_temp        EQU     0x20        ; variable used for context saving 
status_temp   EQU     0x21        ; variable used for context saving
;##############################################

	org	0x000
	goto	main
;
; (12F629) = Interrupt Code (not used)
;
	ORG     0x004             ; interrupt vector location
	movwf   w_temp            ; save off current W register contents
	movf	STATUS,w          ; move status register into W register
	movwf	status_temp       ; save off contents of STATUS register
;
; isr code can go here or be located as a call subroutine elsewhere
;
	movf    status_temp,w     ; retrieve copy of STATUS register
	movwf	STATUS            ; restore pre-isr STATUS register contents
	swapf   w_temp,f
	swapf   w_temp,w          ; restore pre-isr W register contents
	retfie                    ; return from interrupt
;
; these first 4 instructions are not required if the internal oscillator is not used
;

main
		bsf	STATUS,RP0	  ; bank 1
		movlw	b'10000110'       ; Disable T0CKI on Pin 5
		movwf	OPTION_REG	  ; Set it!
		call    0x3FF             ; retrieve factory calibration value
		movwf   OSCCAL            ; update register with factory cal value 
		bcf     STATUS,RP0        ; set file register bank to 0
		clrf	GPIO		  ; Clear all the pins

;
; (12F629) = Goto to main PSX code
;
	goto    start           ;Jump into main code segment

	dt	'M','u','l','t','i','m','o','d','e','3','.','0','0',' '

SUB_016
	movlw	3
	movwf	reflag
	movlw	255	
	movwf	smflag
	retlw	0

dly50
	movlw	50

dly_ms
lab_dly_ms
	movwf	x
dy_0
	movlw	170	
	movwf	y
dy_1
	btfss	memline	
	clrf	smflag

	nop		
	decfsz	y,F
	goto	dy_1

	btfss	reset
	clrf	loop1

	decfsz	VAR_17,F
	goto	LAB_02D

	movlw	250	
	movwf	VAR_17
	decfsz	VAR_18,F
	goto	LAB_02D

	clrf	VAR_19
LAB_02D
	decfsz	x,F	
	goto	dy_0

	retlw	0

SUB_030
	btfss	VAR_1A	,0
	goto	LAB_038

	nop	
	movlw	b'11111001'
	tris	GPIO
	movlw	b'11111001'
	movwf	GPIO
	retlw	0
LAB_038
	movlw	b'11111101'
	tris	GPIO
	movlw	b'11111001'
	movwf	GPIO
	retlw	0

SUB_03D
	movlw	b'11111111'
	tris	GPIO
	movlw	b'11111111'	
	movwf	GPIO
	retlw	0

SUB_042
	btfss	VAR_1A	,0	
	goto	LAB_04B	

	nop			;
	movlw	b'11111001'
	tris	GPIO
	movlw	b'11111001'
	movwf	GPIO
	movlw	4
	goto	lab_dly_ms
LAB_04B
	movlw	b'11111101'
	tris	GPIO
	movlw	b'11111001'
	movwf	GPIO
	movlw	4
	goto	lab_dly_ms

SUB_051
	btfss	VAR_1A	,0
	goto	LAB_05A	

	nop			
	movlw	b'11111011'
	tris	GPIO		
	movlw	b'11111001'
	movwf	GPIO		
	movlw	4
	goto	lab_dly_ms
LAB_05A
	movlw	b'11111101'
	tris	GPIO
	movlw	4
	movwf	x		
LAB_05E
	movlw	109
	movwf	y		
LAB_060
	movlw	251
	btfss	gate	
	movlw	b'11111001'

	movwf	GPIO		
	btfss	memline	
	clrf	smflag		

	decfsz	y,F
	goto	LAB_060	

	btfss	reset
	clrf	loop1

	movlw	251	
	btfss	gate	
	movlw	b'11111001'

	movwf	GPIO
	decfsz	x,F
	goto	LAB_05E	

	retlw	0

SUB_071
	clrf	index	
	movlw	4
	movwf	j	
	btfsc	VAR_1E,0
	goto	LAB_083	

	call	SUB_016	
	movlw	18
	movwf	m
LAB_079
	movlw	4
	call	dly_ms
	decfsz	reflag,F
	goto	LAB_080	

	btfsc	stealthbit
	goto	LAB_0AB	

	call	SUB_016	
LAB_080
	decfsz	m,F
	goto	LAB_079	

	goto	LAB_087	
LAB_083
	movlw	72
	call	dly_ms
	movlw	255	
	movwf	reflag
LAB_087
	movf	index,W	
	call	lines	
	movwf	xmit		
	comf	xmit,F	
	movlw	9
	movwf	k		
	goto	LAB_091		
LAB_08E
	rrf		xmit,F	
	btfss	STATUS,0	
	goto	LAB_093		

LAB_091
	call	SUB_051	
	goto	LAB_095	
LAB_093
	call	SUB_042	
	nop		
LAB_095
	decfsz	reflag,F
	goto	LAB_09A	

	btfsc	stealthbit	
	goto	LAB_0AB		

	call	SUB_016		
LAB_09A
	decfsz	k,F	
	goto	LAB_08E		

	call	SUB_042		
	decfsz	reflag,F	
	goto	LAB_0A2		

	btfsc	stealthbit	
	goto	LAB_0AB		

	call	SUB_016
LAB_0A2
	call	SUB_042	
	decfsz	reflag,F
	goto	LAB_0A8	

	btfsc	stealthbit
	goto	LAB_0AB	

	call	SUB_016
LAB_0A8
	incf	index,F
	decfsz	j,F
	goto	LAB_087

LAB_0AB
	retlw	0

lines
	addwf	PCL,F
	dt      'S','C','E','A' ;European/PAL
	
	
start
	movlw	b'10000010'
	option			
	movlw	100	
	call	dly_ms		
	movlw	b'11111111'	
	tris	GPIO		
	movlw	1
	movwf	VAR_11		
LAB_0B9
	movlw	200	
	call	dly_ms
	movlw	255	
	movwf	VAR_17		
	movwf	VAR_18		
	movwf	VAR_19		
	movwf	VAR_15		
	movlw	10
	movwf	m		
LAB_0C2
	movlw	100
	call	dly_ms
	call	SUB_03D	
	btfsc	reset
	goto	LAB_0D6	

	movlw	100
	call	dly_ms
	call	SUB_030
	decfsz	m,F	
	goto	LAB_0C2	

	call	SUB_03D	
LAB_0CD
	btfss	reset
	goto	LAB_0CD	

	incf	VAR_11,F
	movlw	5	
	subwf	VAR_11,W
	btfss	STATUS,0
	goto	LAB_0D6

	movlw	1
	movwf	VAR_11
LAB_0D6
	movlw	255	
	movwf	loop1
	movlw	30
	movwf	i
LAB_0DA
	call	dly50
	btfss	loop1,0
	goto	LAB_0B9	

	decfsz	i,F
	goto	LAB_0DA

	movlw	255
	movwf	VAR_1A
	movlw	25
	movwf	VAR_1B
LAB_0E3
	movlw	20
	movwf	m
LAB_0E5
	btfsc	gate
	goto	LAB_0EA	

	decfsz	m,F
	goto	LAB_0E5

	goto	LAB_0F9
LAB_0EA
	movlw	20
	movwf	m
LAB_0EC
	btfss	gate
	goto	LAB_0F1

	decfsz	m,F
	goto	LAB_0EC	

	goto	LAB_0F9	
LAB_0F1
	decfsz	VAR_1B,F
	goto	LAB_0E3

	clrf	VAR_1A	
	movlw	b'11111001'
	movwf	GPIO
	movlw	b'11111101'
	tris	GPIO
	goto	LAB_0FD
LAB_0F9
	movlw	b'11111001'
	movwf	GPIO
	movlw	b'11111001'
	tris	GPIO
LAB_0FD
	movlw	255	
	movwf	loop1
	movlw	7
	movwf	i
	btfsc	door
	goto	LAB_1E6	

LAB_103
	call	dly50
	btfss	loop1,0	
	goto	LAB_0B9	

	decfsz	i,F
	goto	LAB_103	

LAB_108
	movf	VAR_11,W
	movwf	VAR_1F		
	decf	VAR_1F,F
	btfsc	STATUS,2
	goto	LAB_121	

	decf	VAR_1F,F
	btfsc	STATUS,2
	goto	LAB_125	

	decf	VAR_1F,F
	btfsc	STATUS,2
	goto	LAB_11B	

	decf	VAR_1F,F
	btfsc	STATUS,2
	goto	LAB_116	

LAB_116
	movlw	b'11111111'
	tris	GPIO
LAB_118
	btfss	reset
	goto	LAB_0B9	

	goto	LAB_118	
LAB_11B
	movlw	255
	movwf	VAR_1E
LAB_11D
	call	SUB_071
	btfss	loop1,0
	goto	LAB_0B9	

	goto	LAB_11D	
LAB_121
	btfss	VAR_1A,0
	goto	LAB_129	

	clrf	VAR_15
	goto	LAB_145
LAB_125
	btfsc	VAR_1A,0
	goto	LAB_145

	incf	VAR_11,F
	goto	LAB_108
LAB_129
	movlw	34
	movwf	VAR_12
	goto	LAB_12E
LAB_12C
	movlw	24
	movwf	VAR_12
LAB_12E
	call	SUB_030
LAB_12F
	btfss	reset
	goto	LAB_0B9

	btfsc	door
	goto	LAB_12F	

	movlw	255
	movwf	VAR_1E
LAB_135
	call	SUB_071
	btfss	loop1,0
	goto	LAB_0B9	

	btfsc	door
	goto	LAB_12C	

	decfsz	VAR_12,F
	goto	LAB_135	

	call	SUB_030
	clrf	VAR_1E
LAB_13E
	call	SUB_071
	call	SUB_030	
	btfss	loop1,0	
	goto	LAB_0B9

	btfsc	door
	goto	LAB_12C

	goto	LAB_13E
LAB_145
	movlw	255
	movwf	VAR_1E
	call	SUB_071
	btfss	loop1,0
	goto	LAB_0B9	

	btfss	memline
	goto	LAB_145	

	movlw	255
	movwf	VAR_14
	movwf	VAR_16
	movwf	VAR_19
	movlw	100	
	movwf	VAR_18
	movlw	250	
	movwf	VAR_17
LAB_154
	btfss	reset
	goto	LAB_0B9	

	btfsc	door
	goto	LAB_145

	btfss	memline
	goto	LAB_190

	goto	LAB_154
LAB_15B
	call	SUB_03D
	movlw	255
	movwf	VAR_13
LAB_15E
	movlw	200
	movwf	m
LAB_160
	movlw	14
	call	dly_ms
	btfss	loop1,0
	goto	LAB_0B9

	btfsc	door
	goto	LAB_1DC

	btfss	memline
	goto	LAB_16C

	decfsz	m,F
	goto	LAB_160	

	clrf	VAR_13
	goto	LAB_15E
LAB_16C
	call	SUB_030
	btfss	VAR_14,0
	goto	LAB_1A0

	movlw	13
	movwf	VAR_1D
LAB_171
	movlw	10
	call	dly_ms
	btfss	loop1,0
	goto	LAB_0B9

	btfsc	door
	goto	LAB_1DC

	btfsc	memline
	goto	LAB_18D

	decfsz	VAR_1D,F
	goto	LAB_171	

	clrf	VAR_14
	btfsc	VAR_13,0
	goto	LAB_1A0	

	btfsc	VAR_16,0
	goto	LAB_1C5

	movlw	25
	movwf	VAR_1D
LAB_182
	movlw	10
	call	dly_ms
	btfss	loop1,0
	goto	LAB_0B9

	btfsc	door
	goto	LAB_1DC

	btfsc	memline
	goto	LAB_15B

	decfsz	VAR_1D,F
	goto	LAB_182

	goto	LAB_1C5
LAB_18D
	call	SUB_03D
	clrf	VAR_16
	goto	LAB_160	
LAB_190
	call	SUB_030	
	movlw	75
	movwf	m
LAB_193
	movlw	10
	call	dly_ms
	btfss	loop1,0	
	goto	LAB_0B9	

	btfsc	door
	goto	LAB_1DC

	btfsc	memline
	goto	LAB_19E	

	decfsz	m,F
	goto	LAB_193

	goto	LAB_1A0	
LAB_19E
	clrf	VAR_14
	goto	LAB_15B	
LAB_1A0
	call	SUB_030	
	movlw	6
	movwf	i
LAB_1A3
	movlw	25
	movwf	m
LAB_1A5
	movlw	10
	call	dly_ms
	btfss	loop1,0	
	goto	LAB_0B9

	btfsc	door
	goto	LAB_1DC

	btfsc	memline
	goto	LAB_15B

	decfsz	m,F
	goto	LAB_1A5

	decfsz	i,F	
	goto	LAB_1A3

	clrf	VAR_14
	call	SUB_030
	movlw	11
	movwf	i
LAB_1B5
	movlw	25
	movwf	m
LAB_1B7
	movlw	10
	call	dly_ms
	btfss	loop1,0
	goto	LAB_0B9

	btfsc	door
	goto	LAB_1DC

	btfsc	memline
	goto	LAB_15B

	decfsz	m,F	;
	goto	LAB_1B7

	decfsz	i,F	
	goto	LAB_1B5

	movlw	3
	goto	LAB_1C8	
LAB_1C5
	movlw	4
	goto	LAB_1C8	
LAB_1C7
	movlw	24
LAB_1C8
	movwf	VAR_12
	clrf	VAR_14	
	btfss	VAR_15,0
	goto	LAB_1CE	

	btfss	VAR_19,0
	goto	LAB_1A0	

LAB_1CE
	btfss	loop1,0
	goto	LAB_0B9	

	btfsc	door
	goto	LAB_1DC	

	btfsc	memline
	goto	LAB_1D7

	call	SUB_071	
	decfsz	VAR_12,F
	goto	LAB_1CE	

LAB_1D7
	movlw	68	
	movwf	VAR_18	
	movlw	250	
	movwf	VAR_17	
	goto	LAB_1A0	
LAB_1DC
	call	SUB_030	
	movlw	255
	call	dly_ms
	movlw	255
	movwf	VAR_19	
LAB_1E1
	btfss	reset
	goto	LAB_0B9	

	btfsc	door
	goto	LAB_1E1	

	goto	LAB_1C7
LAB_1E6
	call	SUB_071
	goto	LAB_1E6
	
;
; (12F629) = initialize eeprom locations
;
		ORG	0x2100
		DE	0x00, 0x01, 0x02, 0x03	
;
; (Note: do NOT overwrite factory-programmed location 0x1FF/0x3FF !!)
;
;
	end
