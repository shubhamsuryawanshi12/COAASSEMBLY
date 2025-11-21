
; Cheat03_AddDiv_Menu.asm
; Accept two 64-bit numbers and perform Addition or Division (menu)

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

%macro EXIT 0
    mov rax,60
    mov rdi,0
    syscall
%endmacro

section .data
menu db "1. Addition",10
     db "2. Division",10
     db "3. Exit",10
     db "Enter choice: ",0
menulen equ $-menu

msg_a db "Enter first number (hex): ",0
msg_b db "Enter second number (hex): ",0
msg_add db "Addition (hex): ",0
msg_divq db "Quotient (hex): ",0
msg_divr db "Remainder (hex): ",0
msg_inv db "Invalid choice",10

section .bss
inbuf resb 32
actl resq 1
num1 resq 1
num2 resq 1
choice resb 4
outbuf resb 32

section .text
global _start
_start:
    ; read first number
    WRITE msg_a, 24
    READ inbuf, 32
    call parse_hex
    mov [num1], rbx

    ; read second number
    WRITE msg_b, 25
    READ inbuf, 32
    call parse_hex
    mov [num2], rbx

menu_loop:
    WRITE menu, menulen
    READ choice,4
    cmp byte [choice], '1'
    je do_add
    cmp byte [choice], '2'
    je do_div
    cmp byte [choice], '3'
    je do_exit
    WRITE msg_inv, 12
    jmp menu_loop

do_add:
    mov rax, [num1]
    add rax, [num2]
    mov rbx, rax
    WRITE msg_add, 15
    call to_hex20
    jmp menu_loop

do_div:
    mov rdx, 0
    mov rax, [num1]
    cmp qword [num2], 0
    je div_by_zero
    div qword [num2]
    ; quotient in rax, remainder in rdx
    mov rbx, rax
    WRITE msg_divq, 14
    call to_hex20
    mov rbx, rdx
    WRITE msg_divr, 15
    call to_hex20
    jmp menu_loop

div_by_zero:
    ; print invalid (reuse msg_inv)
    WRITE msg_inv, 12
    jmp menu_loop

do_exit:
    EXIT

; parse_hex: input buffer in 'inbuf', returns value in rbx
; supports ascii hex (without 0x), up to 16 hex digits
parse_hex:
    ; rsi -> inbuf
    mov rsi, inbuf
    ; rax = bytes read returned by READ in rax, but we can't rely; find newline
    xor rbx, rbx
parse_loop:
    mov dl, [rsi]
    cmp dl, 0x0A
    je parse_done
    cmp dl, 0
    je parse_done
    ; skip spaces
    cmp dl, ' '
    je parse_skip
    ; convert hex char to value in rdx
    mov rcx, 0
    cmp dl, '0'
    jl parse_skip
    cmp dl, '9'
    jle parse_digit
    cmp dl, 'A'
    jl parse_lower
    cmp dl, 'F'
    jle parse_upper
    cmp dl, 'a'
    jl parse_skip
    cmp dl, 'f'
    jle parse_lower
    jmp parse_skip

parse_digit:
    sub dl, '0'
    mov rcx, rdx
    jmp parse_apply

parse_upper:
    sub dl, 'A'
    add dl, 10
    mov rcx, rdx
    jmp parse_apply

parse_lower:
    sub dl, 'a'
    add dl, 10
    mov rcx, rdx

parse_apply:
    shl rbx, 4
    add rbx, rcx
parse_skip:
    inc rsi
    jmp parse_loop

parse_done:
    ret

; to_hex20: convert rbx (64-bit) to 16 hex chars and write
to_hex20:
    mov rsi, outbuf
    mov rcx, 16
    mov rax, rbx
    ; generate from most significant nibble to least by rotating
gen_loop:
    rol rax, 4
    mov dl, al
    and dl, 0x0F
    cmp dl, 9
    jbe add_digit
    add dl, 55 ; 'A' - 10 = 65 -10 =55
    jmp store
add_digit:
    add dl, '0'
store:
    mov [rsi], dl
    inc rsi
    dec rcx
    jnz gen_loop
    ; write newline
    mov byte [rsi], 10
    inc rsi
    mov rdx, 17
    mov rsi, outbuf
    mov rax, 1
    mov rdi, 1
    syscall
    ret
