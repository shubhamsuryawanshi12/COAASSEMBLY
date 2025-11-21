
; Cheat10_Strings_len_cmp_copy.asm
; Menu: length, compare, copy

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
menu db "1.Length",10,"2.Compare",10,"3.Copy",10,"4.Exit",10,"Enter choice: ",0
menulen equ $-menu
msg1 db "Enter first string: ",0
msg2 db "Enter second string: ",0
msg_len db "Length: ",10,0
msg_cmp_eq db "Strings Equal",10,0
msg_cmp_ne db "Strings Not Equal",10,0
msg_copy db "Copied string: ",10,0

section .bss
s1 resb 64
s2 resb 64
out resb 64
l1 resq 1
l2 resq 1
choice resb 4
inbuf resb 128

section .text
global _start
_start:
    WRITE msg1,18
    READ s1,64
    ; compute length
    mov rdi, s1
    xor rax, rax
len10:
    mov bl, [rdi]
    cmp bl, 0x0A
    je len10_done
    inc rax
    inc rdi
    jmp len10
len10_done:
    mov [l1], rax

menu_loop10:
    WRITE menu, menulen
    READ choice,4
    cmp byte [choice],'1'
    je do_len10
    cmp byte [choice],'2'
    je do_cmp10
    cmp byte [choice],'3'
    je do_copy10
    cmp byte [choice],'4'
    je do_exit10
    jmp menu_loop10

do_len10:
    ; print length decimal
    mov rax, [l1]
    mov rsi, out
    add rsi, 20
    mov rcx, 0
itoa10:
    xor rdx,rdx
    mov rbx,10
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    cmp rax, 0
    jne itoa10
    WRITE msg_len,8
    mov rax,1
    mov rdi,1
    mov rdx, rcx
    syscall
    jmp menu_loop10

do_cmp10:
    WRITE msg2,19
    READ s2,64
    ; compare lengths quickly
    mov rax, [l1]
    ; compute l2
    mov rdi, s2
    xor rbx, rbx
len2c:
    mov dl, [rdi]
    cmp dl, 0x0A
    je len2_done
    inc rbx
    inc rdi
    jmp len2c
len2_done:
    mov [l2], rbx
    cmp rax, rbx
    jne not_eq10
    ; compare content
    mov rsi, s1
    mov rdi, s2
cmp_loop10:
    mov al, [rsi]
    cmp al, 0x0A
    je equal10
    cmp al, [rdi]
    jne not_eq10
    inc rsi
    inc rdi
    jmp cmp_loop10
equal10:
    WRITE msg_cmp_eq,15
    jmp menu_loop10
not_eq10:
    WRITE msg_cmp_ne,17
    jmp menu_loop10

do_copy10:
    ; copy s1 to out
    mov rsi, s1
    mov rdi, out
copy10:
    mov al, [rsi]
    cmp al, 0x0A
    je copy10_done
    mov [rdi], al
    inc rsi
    inc rdi
    jmp copy10
copy10_done:
    WRITE msg_copy,14
    mov rax,1
    mov rdi,1
    mov rsi, out
    syscall
    jmp menu_loop10

do_exit10:
    EXIT

section .bss
l2 resq 1
