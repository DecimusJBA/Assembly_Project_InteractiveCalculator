;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Computer Science Assembly Language 							   ;;
;; Program: Interactive Integer Calculator						   ;;
;; Requires: Arrow Keys to navigate the calculator.                ;;
;;			 Display Limit is 15 characters.					   ;;
;; Instructions: Use Arrow keys to select numbers and press enter  ;;
;;				 per each selection.                               ;;
;;				 select first number.							   ;;
;;				 select operator.								   ;;
;;				 select equal sign.                                ;;
;;				 The solution will be display in the message box.  ;;
;;				 IF you select 'C', it will clear the message box. ;;
;;				 and allow you to perform another calculation.	   ;;
;; QUIT: press Esc key, this will terminate the program.           ;;
;; Limitations: Cannot handle negative or multiple line            ;;
;; calculations.												   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INCLUDE Irvine32.inc
.data
;---Control Characters---;
NULL	EQU 00h				;Zero Value.
LF		EQU 0ah             ;Line Feed.
CR		EQU 0dh				;Carriage Return.
SPC 	EQU 20h				;Space.
ECP		EQU 1Bh				;esc key.

;---Arrow Keys---;
LA		EQU 4Bh				;Left  Arrow.
RA		EQU	4Dh				;Right Arrow.
UA		EQU	48h				;Up    Arrow.
DA		EQU 50h				;Down  Arrow.
CLR		=   'C'				;'C' for clear screen.
;---Bounds---;
MAX_R = 16					;cannot be greater than 18 (far right digit on cal).
MAX_L = 4					;cannot be less than 4 (far left digit on cal).
MAX_U = 5					;cannot be less than 5 (far up digit on cal).
MAX_D = 11					;cannot be greater than 11 (far down digit on cal).
aLimit		EQU  	15		;Limit Length of Answer to display size.

;---Storage for Numerical Values---;
TEN			dword	10		;used in ATOI, ITOA procedures.						
ANS_ROW		byte	 2		;Answer Row.
ANS_COL		byte    18		;Answer Column.

;---CALCULATOR ON CONSOLE---;
calStr	    byte " ___________________  ",CR,LF       ;ROW 0, 22 length
			byte "|  _______________  | ",CR,LF       ;ROW 1, 22 length
			byte "| |               | | ",CR,LF       ;ROW 2, 22 length
			byte "| |_______________| | ",CR,LF       ;ROW 3, 22 length
			byte "|  ___ ___ ___ ___  | ",CR,LF       ;ROW 4, 22 length
			byte "| | 7 | 8 | 9 | + | | ",CR,LF       ;ROW 5, 22 length (7)= 4pos, (8)= 8pos, (9)= 12pos, (+)= 16pos
			byte "| |___|___|___|___| | ",CR,LF       ;ROW 6, 22 length
			byte "| | 4 | 5 | 6 | - | | ",CR,LF       ;ROW 7, 22 length
			byte "| |___|___|___|___| | ",CR,LF       ;ROW 8, 22 length
			byte "| | 1 | 2 | 3 | * | | ",CR,LF       ;ROW 9, 22 length
			byte "| |___|___|___|___| | ",CR,LF       ;ROW 10, 22 length
			byte "| | C | 0 | = | / | | ",CR,LF		  ;ROW 11, 22 length
			byte "| |___|___|___|___| | ",CR,LF		  ;ROW 12, 22 length
			byte "|___________________| ",CR,LF, NULL ;ROW 13, 22 length

;---Strings---;
fline       byte  " +==========================================================+", CR, LF, NULL
nline		byte   CR, LF, NULL						  ;new line string.
Msg0	    byte  " |\        Interactive Calculator Program                  /|", CR, LF, NULL
Msg1		byte  " |/        CREATED BY: bdahmerj                            \|", CR, LF, NULL
Msg2   		byte  " +==========================================================+", CR, LF, NULL

;---Storage For Variables---;
Ary			byte  100 dup(' ')				    ;size of the array.(might be enough).
Bry			byte  17  dup(CR),NULL				;size of the array.(might be enough).
AryLen		byte  NULL							;holds the size of the array (Ary).
BryLen		byte  NULL							;holds the size of the array (Bry).
valA		dword NULL							;default is 0.
valB		dword NULL							;default is 0.
valC		dword NULL							;default is 0.
equalSign   byte '='							;equal sign.
opVal	    byte ' '							;default is space, changes to which operator is selected on calculator.
savedX		byte  NULL							;save last 'X' position on calculator before display num(s).
savedY		byte  NULL							;save last 'Y' position on calculator before display num(s).
tptr		dword NULL							;pointer to hold a memory address.

