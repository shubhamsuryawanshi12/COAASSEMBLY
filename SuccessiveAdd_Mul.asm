
; Cheat07_SuccessiveAdd_Mul.asm
; Multiply two 64-bit hex numbers using successive addition
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
    mov rbx, rax
    mov [rel multiplicand], rbx

    WRITE prompt2,25
    READ inbuf,32
    call parse_hex
    mov rbx, rax
    mov [rel multiplier], rbx

    ; compute product by adding multiplicand multiplier times (careful: slow)
    xor rdx, rdx
    xor rax, rax
    mov rcx, [rel multiplier]    ; rcx = multiplier
    xor r8, r8
    xor r9, r9
loop_add:
    cmp rcx, 0
    je done_mul
    add r8, [rel multiplicand]   ; r8:r9 will hold 128? we'll use r8 as low, r9 as high accumulation
    adc r9, 0
    dec rcx
    jmp loop_add

done_mul:
    ; print high (r9) then low (r8) as 16-hex each
    WRITE outmsg, len outmsg
    mov rbx, r9
    call to_hex16_print
    mov rbx, r8
    call to_hex16_print
    ; exit
    mov rax,60
    xor rdi,rdi
    syscall

; helper parse_hex -> returns value in rax
parse_hex:
    mov rsi, inbuf
    xor rax, rax
ph_loop:
    mov dl, [rsi]
    cmp dl, 0x0A
    je ph_done
    cmp dl, 0
    je ph_done
    cmp dl, ' '
    je ph_skip
    mov rcx,0
    cmp dl,'0'
    jl ph_skip
    cmp dl,'9'
    jle ph_digit
    cmp dl,'A'
    jl ph_skip
    cmp dl,'F'
    jle ph_upper
    cmp dl,'a'
    jl ph_skip
    cmp dl,'f'
    jle ph_lower
    jmp ph_skip
ph_digit:
    sub dl,'0'
    mov rcx, rdx
    jmp ph_apply
ph_upper:
    sub dl,'A'
    add dl,10
    mov rcx, rdx
    jmp ph_apply
ph_lower:
    sub dl,'a'
    add dl,10
    mov rcx, rdx
ph_apply:
    shl rax,4
    add rax, rcx
ph_skip:
    inc rsi
    jmp ph_loop
ph_done:
    ret

; to_hex16_print: print 16 hex chars from rbx
to_hex16_print:
    mov rsi, outbuf
    mov rcx, 16
    mov rax, rbx
gen_hex16:
    rol rax, 4
    mov dl, al
    and dl, 0x0F
    cmp dl, 9
    jbe td1
    add dl, 55
    jmp td2
td1:
    add dl, '0'
td2:
    mov [rsi], dl
    inc rsi
    dec rcx
    jnz gen_hex16
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
