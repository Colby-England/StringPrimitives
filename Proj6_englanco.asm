TITLE Project Six     (Proj6_englanco.asm)

; Author: Colby England
; Last Modified: 12/1/2020
; OSU email address: englanco@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  Project 6      Due Date: December 7, 2020
; Description: This program will read 10 signed integers from the user and display the numbers, the sum of the numbers and then rounded average. The numbers will be
;			   read in as strings and converted to ints using low level methods. The program will check and make sure that the numbers aren't too large or small to fit
;			   in 32 bits.

INCLUDE Irvine32.inc

; (insert macro definitions here)

mGetString MACRO prompt, destination, maxSize, bytesRead	; prompt the user for input and store that input in destination.
	; Preserve Registers that will be affected
	PUSH	ECX
	PUSH	EAX
	PUSH	EDX

	; Pormpt the user for input
	CALL	WriteString

	; Set up registers to read the users input
	MOV		EAX, 0
	MOV		ECX, maxSize
	MOV		EDX, destination

	; Read the users input and store bytes read
	CALL	ReadString
	MOV		[bytesRead], EAX

	; Restore Registers
	POP		EDX
	POP		EAX
	POP		ECX

ENDM

mDisplayString MACRO outString
	; Preserve EDX 
	PUSH	EDX

	MOV		EDX, outString
	CALL	WriteString

	; Restore EDX
	POP		EDX
	
ENDM
; (insert constant definitions here)


.data

programName				BYTE	"Low-Level I/O procedures",13,10
						BYTE	"Written by: Colby England",13,10,0
programRules			BYTE	"Provide 10 signed decimal integers. Each numebr should fit in a 32 bit register."
						BYTE	"After the numbers are input I will display a list of the integers, the sum of the integers and a rounded average of the integers",13,10,0
strPrompt				BYTE	"Please enter a signed number: ",0
errorPrompt				BYTE	"You did not enter an integer, or the integer is too large",0
space					BYTE	" ",0
yourNumbers				BYTE	"Your numbers are: ",0
sumNumbers				BYTE	"The sum of your numbers is: ",0
avgNumbers				BYTE	"The rounded average of your numbers is: ",0
farewell				BYTE	"Thanks for playing!!",13,10,0
maxSize					DWORD	12
userString				BYTE	12 DUP(?)
reverseStringFromInt	BYTE	12 DUP(?)
stringFromInt			BYTE	12 DUP(?)
userInt					SDWORD  0
numBytes				DWORD	0
intList					SDWORD	10 DUP(0)
userSum					SDWORD  ?
userAvg					SDWORD  ?


.code
main PROC

	mDisplayString OFFSET programName
	mDisplayString OFFSET programRules


	; set up counter and addres of array to get and store 10 valid numbers from user.
	MOV		ECX, 10
	MOV		EDI, OFFSET intList

	; get 10 valid numbers from the user and store them in the array intList
	_getNumbers:
		PUSH	OFFSET errorPrompt
		PUSH	OFFSET userInt
		PUSH	OFFSET strPrompt
		PUSH	OFFSET userString
		PUSH	maxSize
		PUSH	OFFSET numBytes
		CALL	ReadVal
		MOV		EAX, userInt
		MOV		[EDI], EAX
		MOV		EBX, userSum
		ADD		userSum, EAX
		ADD		EDI, TYPE intList
	LOOP _getNumbers

	; display prompt for displaying the user's numbers
	CALL	CrLf
	mDisplayString OFFSET yourNumbers
	CALL	CrLf

	; set up array address and counter to print numbers
	MOV		ECX, 10
	MOV		EDI, OFFSET intList

	; print the user's number to output
	_printNumbers:
		PUSH	OFFSET stringFromInt
		PUSH	OFFSET reverseStringFromInt
		PUSH	[EDI]
		CALL	WriteVal
		mDisplayString OFFSET space
		ADD		EDI, TYPE intList
	LOOP _printNumbers
	CALL	CrLf


	; Display the sum of the user's numbers
	mDisplayString OFFSET sumNumbers
	PUSH	OFFSET stringFromInt
	PUSH	OFFSET reverseStringFromInt
	PUSH	userSum
	CALL	WriteVal
	CALL	CrLf

	; Calculate average of user numbers
	MOV		EAX, userSum
	CDQ
	MOV		EBX, LENGTHOF intList
	IDIV	EBX
	MOV		userAvg, EAX

	; Display the avg of the user's numbers
	mDisplayString OFFSET avgNumbers
	PUSH	OFFSET stringFromInt
	PUSH	OFFSET reverseStringFromInt
	PUSH	userAvg
	CALL	WriteVal
	CALL	CrLf

	mDisplayString OFFSET farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