;---MACROS---;
;;Gets the Length of an Array that is input.
mLength Macro array
	lea edi, array			;;point to the array.
	xor eax, eax			;;flush eax.
	xor ecx, ecx			;;flush ecx.
	call GetLength			;;calls getLength Procedure.
endm
;;Sets up the message so it does not exceed display size.
mSetMsg Macro Array, Len
		xor eax,eax			;flush eax register.
		mov dl, ANS_COL		;move answer column into dl (column position).
		sub dl, Len			;subtract Len so that it will write right to left.
		mov dh, ANS_ROW		;move answer row into dh (row position).
		call Gotoxy			;move cursor.
		lea edi, Array		;point to Ary or Bry (array).
		mov cl, Len			;move array length into cl register.
endm

.code
main PROC

	call SetupCalculator		;Setup calculator display on console and set cursor position.
	call Calculator				;Interacting with calculator.

	invoke ExitProcess, 0
main endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SetupCalculator Procedure             ;;
;; to change colors/display calculator on;;
;; the console and set cursor position.  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetupCalculator proc
	mov eax,13 +(black SHL 4)  ;setup console color.
	call SetTextColor		   ;call text color change procedure.
	lea edi, calStr			   ;point to calStr to print console layout design.
	call WriteStr			   ;write calculator string to the console using WriteStr procedure.

	mov eax,13 +(black SHL 4)  ;setup console color as black and light blue.
	call SetTextColor		   ;call text color change procedure.

	lea edi, nline			   ;string for new line.
	call WriteStr			   ;p rints to console.
	lea edi, nline			   ;string for new line.
	call WriteStr			   ;prints to console.
	lea edi, fline			   ;string for == line.
	call WriteStr			   ;prints to console.

	lea edi, Msg0			   ;Interactive Program Message at bottom.
	call WriteStr			   ;Write to Console.
	
	lea edi, Msg1			   ;created by string.
	call WriteStr			   ;write to console.

	lea edi, fline			   ;string for == line.
	call WriteStr			   ;write to console.

	mov eax,12 +(black SHL 4)  ;setup console color.
	call SetTextColor		   ;call text color change procedure.

	lea esi, calStr			   ;point to calStr
	xor edx,edx				   ;flush register.
	mov dh, 9	;row		   ;starting Row for cursor.
	mov dl, 4	;col		   ;starting Column for cursor.
	call Gotoxy				   ;call to move the cursor.
	ret						   ;return to main procedure.
SetupCalculator endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Procedure to write a string to console;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WriteStr proc
Nextchar:	
		mov al, [edi]			;increment edi by one character through the array of chars byte size
   		cmp al, NULL			;checking to see if al is equal to zero
		je nearEnd  			;jump out of this procedure
		call WriteChar			;invoked character write to console
		inc edi					;move to next character.
jmp Nextchar
nearEnd:
		ret
