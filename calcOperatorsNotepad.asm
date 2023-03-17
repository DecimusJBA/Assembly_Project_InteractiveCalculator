		cmp al, '+'
	je addOperator
		cmp al, '-'
	je subOperator
		cmp al, '/'
	je divOperator
		cmp al, '*'
	je multOperator
		cmp ah, RA			;Right arrow check.
	je  R_Arrow
        cmp ah, LA			;Left arrow check.
	je  L_Arrow
		cmp ah, DA			;Down arrow check.
	je D_Arrow
		cmp ah, UA			;Up arrow check.
	je U_Arrow


		;ascii to integer using shift right shift left bits.
		SHL bl, 4			;shift 4 left.
		SHR bl, 4			;shift 4 right, converts from ASCII to integer.
		add val_A, ebx		;store in value A.
		
		
		
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Procedure to Read Character from keyboard;;
;;;then write character to console;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Calculator Proc				;start of procedure
	lea esi, calStr			;point to calStr
	add esi, 220			;add 220 (start position)
	lea edi, Ary			;point to Ary (will store equation).
	xor eax, eax			;flush eax register.
	xor ebx, ebx			;flush ebx register.
	;mov al, [esi]			;move calStr value into al register.
	Continue:
		xor eax,eax			;flush out the register data.
		call ReadChar		;read character from keyboard
		cmp al, CR
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
	je solution
		mov [edi], bl		;storing new value into Ary.
		push edx			;push col to stack.
		push ebx			;push bl to stack.
;MIGHT NOT HAVE TO SINCE LEA EDI WILL LAND ON LAST POSITION.		push edi			;push edi pointer to stack.
		mLength Ary			;get length of Ary, uses ecx and edi
		cmp AryLen, aLimit  ;check size of array to make sure smaller than limit.
	jle SetMsg
		mov al, aLimit
		mov AryLen, al
	;	mPosition AryLen	;gets the start position for printing characters in display.
		;pop edi
	SetMsg:
		xor eax,eax			;flush eax register.
		mov dl, ANS_COL		;move answer column into dl (column position).
		sub dl, AryLen		;subtract AryLen so that it will write right to left.
		mov dh, ANS_ROW		;move answer row into dh (row position).
		call Gotoxy			;move cursor
		lea edi, Ary		;point to Ary (array).
		mov cl, AryLen		;move array length into cl register.
	PrintAns:
		mov al, [edi]		;move first character into al register.
		call WriteChar		;write character to the screen.
		inc edi				;increment edi register by one byte.
		dec cl				;decrement counter in cl.
		cmp cl, NULL		;compare cl to 0.
	jne PrintAns
		pop ebx				;get ebx register off the stack.
		;mov [edi], bl		;store the value in edi
		;mov al, [edi]
		;call WriteChar
		pop edx				;get edx register (dh & dl) from last position cursor was on before going to Display location.
		call Gotoxy			;move the cursor.
		
		;mov [edi], bl		;store the number in Ary for solving later.
		;inc edi				;increment edi so the next value can be stored if number or operator.
		;SHL bl, 4			;shift 4 left.
		;SHR bl, 4			;shift 4 right, converts from ASCII to integer.
		;add val_A, ebx		;store in value A.
		jmp Continue
		;add val_A, dword ptr [bl]
	solution:
		ret					;returns to main proc
Calculator endp				;end of procedure






;---MACROS---;
mLength Macro array
	lea edi, array		;; point to the array.
	xor eax, eax		;; flush eax.
	xor ecx, ecx		;; flush ecx.
	C1:
		mov al,[edi]	;; move value edi points to into al register.
		cmp al, SPC		;; check for space.
	je C2
		inc cl  		;; increment counter.
		inc edi			;; increment the array.
		jmp C1	
	C2:
		;;mov AryLen, cl	;; ecx
		;;
		
		
		
		
		
		
		
		
		;;;;;;;;;;;;;;;MODIFIED VERSION OF CALCULATOER Procedure
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Procedure to Read Character from keyboard;;
;;;then write character to console;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Calculator Proc				;start of procedure

	xor eax, eax			;flush eax register.
	xor ebx, ebx			;flush ebx register.
	Continue:
		xor eax,eax			;flush out the register data.
		call ReadChar		;read character from keyboard
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
		mov [edi], bl		;storing new value into Ary.
		push edx			;push col to stack.
		push ebx			;push bl to stack.
;MIGHT NOT HAVE TO SINCE LEA EDI WILL LAND ON LAST POSITION.		push edi			;push edi pointer to stack.
		mLength Ary			;get length of Ary, uses cl and edi
		mov AryLen, cl		;get length from cl register and move to AryLen.
		cmp AryLen, aLimit  ;check size of array to make sure smaller than limit.
	jle SetMsg
		mov al, aLimit		;limit check, display is max at aLimit.
		mov AryLen, al		;move AryLen (length into al register).
	SetMsg:
	;	xor eax,eax			;flush eax register.
	;	mov dl, ANS_COL		;move answer column into dl (column position).
	;	sub dl, AryLen		;subtract AryLen so that it will write right to left.
	;	mov dh, ANS_ROW		;move answer row into dh (row position).
	;	call Gotoxy			;move cursor.
	;	lea edi, Ary		;point to Ary (array).
	;	mov cl, AryLen		;move array length into cl register.
	 mSetMsg Ary, AryLen
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
		call CalculateAns	;will calculate the answer and move it into Bry
		mLength Bry			;Gets length
		mov BryLen, cl		;move length from cl register to BryLen.
		;mLength Bry			;will get the length of Bry.
		;jmp

	quit:
		ret					;returns to main proc
Calculator endp				;end of procedure
