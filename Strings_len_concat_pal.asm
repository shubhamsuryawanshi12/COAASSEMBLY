
; Cheat09_Strings_len_concat_pal.asm
; Menu: length, concatenation, palindrome

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
menu db "1.Length",10,"2.Concat",10,"3.Palindrome",10,"4.Exit",10,"Enter choice: ",0
menulen equ $-menu
msg1 db "Enter first string: ",0
msg2 db "Enter second string: ",0
msg_len db "Length: ",10,0
msg_concat db "Concatenated: ",10,0
msg_pal_yes db "Is palindrome",10,0
msg_pal_no db "Not palindrome",10,0

section .bss
s1 resb 64
s2 resb 64
out resb 128
inbuf resb 128
l1 resq 1
l2 resq 1
choice resb 4

section .text
global _start
_start:
    WRITE msg1,18
    READ s1,64
    ; store length
    mov rax,0
    mov rdi, s1
len_calc1:
    mov bl, [rdi]
    cmp bl, 0x0A
    je len_done1
    inc rax
    inc rdi
    jmp len_calc1
len_done1:
    mov [l1], rax

menu_loop:
    WRITE menu, menulen
    READ choice,4
    cmp byte [choice], '1'
    je do_len
    cmp byte [choice], '2'
    je do_concat
    cmp byte [choice], '3'
    je do_pal
    cmp byte [choice], '4'
    je do_exit
    jmp menu_loop

do_len:
    ; print length as decimal
    mov rax, [l1]
    ; simple itoa for rax
    mov rsi, out
    add rsi, 20
    mov rcx, 0
itoa_loop:
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    cmp rax, 0
    jne itoa_loop
    ; write
    WRITE msg_len, 8
    mov rdx, rcx
    mov rax,1
    mov rdi,1
    mov rsi, rsi
    syscall
    WRITE nl,1
    jmp menu_loop

do_concat:
    WRITE msg2,19
    READ s2,64
    ; copy s1 then s2 to out
    mov rsi, s1
    mov rdi, out
copy1:
    mov al, [rsi]
    cmp al, 0x0A
    je copy1_done
    mov [rdi], al
    inc rsi
    inc rdi
    jmp copy1
copy1_done:
    ; copy s2
    mov rsi, s2
copy2:
    mov al, [rsi]
    cmp al, 0x0A
    je copy2_done
    mov [rdi], al
    inc rsi
    inc rdi
    jmp copy2
copy2_done:
    ; write result
    WRITE msg_concat, 14
    ; calculate length
    mov rdx, rdi
    sub rdx, out
    mov rax,1
    mov rdi,1
    mov rsi, out
    syscall
    WRITE nl,1
    jmp menu_loop

do_pal:
    ; check palindrome of s1
    mov rsi, s1
    mov rcx, [l1]
    mov rdi, s1
    add rdi, rcx
    dec rdi
pal_loop:
    mov al, [rsi]
    cmp al, 0x0A
    je pal_yes
    cmp al, [rdi]
    jne pal_no
    inc rsi
    dec rdi
    dec rcx
    cmp rcx,0
    jne pal_loop
pal_yes:
    WRITE msg_pal_yes, 13
    jmp menu_loop
pal_no:
    WRITE msg_pal_no, 16
    jmp menu_loop

do_exit:
    EXIT

section .data
nl db 10