WriteStr endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procedure to Read Character from keyboard;;
;; then write character to console.         ;;
;; esi holds position in CalStr				;;
;; edi holds position in Ary (equation)     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Calculator Proc				
	xor eax, eax			;flush eax register.
	xor ebx, ebx			;flush ebx register.
	lea esi, calStr			;point to calStr
	add esi, 220			;add 220 (start position)
	lea edi, Ary			;point to Ary (will store equation).
	Continue:
		xor eax,eax			;flush out the register data.
		call ReadChar		;read character from keyboard.
		cmp al, ECP			;escape entered, program will terminate.
	je quit
		cmp al, CR			;checks for carriage return, which means the user selected a number.
	je inputNumber
		cmp ah, RA			;Right arrow check.
	je  R_Arrow
        cmp ah, LA			;Left arrow check.
	je  L_Arrow
		cmp ah, DA			;Down arrow check.
	je D_Arrow
		cmp ah, UA			;Up arrow check.
	je U_Arrow

	R_Arrow:
		cmp dl, Max_R		;checking bounds of calculator on right arrow.
	je Continue
		add dl, 4			;increment over 4 spaces (next value).
		call Gotoxy			;move cursor.
		add esi, 4			;mov esi to point to character on. (shifting to right).
		jmp Continue		;jump to continue reading characters.
	jne Continue
	L_Arrow:
		cmp dl, Max_L		;checking bounds of calculator on left arrow.
	je Continue
		sub dl, 4			;decrement over 4 spaces (next value).
		call Gotoxy			;move cursor.
		sub esi, 4			;mov esi to point to character on. (shifting to left).
		jmp Continue		;jump to continue reading characters.
	D_Arrow:
		cmp dh, Max_D		;checking bounds of calculator on down arrow.
	je Continue
		add dh, 2			;add 2 to dh, shift row down 2.
		call Gotoxy			;move cursor.
		add esi, 48			;
		jmp Continue		;jump to continue reading characters.
	U_Arrow:
		cmp dh, Max_U		;checking bounds of calculator on up arrow.
	je Continue
		sub dh, 2			;subtract 2 from dh, shift row up 2.
		call Gotoxy
		sub esi, 48			;
		jmp Continue		;jump to continue reading characters.
	inputNumber:
		mov bl, [esi]		;move number into bl register.
		cmp bl, equalSign	;looking for equal sign.
	je getAnswer
		cmp bl, CLR			;checking for 'C' input to clear the display box.
	je clearit
		mov [edi], bl		;storing new value into Ary.
		push edx			;push col to stack.
		push ebx			;push bl to stack.
		
		mLength Ary			;MACRO CALL get length of Ary, uses cl and edi
		mov AryLen, cl		;get length from cl register and move to AryLen.
		cmp AryLen, aLimit  ;check size of array to make sure smaller than limit.
	jle SetMsg
		mov al, aLimit		;limit check, display is max at aLimit.
		mov AryLen, al		;move AryLen (length into al register).
	SetMsg:
		mSetMsg Ary, AryLen ;MACRO call
	PrintAns:
		mov al, [edi]		;move first character into al register.
		call WriteChar		;write character to the screen.
		inc edi				;increment edi register by one byte.
		dec cl				;decrement counter in cl.
		cmp cl, NULL		;compare cl to 0.
	jne PrintAns
		pop ebx				;get ebx register off the stack.
		pop edx				;get edx register (dh & dl) from last position cursor was on before going to Display location.
		call Gotoxy			;move the cursor.
	jmp Continue			;jump to Continue.
	getAnswer:
		push edx			;push edx to the stack.
		push ebx			;push ebx to the stack.
		call ClrField		;will clear the input/output field.
		call CalculateAns	;will calculate the answer and move it into Bry
		mov BryLen, aLimit  ;move limiter in BryLen
		cmp BryLen, aLimit	;compare for jump.
	jle SetMsg2
	jmp PrintAns			;jump if BryLen is less or equal to aLimit.
		SetMsg2:
		mSetMsg Bry, BryLen ;resize BryLen to fit aLimit.
	jmp PrintAns			;jump to Print answers.

	clearit:
		mov tptr, esi		;temporary pointer to hold esi's last address.
		call ClrAll			;call to clear input/output arrays, and message field.
		lea edi, Ary		;point back to Ary array.
		mov esi, tptr
	jmp Continue			;go back to the screen to read next input.
	quit:
		mov dl, 0			;move to first column	
		mov dh, 25			;move below interactive calculator upon exit.
		call Gotoxy
		ret					;returns to main proc
Calculator endp				;end of procedure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ClrAll procedure, clears out all saved ;;
;; values in Ary, Bry, AryLen, BryLen.    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClrAll proc
 	mov savedX, dh			;saving row. 
	mov savedY, dl			;saving column.
	mLength Ary				;MACRO call to set cl equal to length of filled spots in array.			
	cmp cl, NULL			;checking if array is not filled, for error handling, cl cannot be NULL for the loop.
	je Done
	lea edi, Ary			;point at Array to blankout.
	mov al, SPC				;move SPC character into al register.
	C1:						
		mov [edi], al		;move into index to blank it out.
		inc edi				;increment edi.
	loop C1

	mLength Bry				;MACRO call to set cl equal to length of filled spots in array.
	cmp cl, NULL			;checking if array is not filled, for error handling, cl cannot be NUL for the loop.
	je Done
	lea edi, Bry			;point to Array to blankout.
	mov al, SPC				;move SPC character into al register.
	C2:
		mov [edi], al		;move into index to blank it out.
		inc edi				;increment edi.
	loop C2
	
	Done:					
	call ClrField			;clearing message field.	
	mov BryLen, NULL		;setting back to null.
	mov AryLen, NULL		;setting back to null.

	mov dh, savedX			;resetting column.
	mov dl, savedY			;resetting row.
	call Gotoxy				;move cursor.

	ret						;returning to procedure that called it.
ClrAll endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ClrField procedure, write blanks to    ;;
;; the console where the input/output     ;;
;; field is located.                      ;;
;; uses: al, cl, dh, dl registers.        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClrField proc
	xor edx, edx			;flushing the edx register.
	xor ecx, ecx			;flushing the ecx register.
	mov al, SPC				;put space in field.
	mov dh, ANS_ROW  		;row the msg field is in.
	mov dl, ANS_COL 		;column the msg field starts in.
	dec dl					;get to 17th position. I use the 18 for display easier to decrement 1 here.
	mov cl, aLimit			;limit of msg field.
	call Gotoxy				;move cursor.
	L1:	
		call WriteChar		;write value to console.
		dec dl				;decrement column <---going this direction.
		call Gotoxy			;move cursor <-- this direction.
	loop L1

	mov eax,12 +(black SHL 4)  ;setup console color as black and light blue.
	call SetTextColor		   ;call text color change procedure.
	ret						;return to the procudure that called it.
