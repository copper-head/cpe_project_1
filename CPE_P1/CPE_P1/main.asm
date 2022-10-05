;
; CPE_P1.asm
;
; Created: 10/5/2022 4:17:57 PM
; Author : Duncan
;


; Replace with your application code
start:
    .ORG 0
	SBI DDRC, 7; Set LED as output
	SBI DDRC, 6; Set SPEAKER as output
	CBI DDRA, 6; Set RIGHT BUTTON as input
	CBI DDRD, 4; Set LEFT BUTTON as input

	NOP
	NOP