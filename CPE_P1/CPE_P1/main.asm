;
; CPE_P1.asm
;
; Created: 10/5/2022 4:17:57 PM
; Author : Duncan
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
	CBI DDRA, 6; Set RIGHT BUTTON as input
	CBI DDRD, 4; Set LEFT BUTTON as input


	;  --- THE MAIN LOOP BEGINS HERE --- ;

BEGIN:	

		RJMP BEGIN; Program needs to loop


	; THIS SUBROUTINE ADDS A DELAY OF ~1ms ;
DELAY_MS:



TOGGLE_LED:
			OUT
