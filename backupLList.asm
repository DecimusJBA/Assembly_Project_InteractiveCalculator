;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CS340 Assembly Language Course   							   ;;
;; Brett Dahmer													   ;;
;; Student ID# 00076158											   ;;
;; Program: Finds the largest product of four numbers that can be  ;;
;; in a (row, column, or diagonally).                              ;;
;; Requires: Input file, output file.                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INCLUDE Irvine32.inc



.data

;ALIGN DWORD
;---Control Characters---;
NULL	EQU 00h         
LF		EQU 0ah         
CR		EQU 0dh         
SPC 	EQU 20h
BitC	EQU 0DFH
FN		 = 0	;firstName
GD		 = 20   ;Grade
;linky	 EQU 18

;mPry		;;macro to print.
;;char:req    ;this is a print macro.

;recs byte 100 dup (28 dup (?))  ;setting up my own records 100 students max storing 28 bytes each  

;---Storage for Numerical Values---;
TEN			dword	10							

;---Input and Output filenames and handles---;
outFN		byte	"BDahmer_ResultsLinkList.txt", NULL		;output filename.
inFN     	byte	"Grades.txt", NULL  					;input filename.
infile		dword	?										;input file handle, value holder.
outfile		dword	?										;output file handle, value holder.

;---Strings---;
fline       byte  "=================================================================", CR, LF, NULL
Msg0	    byte  "Name Grade Sort Link List Program Created by: BRETT DAHMER", CR, LF, NULL

;---Format Strings---;
nline		byte   CR, LF, NULL						;new line string.
;---Storage For Ary1 and Buffer---;
BUFF	 	byte	 1024 dup(?), CR, CR			;size of the buffer (might be overkill).
Ary		byte    6000 dup(" ")				;size of the array.(might be enough).
AryEnd	byte	($ - Ary)								;end of the array.

studCt		dword NULL			;running total of students.
tStuds		dword 32			;total number of students.          
byteCount	dword ?				;stores the total bytes from the Buffer.
valCtr		dword ?				;stores the number of values in Ary1, used as a counter for filling the array.
val			dword 30
nSize		dword 0	
MAXPTS		dword ?				;MAXPTS a student can have.
buffStart	dword ?				;Stores the beginning address of the buffer where record data exists.
buffPos		dword ?				;location where the buffer left off.
headptr		dword ?				;stores the beginning value of the Ary.

linky	    dword ?				;4bytes.
;---MACROS---;
mPry Macro BUFF, val
  lea esi, BUFF
  mov ecx, LENGTHOF BUFF
  m1:
	mov al,[esi]				;puts random character from parameter into al register.
	call WriteChar
	inc esi
	mov al,[esi]
	dec ecx
	cmp ecx, 0
	jne m1	
	pop eax
endm
mPutchar macro char
	push eax
	mov al, char
	call WriteChar
	pop eax
endm

.code

main PROC
	call ReadFileIntoBuffer				;reads an input file into a buffer.
	lea esi, BUFF
	mov al, [esi]
	call ATOI
	mov MAXPTS, eax						;storing max points, 300.
	

	add esi, 2
	mov buffStart, esi                  ;storing the start address of buff position.
	xor esi, esi
	mov esi, buffStart					;storing the address of the beginning of the array
	lea edi, Ary						;getting first address from Ary
	mov headptr, edi					;storing as head ptr.

	mov ecx, 32
LetsGo:
	push ecx
	call AddNode
	pop ecx
	cmp ecx, NULL
	loop LetsGo

	


;---Printing Nodes---;
	lea edi, Ary
	mov ecx, 32
M000:
	mov al, [edi]
	call WriteChar
	inc edi
	cmp al, CR
jne M000



	XOR ebx,ebx
    
	call OutputFileOpenSetup			;opens output file and sets it up.
;;	xor ebx, ebx
;	mov al, 'a'
;	mov bl, 'a'
;	AND al, BitC 
;	call WriteChar

	mov eax, outfile					;moving handle into eax register for output file.
	call CloseFile						;closing output file.   
	
	invoke ExitProcess, 0
main endp

;;;;;;;;;;;;;;;;;;;;;;;;
;; Adding a Node ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
AddNode proc
    L1:
		mov al, [esi]					;move pointed to value into eax register.	
		cmp al, CR						;compare al with space.
	je foundCR							;looking to see if space was found.
		mov [edi], al					;move ascii char into array.
		call WriteChar
		inc edi							;increment edi pointer.
		inc esi							;increment esi pointer, it is pointing to BUFF (the buffer).
	jmp L1								;jump to L1 for loop.
	foundCR:
		mov al, [esi]					;check for return character.
		mov [edi], al					;putting CR in array.
		inc esi
		mov [edi], al
		ret
