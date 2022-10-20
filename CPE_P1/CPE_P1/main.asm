;
; CPE_P1.asm
;
; Created: 10/5/2022 4:17:57 PM
; Author : Duncan, Jorge
;
;
; Notes:
;	GPRs reserved for program execution -- R16, R17
;	GPRs reserved for passing parameters to subroutines or junk stuff thats only needed for a couple lines -- R18, R19
;	GPRs reserved for use in subroutines -- R20, R21, R22, R23

start:
	.DEF C_LEVEL = R16; This register needs to be reserved for holding the current level for the led timing (0-24)
	.DEF ITERATOR = R17; This register is the iterator that the code will use

	.EQU WAIT_MULTIPLIER = 10; ~number of ms for each poll/loop of the program
	 
    .ORG 0
	LDI C_LEVEL, 25; Current num starts at 0 and gets changed by the user pressing the push button 

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
			BRLO T_OFF
			CALL LED_ON
			RJMP WAIT	
	T_OFF:	CALL LED_OFF
	WAIT:	CALL DELAY_MS
			DEC R24
			BRNE WAIT 
			RJMP LOOP;



	; THIS SUBROUTINE ADDS A DELAY OF ~1ms ;
DELAY_MS:
				LDI R20, 0x26	;Number of iterations for the first loop
	LOOP1_MS:	LDI	R21, 0x43	;Number of iterations for the second loop
	LOOP2_MS:	DEC R21			;Decrement value for second loop
				BRNE LOOP2_MS	;Repeat loop if the value for second loop is not equal to 0
				NOP				; ]
				NOP				; ]
				NOP				; ] - NOP's used to get closer to desired time
				NOP				; ]
				NOP				; ]
				NOP				; ]
				DEC R20			;Decrement value for first loop
				BRNE LOOP1_MS	;Repeat loop if the value for first loop is not equal to 0
				RET				;Return to main program		



	; TOGGLE LED SUBROUTINE ;
TOGGLE_LED:
				SBIS PORTC, 7
				RJMP LED_ON
				SBIC PORTC, 7
				RJMP LED_OFF
				RET

LED_ON:			SBI PORTC, 7
				RET
LED_OFF:		CBI PORTC, 7
				RET
