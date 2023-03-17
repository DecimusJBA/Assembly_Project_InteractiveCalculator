;Assembly Notes


.data



N equ 8

.code
main proc

	push 5
	call Fact
	pop eax

	invoke ExitProcess, 0
main endp

Fact proc
	push ebp
	mov ebp, esp
	
	mov eax, N[ebp]
	cmp eax, 0   ;N == 0?
	jne  R1 ;N_MinusOne
		;base case
	
	mov eax, 1
	mov Ans[ebp], eax
	jmp Returnstuff
	
R1: ;N_MinusOne
	dec eax         ;N-1
	push eax	    ;push to stack
	call Fact		;return goes here. RECURSIVE CALL IS HERE.
 pop eax
 mov edx, 0		    ;multiply takes 2 register eax,edx
 imul eax, Ans[ebp]   ;moved down 8 on the stack.
 mov Ans[ebp], eax    ;moved 1x1
	
	
Returnstuff:
	pop ebp    ;removes ebp from top of stack.
	ret		   ;removes @fact (return address)

Fact endp










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;-----------END OF PROGRAM--------------;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end main