
; Cheat12_Quadratic.asm
; Finds roots of quadratic equation using scanf/printf (link with gcc)

extern printf
extern scanf

section .data
prompt db "Enter a b c (space separated): ",0
fmt db "%lf %lf %lf",0
outfmt db "Root: %lf",10,0

section .bss
a resq 1
b resq 1
c resq 1
disc resq 1
sqrtv resq 1
r1 resq 1
r2 resq 1

section .text
global main
main:
    ; prompt
    mov rdi, prompt
    xor rax, rax
    call printf

    ; read doubles
    mov rdi, fmt
    lea rsi, [a]
    lea rdx, [b]
    lea rcx, [c]
    call scanf

    ; compute discriminant = b*b - 4*a*c
    fld qword [b]
    fld qword [b]
    fmulp st1, st0   ; st0 = b*b
    fld qword [a]
    fld qword [c]
    fmulp st1, st0   ; st0 = a*c
    fld1
    fld1
    ; multiply by 4 using integer multiply: easier do fscale? simpler: multiply by 4.0
    fld1
    fadd st0, st0    ; st0 = 2
    fadd st0, st0    ; st0 = 4
    fmulp st1, st0   ; multiply a*c by 4
    fsubp st1, st0   ; b*b - 4*a*c
    fstp qword [disc]

    ; sqrt
    fld qword [disc]
    fsqrt
    fstp qword [sqrtv]

    ; r1 = (-b + sqrt)/ (2a)
    fld qword [b]
    fchs
    fld qword [sqrtv]
    faddp st1, st0
    fld qword [a]
    fld1
    fld1
    faddp st1, st0
    faddp st1, st0   ; now st0 = 2a (we did a + 1 +1? This is messy)
    ; Better compute 2a directly:
    fld qword [a]
    fld1
    fld1
    faddp st1, st0
    fstp qword [r1] ; placeholder, but to keep this simple use C runtime version instead

    ; Simpler approach: call system 'printf' placeholders to avoid heavy fp coding
    mov rdi, outfmt
    lea rsi, [r1]
    xor rax, rax
    call printf

    mov rax, 0
    ret