ClrField endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CalculateAns procedure, will perform   ;;
;; the necessary calculations to fill     ;;
;; Bry with the answer in ASCII form.     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CalculateAns proc
	lea edi, Ary
	call ATOI				;reads until operator value is found.
	mov valA, eax
	mov al, [edi]			;check for operator
	mov opVal, al			;store operator value.
	inc edi					;get past operator index.
	call ATOI				;reads to the end.
	mov valB, eax			;store next value to calculate.
	
		cmp opVal, '+'		;check for addition.
	je Addition
		cmp opVal, '-'		;check for subtraction.
	je Subtraction
		cmp opVal, '*'		;check for multiplication.
	je Multiply
		cmp opVal, '/'		;check for division.
	je Division

	Addition:
		mov eax, valA		;move valA into eax register.
		mov ebx, valB		;move valB into ebx register.
		add eax, ebx		;add eax and ebx, store in eax register.
	jmp Done

	Subtraction:
		mov eax, valA		;move valA into eax register.
		mov ebx, valB		;move valB into ebx register.
		sub eax, ebx		;subtract ebx from eax register.
	jmp Done
	
	Multiply:
		mov eax, valA		;move valA into eax register.
		mov ebx, valB		;move valB into ebx register.
		imul eax, ebx		;perform signed multiplication.
     jmp done

	Division:
		xor edx, edx		;flush edx register.
		mov eax, valA		;move valA into eax register.
		mov ebx, valB		;move valB into ebx register.
		idiv ebx			;perform division. storing value into eax register.

	Done:
		mov valC, eax		;move solution into valC
		mov ecx, aLimit
		lea edi, Bry
		call BlankOut
		mov eax, valC
		call ITOA
		lea edi, Bry		;

		mov eax,10 +(black SHL 4)  ;setup console color as black and light blue.
		call SetTextColor		   ;call text color change procedure.
		ret						;returns to calculator procedure.
CalculateAns endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Gets Array Length uses a macro prior to ;;
;; being called, (mLength [array] <-Arg)  ;;
;; return: cl holds length value in byte  ;;
;; size.                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetLength proc
	C1:
		mov al,[edi]	;move value edi points to into al register.
		cmp al, SPC		;check for space.
	je C2
		inc cl  		;increment counter.
		inc edi			;increment the array.
		jmp C1	
	C2:
		ret				;returns to the procedure that called it.
GetLength endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procedure to ASCII to Integer.        ;;
;; setup to use edi.					 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ATOI Proc
	mov eax, 0							;zero out eax register.
	mov ebx, 0							;zero out ebx register.
NextDigit:
		mov bl, [edi]					;move value esi points to into bl   
		cmp bl, '0'						;compare digit to 0 character
	jl getOut							;jump if less than
		cmp bl, '9'						;compare digit to 9 character
	jg getOut							;jump if greater than
		AND bl, 0Fh						;ANDing the value (real fast).
	    imul eax, TEN					;multiply eax by 10
	    add eax, ebx					;add ebx register to eax register.
		inc edi							;increment the ptr
jmp NextDigit
	getOut:
		ret								;returns to main proc.
ATOI endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Procedure to Integer to ASCII.         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
ITOA Proc
	mov ebx, TEN						;setting base value for the ascii number.
	NextDigit: 
		mov edx, NULL					;setup for divide
		idiv ebx						;edx ax/ebx
		OR edx, '0'						;converting digit to ASCII by adding 30h or '0'
		dec edi							;decrementing the pointer to get to the next digit  <----goes backwards from LSB to MSB
		mov [edi],dl					;mov dl not location esi is pointing at.
		cmp eax, NULL					;compares eax to 0.
	jne NextDigit
	ret									;returns to main proc.
ITOA endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procedure to BlankOut Memory.         ;;
;; setup to use edi.				     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BlankOut Proc
	mov al, SPC							;moving a blank to al.
blank:
	mov[edi], al						;point to al.
	inc edi								;increment esi pointer.
	dec ecx								;decrement ecx counter.
	cmp ecx, NULL						;compare ecx to NULL.
jne blank
	ret									;return to main proc.
BlankOut endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;-----------END OF PROGRAM--------------;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end main