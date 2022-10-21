;
; CPE_P1.asm
;
; Created: 10/5/2022 4:17:57 PM
;
;
; Notes:
;	GPRs reserved for program execution -- R16, R17
;	GPRs reserved for passing parameters to subroutines or junk stuff thats only needed for a couple lines -- R18, R19
;	GPRs reserved for use in subroutines -- R20, R21, R22, R23

start:
	.DEF C_LEVEL = R16; This register needs to be reserved for holding the current level for the led timing (0-24)
	.DEF ITERATOR = R17; This register is the iterator that the code will use
	.EQU rb = 0xD0; the state that the Right Button is in, see Tony's Buttons Subroutines
	.EQU lb = 0xD1; the state that the Left Button is in, see Tony's Buttons Subroutines

	.EQU WAIT_MULTIPLIER = 10; ~number of ms for each poll/loop of the program
	.EQU DEBOUNCE_WAIT = 5;
	 
    .ORG 0

	LDI R16,HIGH(RAMEND)
	OUT SPH,R16
	LDI R16,LOW(RAMEND)
	OUT SPL,R16


	LDI C_LEVEL, 0; Current num starts at 0 and gets changed by the user pressing the push button 
	ldi R30, 0x00 ;general register to have 0x00
	sts rb,R30 ;set right button 0x00
	sts lb,R30 ;set left button 0x00
	SBI DDRC, 7; Set LED as output
	SBI DDRC, 6; Set SPEAKER as output
	CBI DDRF, 6; Set RIGHT BUTTON as input
	CBI DDRD, 4; Set LEFT BUTTON as input

	;  --- THE MAIN LOOP BEGINS HERE --- ;

BEGIN:		LDI ITERATOR, 192
	LOOP:	MOV R18, ITERATOR
			LSR R18
			LSR R18
			LSR R18
			CPI R18, 0
			BREQ BEGIN ; If Iterator / 8 is 0, Start from the top

			LDI R24, WAIT_MULTIPLIER
			DEC ITERATOR
			CP R18, C_LEVEL
			BRSH T_OFF
			CALL LED_ON
			RJMP BUTTON
	T_OFF:	CALL LED_OFF
	BUTTON:	CALL CHK_R
			CALL CHK_L

			; Check if C_LEVEL IS OUT OF BOUNDS ;
			CPI C_LEVEL, 0xFF
			BREQ T_LOW
			CPI C_LEVEL, 0x17
			BREQ T_HIGH
			RJMP WAIT

	T_LOW:	LDI C_LEVEL, 24
			RJMP BEGIN
	T_HIGH:	LDI C_LEVEL, 0
			RJMP BEGIN

	WAIT:	CALL DELAY_MS
			DEC R24
			BRNE WAIT 
			RJMP LOOP;



	; THIS SUBROUTINE ADDS A DELAY OF ~1ms ;
DELAY_MS:
				LDI R20, 0x26	;Number of iterations for the first loop
	LOOP1_MS:	LDI	R21, 0x43	;Number of iterations for the second loop
	LOOP2_MS:	DEC R21			;Decrement value for second loop
				BRNE LOOP2_MS		;Repeat loop if the value for second loop is not equal to 0
				NOP
				NOP
				NOP
				NOP
				NOP
				NOP
				DEC R20			;Decrement value for first loop
				BRNE LOOP1_MS		;Repeat loop if the value for first loop is not equal to 0
				RET		


PLAY_HIGH:
				LDI R22, 0xFF
	PH_LOOP:	DEC R22
				SBI PORTC, 6
				RCALL WAVE_FORM_DELAY
				CBI PORTC, 6
				RCALL WAVE_FORM_DELAY
				BRNE PH_LOOP
				RET

WAVE_FORM_DELAY:
				LDI R20, 100
	P_LOOP1:	LDI R21, 98
	P_LOOP2:	NOP
				NOP
				NOP
				DEC R21
				BRNE P_LOOP2
				DEC R20
				BRNE P_LOOP1
				RET

	; TOGGLE LED SUBROUTINES ;

LED_ON:			SBI PORTC, 7
				RET
LED_OFF:		CBI PORTC, 7
				RET

CHK_L:		LDS R20, lb
			SBIS PIND, 4
			RJMP RESET_L
			INC R20
			STS lb, R20
			CPI R20, DEBOUNCE_WAIT
			BREQ DEC_LVL
			RET
DEC_LVL:	DEC C_LEVEL
			RET
RESET_L:	LDI R20, 0x00
			STS lb, R20
			RET


CHK_R:		LDS R20, rb
			SBIS PINF, 6
			RJMP RESET_R
			INC R20
			STS rb, R20
			CPI R20, DEBOUNCE_WAIT
			BREQ INC_LVL
			RET
INC_LVL:	INC C_LEVEL
			RET
RESET_R:	LDI R20, 0x00
			STS rb, R20
			RET
