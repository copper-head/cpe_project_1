;
; AssemblerApplication1.asm
;
; Created: 10/18/2022 5:22:48 PM
; Author : Duncan, Jorge, Tony
;


; Replace with your application code
start:
	.DEF CURRENT_NUM = R16; This register needs to be reserved for holding the current level for the led timing (0-24)
	.DEF NUM_COUNTER = R17; This register is the iterator that the code will use
	.DEF treg = R30; Tony's Register. going to be used to access data space and modify flags stored in data space
	.DEF rb = 0xD0; the state that the Right Button is in, see Tony's Buttons Subroutines
	.DEF lb = 0xD1; the state that the Left Button is in, see Tony's Buttons Subroutines
	 
    .ORG 0
	LDI CURRENT_NUM, 0; Current num starts at 0 and gets changed by the user pressing the push button
	LDI NUM_COUNTER, 24; NUM_COUNTER starts at 24 and decrements 
	ldi treg,0x00 ;set treg to 0x00
	sts rb,treg ;set right button to treg, aka 0x00
	sts lb,treg ;set left button to treg, aka 0x00
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
				LDI R20, 0x27	;Number of iterations for the first loop
	LOOP1:		LDI	R21, 0x43	;Number of iterations for the second loop
	LOOP2:		DEC R21			;Decrement value for second loop
				BRNE LOOP2		;Repeat loop if the value for second loop is not equal to 0
				DEC R20			;Decrement value for first loop
				BRNE LOOP1		;Repeat loop if the value for first loop is not equal to 0
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
	; Tony's Buttons Subroutine ;
	/*psudocode
	when button is pressed
	check how many times it has been pressed for
	if 4, 5, 6, 7, do nothing
	if 0, 1, 2, or 3,
		increment
		if hits 4
			increment CURRENT_NUM

	when button is NOT pressed
	check how many times it has been pressed for
	if 0, 1, 2, 3
		do nothing
	if 4, 5, 6, 7
		increment
		if hits 8
			set back to 0
	*/
	// 0 1 2 3 4 5 6 7 
	// X 1 2 3 y 1 2 3
clb:
	sbis PIND,6 ;skip if button pressed
		rjmp lbnot
	sbrs R30,2 ;skip if >=4
		ret ;return because we dont want to hold the button down for too long
	;lb = 0|1|2|3
	lds R30,lb ;set R30 to lb
	inc R30 ;treg = 1|2|3|4
	sbrc R30,2 ;skip if we did NOT hit 4
		inc COUNTER_NUM ;if the button has been held for 4 counts, increment the light lvl
	sts lb, R30 ;store lb+1 to lb, lb = 1|2|3|4
	ret ;done with this iteration of checking while the button is down

lbnot: 
	ldi R31,0b00000000 ;set to 0
	lds R30,lb ;if lb=0
	cpse R30,R31 ;compare ld and 0, skip if equal
		ret ;if ld = 0
	lds R30,lb ;set R30 into lb, 4|5|6|7
	inc R30 ; = 5|6|7|8
	sbrc R30,8 ;skip if we did NOT hit 8
		ldi R30,0x00 ;reset the lb/treg count
	sts lb,R30 ;store R30 into lb, =5|6|7|0
	ret ;done with this iteration of checking if the buttin is up