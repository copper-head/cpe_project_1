;
; CPE_P1.asm
;
; Created: 10/5/2022 4:17:57 PM
; Author : Duncan, Jorge
;
;
; Notes:
;	GPRs reserved for program execution -- R16, R17
;	GPRs reserved for passing parameters to subroutines -- R18, R19
;	GPRs reserved for use in subroutines -- R20, R21, R22, R23

; Replace with your application code
start:
	.DEF CURRENT_NUM = R16; This register needs to be reserved for holding the current level for the led timing (0-24)
	.DEF NUM_COUNTER = R17; This register is the iterator that the code will use
	 
    .ORG 0
	LDI CURRENT_NUM, 0; Current num starts at 0 and gets changed by the user pressing the push button
	LDI NUM_COUNTER, 24; NUM_COUNTER starts at 24 and decrements 

	SBI DDRC, 7; Set LED as output
	SBI DDRC, 6; Set SPEAKER as output
	CBI DDRF, 6; Set RIGHT BUTTON as input
	CBI DDRD, 4; Set LEFT BUTTON as input


	;  --- THE MAIN LOOP BEGINS HERE --- ;

BEGIN:		LDI R24, 0x10
	LOOP:	DEC R24
			RCALL DELAY_MS
			BRNE LOOP
			RCALL TOGGLE_LED
			RJMP BEGIN; Program needs to loop


	; THIS SUBROUTINE ADDS A DELAY OF ~1ms ;
DELAY_MS:
				LDI R20, 0x26	;Number of iterations for the first loop
	LOOP1_MS:	LDI	R21, 0x43	;Number of iterations for the second loop
	LOOP2_MS:	DEC R21			;Decrement value for second loop
				BRNE LOOP2_D	;Repeat loop if the value for second loop is not equal to 0
				NOP				; ]
				NOP				; ]
				NOP				; ] - NOP's used to get closer to desired time
				NOP				; ]
				NOP				; ]
				NOP				; ]
				DEC R20			;Decrement value for first loop
				BRNE LOOP1_D		;Repeat loop if the value for first loop is not equal to 0
				RET				;Return to main program



	; TOGGLE LED SUBROUTINE ;
TOGGLE_LED:
				SBIS PORTC, 7
				RJMP TOGGLE_ON
				SBIC PORTC, 7
				RJMP TOGGLE_OFF
				RET

	TOGGLE_ON:		SBI PORTC, 7
					RET
	TOGGLE_OFF:		CBI PORTC, 7
					RET
