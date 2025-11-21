
; Cheat05_HexToBCD.asm
; Convert 64-bit HEX input to BCD and print decimal string (works for up to 20 decimal digits)

%macro WRITE 2
    mov rax,1
    mov rdi,1
    mov rsi,%1
    mov rdx,%2
    syscall
%endmacro

%macro READ 2
    mov rax,0
    mov rdi,0
    mov rsi,%1
    mov rdx,%2
    syscall
%endmacro

section .data
prompt db "Enter hex number: ",0
outmsg db "Decimal (BCD): ",0

section .bss
inbuf resb 32
digits resb 24  ; enough for decimal digits
temp resq 1

section .text
global _start
_start:
    WRITE prompt,17
    READ inbuf,32
    ; parse hex into rbx
    mov rsi, inbuf
    xor rbx, rbx
parse_hex5:
    mov dl, [rsi]
    cmp dl, 0x0A
    je parsed5
    cmp dl, 0
    je parsed5
    cmp dl, ' '
    je skip5
    mov rcx,0
    cmp dl,'0'
    jl skip5
    cmp dl,'9'
    jle digit5
    cmp dl,'A'
    jl skip5
    cmp dl,'F'
    jle upper5
    cmp dl,'a'
    jl skip5
    cmp dl,'f'
    jle lower5
    jmp skip5
digit5:
    sub dl,'0'
    mov rcx, rdx
    jmp apply5
upper5:
    sub dl,'A'
    add dl,10
    mov rcx, rdx
    jmp apply5
lower5:
    sub dl,'a'
    add dl,10
    mov rcx, rdx
apply5:
    shl rbx,4
    add rbx, rcx
skip5:
    inc rsi
    jmp parse_hex5
parsed5:
    ; now rbx has value. Convert to decimal by repeated division by 10, store digits
    mov rcx,0
    mov rdi, digits
    mov rsi, rdi
conv5:
    xor rdx, rdx
    mov rax, rbx
    mov rbx, 10
    div rbx
    mov rbx, rax
    add dl, '0'
    mov [rsi], dl
    inc rsi
    inc rcx
    cmp rbx, 0
    jne conv5
    ; print in reverse
    ; rsi points after last digit, rcx = digit count
    dec rsi
    mov rdx, rcx
print5:
    mov al, [rsi]
    mov [temp], rax
    ; write one char
    mov rax,1
    mov rdi,1
    lea rsi, [rsi]
    mov rdx,1
    syscall
    dec rsi
    dec rdx
    jnz print5
    ; newline
    mov rax,1
    mov rdi,1
    mov rsi, nl
    mov rdx,1
    syscall
    ; exit
    mov rax,60
    xor rdi,rdi
    syscall

section .data
nl db 10