AddNode endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inserts a node
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
InsertNode proc
	mov ecx, 20							;name size.
	push ecx
	GetName:
		dec ecx								;countdown for size of name.
		mov al, [esi]						;put buff char into al register.
		cmp al, SPC							;look for space.
		je GetGrade
		mov [edi], al						;store value in ARY
		call WriteChar						;DEBUG PRINT CHARACTER TO CONSOLE.
		inc edi								;increment pointer.
		inc esi								;increment buff pointer.
		jmp GetName    
	GetGrade:
		;inc edi
		mov eax, ecx						;moving remainder of space for name into eax register (i.e. 7 bytes).
		pop ecx								;pop the 20 back into ecx
		sub eax, ecx						;subtract to get the remaining bytes between the 20.
		neg eax								;draws negative negate to flip the bits.
		add edi, eax
		;add edi, 20							;get full 20 bytes for name.
	Continue:
		inc esi
		mov al, [esi]
		cmp al, SPC
	je Continue
	C2:
		mov [edi], al						;store grade number
		inc esi								;increment buff ptr.
		inc edi								;increment ary ptr.
		mov al, [esi]						;move buff value into al register.
		cmp al, CR							;compare to a carriage return.
		jne C2
		mov [edi], al
	;---create linky---;
		;mov Linky, edi				;storing link position.
		;mov [edi], Linky			;move address from edi into edi place holder.
		 ret
InsertNode endp

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Procedure to TITLE OF PROGRAM.         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Print_Title proc
		lea esi, fline					;format line bunch of ===.
		call PrintToFile				;prints to file.
		lea esi, Msg0					;The program Title.
		call PrintToFile				;prints to file.
		lea esi, fline					;format line bunch of ===.
		call PrintToFile				;prints to file.
		ret								;return to main proc.
Print_Title endp	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FillAry will convert size value from  ;;
;; byte to dword and put into an array.  ;;
;; returns with esi pointing to last     ;;
;; position used in the buffer (BUFF).   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FillAry Proc
	mov ecx, 20							;total character returns. Since 20 x 20 array.
	  L1:
		mov eax, [esi]					;move pointed to value into eax register.	
		cmp al, SPC						;compare al with space.
	 je	foundSpace					    ;looking to see if space was found.
									
		GoOn:
			cmp bl, CR					;checking to see if return character.
	 je	foundCR							;branches to the end of the procedures.

			call ATOI					;call ascii to integer, uses esi push to stack if needed later.
			mov [edi], eax				;move integer into Polygon1 (P1).
			inc valctr
			add edi, 4					;increment edi pointer.
			inc esi						;increment esi pointer, it is pointing to BUFF (the buffer).
		    jmp L1

	 foundSpace:
			inc esi 					;increment buff pointer..
			jmp L1						;branch to L1

	 foundCR:
			inc esi						;increment buff pointer.
			mov bl, 0					;clear bl register.
			dec ecx						;dec ecx register.
			cmp ecx, NULL				;compare to NULL, if not return to L1 branch.
	jne L1
		    ret							;return to main procedure.
FillAry endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procedure OutputFileOpenSetup         ;;
;; Opens output file and stores handle   ;;
;; in outfile.                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OutputFileOpenSetup Proc
		lea edx, outFN				    ;outfile 
		call CreateOutputFile           ;creating output file
		mov outfile, eax			    ;move the handle from eax into outfile to store.
		ret							    ;return to main procedure.
OutputFileOpenSetup endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procedure ReadFileIntoBuffer          ;;
;; reads the input file into a buffer    ;;
;; returns to main procedure when done.  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadFileIntoBuffer Proc
		lea edx, inFN	                ;move inFN (input file) into edx for input file parameter.
		call OpenInputFile			    ;opening input file.
		mov infile, eax				    ;move the handle from eax into input file.
		mov ecx, 1024				    ;move buffer size into ecx counter.
		lea edx, BUFF		            ;buffer size in edx.
		mov eax, infile				    ;move handle for infile into eax.
		call ReadFromFile			    ;read file into buffer.
	    mov byteCount, eax
		mov eax, infile				    ;moving infile handle into eax.
		call CloseFile				    ;closing input file.
		ret							    ;return to main proc.
ReadFileIntoBuffer endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procedure to ASCII to Integer.        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ATOI Proc
	mov eax, 0							;zero out eax register.
	mov ebx, 0							;zero out ebx register.
NextDigit:
		mov bl, [esi]					;move value esi points to into bl   
		cmp bl, '0'						;compare digit to 0 character
	jl getOut							;jump if less than
		cmp bl, '9'						;compare digit to 9 character
	jg getOut							;jump if greater than
		AND bl, 0Fh

	    imul eax, TEN					;multiply eax by 10
	    add eax, ebx					;add ebx register to eax register.
		inc esi							;increment the ptr
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
		dec esi							;decrementing the pointer to get to the next digit  <----goes backwards from LSB to MSB
		mov [esi],dl					;mov dl not location esi is pointing at.
		cmp eax, NULL					;compares eax to 0.
	jne NextDigit
	ret									;returns to main proc.
ITOA endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Procedure to BlankOut Memory.          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BlankOut Proc
	mov al, SPC							;moving a blank to al.
blank:
	mov[esi], al						;point to al.
	inc esi								;increment esi pointer.
	dec ecx								;decrement ecx counter.
	cmp ecx, NULL						;compare ecx to NULL.
jne blank
	ret									;return to main proc.
BlankOut endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procedure to print data to file.      ;;
;; uses esi to print characters.         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintToFile Proc
next:
     mov dl, [esi]						;moving value esi points to into dl
     cmp dl, NULL						;comparing to 0.
     je outOfHere
		mov edx, esi					;mov esi into edx.
		mov ecx, 1						;move 1 into ecx.
		mov eax, outfile				;setting eax to handle for outfile.
		call WriteToFile				;calling WriteToFile proc.
		inc esi							;incrementing esi index.
jmp next
	outOfHere:
		ret								;returns to main proc.
PrintToFile endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;-----------END OF PROGRAM--------------;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end main