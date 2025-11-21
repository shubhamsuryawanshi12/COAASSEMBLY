
; Cheat04_MulSub_Menu.asm
; Accept two 64-bit numbers and perform Multiplication or Subtraction (menu)

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
menu db "1. Multiplication",10
     db "2. Subtraction",10
     db "3. Exit",10
     db "Enter choice: ",0
menulen equ $-menu

msg_a db "Enter first number (hex): ",0
msg_b db "Enter second number (hex): ",0
msg_mul db "Product (hex): ",0
msg_sub db "Subtraction (hex): ",0
msg_inv db "Invalid choice",10

section .bss
inbuf resb 32
num1 resq 1
num2 resq 1
choice resb 4
outbuf resb 36

section .text
global _start
_start:
    WRITE msg_a, 24
    READ inbuf, 32
    call parse_hex
    mov [num1], rbx

    WRITE msg_b, 25
    READ inbuf, 32
    call parse_hex
    mov [num2], rbx

menu_loop:
    WRITE menu, menulen
    READ choice,4
    cmp byte [choice], '1'
    je do_mul
    cmp byte [choice], '2'
    je do_sub
    cmp byte [choice], '3'
    je do_exit
    WRITE msg_inv, 12
    jmp menu_loop

do_mul:
    mov rax, [num1]
    mul qword [num2]    ; rdx:rax = product
    ; print high then low to show full 128-bit product (hex 32 chars)
    mov rbx, rdx
    WRITE msg_mul, 13
    call to_hex32
    mov rbx, rax
    call to_hex32
    jmp menu_loop

do_sub:
    mov rax, [num1]
    sub rax, [num2]
    mov rbx, rax
    WRITE msg_sub, 13
    call to_hex20
    jmp menu_loop

do_exit:
    EXIT

; parse_hex: same as Cheat03
parse_hex:
    mov rsi, inbuf
    xor rbx, rbx
parse_loop4:
    mov dl, [rsi]
    cmp dl, 0x0A
    je parse_done4
    cmp dl, 0
    je parse_done4
    cmp dl, ' '
    je parse_skip4
    mov rcx, 0
    cmp dl, '0'
    jl parse_skip4
    cmp dl, '9'
    jle parse_digit4
    cmp dl, 'A'
    jl parse_lower4
    cmp dl, 'F'
    jle parse_upper4
    cmp dl, 'a'
    jl parse_skip4
    cmp dl, 'f'
    jle parse_lower4
    jmp parse_skip4

parse_digit4:
    sub dl, '0'
    mov rcx, rdx
    jmp parse_apply4

parse_upper4:
    sub dl, 'A'
    add dl, 10
    mov rcx, rdx
    jmp parse_apply4

parse_lower4:
    sub dl, 'a'
    add dl, 10
    mov rcx, rdx

parse_apply4:
    shl rbx, 4
    add rbx, rcx
parse_skip4:
    inc rsi
    jmp parse_loop4

parse_done4:
    ret

; to_hex20: convert rbx to 16 hex chars
to_hex20:
    mov rsi, outbuf
    mov rcx, 16
    mov rax, rbx
gen_loop20:
    rol rax, 4
    mov dl, al
    and dl, 0x0F
    cmp dl, 9
    jbe add_digit20
    add dl, 55
    jmp store20
add_digit20:
    add dl, '0'
store20:
    mov [rsi], dl
    inc rsi
    dec rcx
    jnz gen_loop20
    mov byte [rsi], 10
    inc rsi
    mov rdx, 17
    mov rsi, outbuf
    mov rax, 1
    mov rdi, 1
    syscall
    ret

; to_hex32: prints 16 hex chars for value in rbx (call twice with high/low parts)
to_hex32:
    ; uses same outbuf but ensures 16 chars
    mov rsi, outbuf
    mov rcx, 16
    mov rax, rbx
gen_loop32:
    rol rax, 4
    mov dl, al
    and dl, 0x0F
    cmp dl, 9
    jbe add_digit32
    add dl, 55
    jmp store32
add_digit32:
    add dl, '0'
store32:
    mov [rsi], dl
    inc rsi
    dec rcx
    jnz gen_loop32
    mov byte [rsi], 10
    inc rsi
    mov rdx, 17
    mov rsi, outbuf
    mov rax, 1
    mov rdi, 1
    syscall
    ret
