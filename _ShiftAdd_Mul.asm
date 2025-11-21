
; Cheat08_ShiftAdd_Mul.asm
; Multiply two 64-bit hex numbers using shift-and-add method

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
prompt1 db "Enter multiplicand (hex): ",0
prompt2 db "Enter multiplier (hex): ",0
outmsg db "Product (128-bit hex high then low):",10,0
outbuf resb 40

section .bss
inbuf resb 32

section .text
global _start
_start:
    WRITE prompt1,26
    READ inbuf,32
    call parse_hex
    mov [rel multiplicand], rax

    WRITE prompt2,25
    READ inbuf,32
    call parse_hex
    mov [rel multiplier], rax

    xor rdx, rdx
    xor rax, rax
    xor r8, r8    ; accumulator low
    xor r9, r9    ; accumulator high
    mov rcx, [rel multiplier]

    ; iterate 64 times
    mov r10, 0
mul_loop:
    cmp r10, 64
    je mul_done
    ; check LSB of rcx (multiplier)
    mov r11, rcx
    and r11, 1
    cmp r11, 0
    je no_add
    ; add multiplicand shifted by r10 to accumulator
    ; for performance, if r10 < 64, shift multiplicand left by r10 into temp high/low
    mov r12, [rel multiplicand]
    ; shift left by r10: use shl r12, cl etc (we'll shift sequentially using loop)
    mov r13, r12
    mov r14, 0
    mov rsi, r10
sloop:
    cmp rsi, 0
    je sdone
    shl r13, 1
    rcl r14, 1
    dec rsi
    jmp sloop
sdone:
    ; add low
    add r8, r13
    adc r9, r14

no_add:
    ; shift multiplier right by 1
    shr rcx, 1
    inc r10
    jmp mul_loop

mul_done:
    WRITE outmsg, len outmsg
    mov rbx, r9
    call to_hex16_print
    mov rbx, r8
    call to_hex16_print
    mov rax,60
    xor rdi,rdi
    syscall

; parse_hex -> rax
parse_hex:
    mov rsi, inbuf
    xor rax, rax
ph_loop8:
    mov dl, [rsi]
    cmp dl, 0x0A
    je ph_done8
    cmp dl, 0
    je ph_done8
    cmp dl, ' '
    je ph_skip8
    mov rcx,0
    cmp dl,'0'
    jl ph_skip8
    cmp dl,'9'
    jle ph_digit8
    cmp dl,'A'
    jl ph_skip8
    cmp dl,'F'
    jle ph_upper8
    cmp dl,'a'
    jl ph_skip8
    cmp dl,'f'
    jle ph_lower8
    jmp ph_skip8
ph_digit8:
    sub dl,'0'
    mov rcx, rdx
    jmp ph_apply8
ph_upper8:
    sub dl,'A'
    add dl,10
    mov rcx, rdx
    jmp ph_apply8
ph_lower8:
    sub dl,'a'
    add dl,10
    mov rcx, rdx
ph_apply8:
    shl rax,4
    add rax, rcx
ph_skip8:
    inc rsi
    jmp ph_loop8
ph_done8:
    ret

; to_hex16_print (same as in Cheat07)
to_hex16_print:
    mov rsi, outbuf
    mov rcx, 16
    mov rax, rbx
gen_hex16b:
    rol rax, 4
    mov dl, al
    and dl, 0x0F
    cmp dl, 9
    jbe td1b
    add dl, 55
    jmp td2b
td1b:
    add dl, '0'
td2b:
    mov [rsi], dl
    inc rsi
    dec rcx
    jnz gen_hex16b
    mov byte [rsi], 10
    inc rsi
    mov rdx, 17
    mov rsi, outbuf
    mov rax,1
    mov rdi,1
    syscall
    ret

section .data
multiplicand dq 0
multiplier dq 0
