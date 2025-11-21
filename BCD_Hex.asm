
; Cheat06_BCDToHex.asm
; Convert decimal BCD input (as ascii digits) to hex 64-bit and print hex

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
prompt db "Enter decimal number: ",0
outmsg db "Hex: ",0
outbuf resb 20

section .bss
inbuf resb 32

section .text
global _start
_start:
    WRITE prompt,22
    READ inbuf,32
    mov rsi, inbuf
    xor rax, rax
parse6:
    mov dl, [rsi]
    cmp dl, 0x0A
    je done6
    cmp dl, 0
    je done6
    cmp dl, '0'
    jl skip6
    cmp dl, '9'
    jg skip6
    sub dl, '0'
    imul rax, 10
    add rax, rdx
skip6:
    inc rsi
    jmp parse6
done6:
    ; rax now value. print as 16 hex chars
    mov rbx, rax
    mov rsi, outbuf
    mov rcx, 16
gen6:
    rol rbx, 4
    mov dl, bl
    and dl, 0x0F
    cmp dl, 9
    jbe d6
    add dl, 55
    jmp s6
d6:
    add dl, '0'
s6:
    mov [rsi], dl
    inc rsi
    dec rcx
    jnz gen6
    ; newline
    mov byte [rsi], 10
    inc rsi
    mov rdx, 17
    mov rsi, outbuf
    mov rax,1
    mov rdi,1
    syscall
    mov rax,60
    xor rdi,rdi
    syscall
