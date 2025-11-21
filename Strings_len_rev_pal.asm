
; Cheat11_Strings_len_rev_pal.asm
; Menu: length, reverse, palindrome

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
menu db "1.Length",10,"2.Reverse",10,"3.Palindrome",10,"4.Exit",10,"Enter choice: ",0
menulen equ $-menu
msg1 db "Enter string: ",0
msg_len db "Length: ",10,0
msg_rev db "Reversed: ",10,0
msg_pal_yes db "Palindrome",10,0
msg_pal_no db "Not Palindrome",10,0

section .bss
s resb 128
out resb 128
l resq 1
choice resb 4

section .text
global _start
_start:
    WRITE msg1,13
    READ s,128
    ; compute length
    mov rdi, s
    xor rax, rax
len11:
    mov bl, [rdi]
    cmp bl, 0x0A
    je len11_done
    inc rax
    inc rdi
    jmp len11
len11_done:
    mov [l], rax

menu11:
    WRITE menu, menulen
    READ choice,4
    cmp byte [choice],'1'
    je do_len11
    cmp byte [choice],'2'
    je do_rev11
    cmp byte [choice],'3'
    je do_pal11
    cmp byte [choice],'4'
    je do_exit11
    jmp menu11

do_len11:
    ; print length decimal
    mov rax, [l]
    mov rsi, out
    add rsi, 20
    mov rcx, 0
itoa11:
    xor rdx,rdx
    mov rbx,10
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    cmp rax, 0
    jne itoa11
    WRITE msg_len,8
    mov rax,1
    mov rdi,1
    mov rdx, rcx
    mov rsi, rsi
    syscall
    jmp menu11

do_rev11:
    mov rsi, s
    mov rdi, out
    mov rcx, [l]
    add rsi, rcx
    dec rsi
rev_loop:
    mov al, [rsi]
    cmp al, 0x0A
    je rev_done
    mov [rdi], al
    dec rsi
    inc rdi
    dec rcx
    cmp rcx,0
    jne rev_loop
rev_done:
    WRITE msg_rev,9
    mov rax,1
    mov rdi,1
    mov rsi, out
    syscall
    jmp menu11

do_pal11:
    mov rsi, s
    mov rdi, out
    mov rcx, [l]
    add rdi, rcx
    dec rdi
pal_loop11:
    mov al, [rsi]
    cmp al, 0x0A
    je pal_yes11
    cmp al, [rdi]
    jne pal_no11
    inc rsi
    dec rdi
    dec rcx
    cmp rcx,0
    jne pal_loop11
pal_yes11:
    WRITE msg_pal_yes,11
    jmp menu11
pal_no11:
    WRITE msg_pal_no,14
    jmp menu11

do_exit11:
    EXIT