ReadVal PROC

	; Preserve the old value of EBP
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ECX
	PUSH	EDI

	_tryAgain:
		; Gather parameters from stack
		MOV		EAX, [EBP + 24]		  ; Store address of userInt in EAX
		MOV		EDX, [EBP + 20]       ; Store address of prompt in EDX
		MOV		ESI, [EBP + 16]		  ; Store address of userString in ESI
		MOV		EBX, [EBP + 12]		  ; Store address of maxSize in EBX
		MOV		EDI, [EBP + 8]		  ; Store address of BytesRead in EDI

		; get String from user
		mGetString EDX, ESI, EBX, EDI


		; validate string
		MOV		ECX, [EDI]			  ; Establish loop counter for user string
		MOV		EDI, EAX			  ; Store address of userInt in EDI
		MOV		EBX, 0
		MOV		[EDI], EBX
		_validate:
			LODSB
			CMP		AL, 43
			JE		_plusSign
			CMP		AL, 45
			JE		_negative
			CMP		AL, 48
			JL		_invalid
			CMP		AL, 57
			JG		_invalid
			JMP		_valid

			_negative:
				PUSH	0  
				DEC		ECX
				JMP		_validate

			_plusSign:
				DEC		ECX
				JMP		_validate

			_valid:
				MOV		EDX, 0
				MOV		DL, AL
				SUB		DL, 48
				MOV		EBX, 10
				MOV		EAX, [EDI]
				PUSH	EDX
				MUL		EBX
				POP		EDX
				ADD		EAX, EDX
				CMP		EAX, 2147483647
				JA		_invalid
				MOV		[EDI], EAX

			DEC		ECX
			CMP		ECX, 0
			JG		_validate
			JMP		_finalCheck

				_invalid:
				MOV		EDX, [EBP + 28]
				MOV		EAX, 0
				MOV		[EDI], EAX
				mDisplayString EDX
				CALL	CrLf
				JMP _tryAgain

		_finalCheck:
			MOV		EAX, EBP
			SUB		EAX, ESP
			CMP		EAX, 8
			JE		_finished

		_makeNegative:
			POP		EBX
			MOV		EAX, [EDI]
			SUB		EBX, EAX
			MOV		[EDI], EBX

		_finished:

	POP		EDI
	POP		ECX
	; Restore EBP & dereference parameters on stack
	POP		EBP
	RET		20
ReadVal ENDP

WriteVal PROC

	; Preserve the old value of EBP
	PUSH	EBP
	MOV		EBP, ESP

	PUSH	ECX
	PUSH	EDI

	MOV		EDI, [EBP + 12]				; Store offset of stringToInt in EDI
	MOV		EAX, [EBP + 8]				; Store integer in EAX
	MOV		ECX, 0						; Set up ecx to count letters in string


	CMP		EAX, 0
	JL		_negative
	JMP		_loop

	;if the value is negative multiply by negative 1
	_negative:
	PUSH	0
	INC		ECX
	MOV		EBX, -1
	MUl		EBX

	_loop:
		INC		ECX
		PUSH	ECX
		MOV		EDX, 0
		MOV		EBX, 10
		DIV		EBX
		ADD		EDX, 48
		MOV		EBX, EAX
		MOV		AL, DL
		CLD
		STOSB
		POP		ECX
		MOV		EAX, EBX
		CMP		EAX, 0
		JE		_finalcheck
		JMP		_loop


	_finalCheck:
		MOV		EAX, EBP
		SUB		EAX, ESP
		CMP		EAX, 8
		JE		_reverse

	_makeNegative:
		POP		EBX
		MOV		AL, 2dh
		STOSB
	_reverse:
		MOV		ESI, [EBP + 12]
		ADD		ESI, ECX
		DEC		ESI
		MOV		EDI, [EBP + 16]
		
		_reverseLoop:
			STD
			LODSB
			CLD
			STOSB
		LOOP	_reverseLoop

		MOV		AL, 00h
		STOSB

	MOV		EDI, [EBP + 16]
	mDisplayString EDI

	POP		EDI
	POP		ECX
	; Restore EBP & dereference parameters on stack
	POP		EBP
	RET		20

WriteVal ENDP

END main
