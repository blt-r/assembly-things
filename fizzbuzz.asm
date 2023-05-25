; FizzBuzz in assembly

section .data
    nl          db     0x0a
    
    fizz        db     'Fizz'
    fizz_len    equ    $-fizz
    
    buzz        db     'Buzz'
    buzz_len    equ    $-buzz

    iterations  equ    100
    
section .text
global _start
_start:
    ; local variables:
    push 0               ; the iteratotion variable [rsp]

loop_body:
    cmp dword [rsp], iterations
    jg after_loop


    mov rdx, 0           ; clear remainder
    mov rax, qword [rsp] ; divided
    mov rcx, qword 15    ; divisor
    div rcx              ; result is in rax, remainder is in rdx
    cmp rdx, 0
    je if_divisible_by_15

    mov rdx, 0           ; clear remainder
    mov rax, qword [rsp] ; divided
    mov rcx, qword 5     ; divisor
    div rcx              ; result is in rax, remainder is in rdx
    cmp rdx, 0
    je if_divisible_by_5

    mov rdx, 0           ; clear remainder
    mov rax, qword [rsp] ; divided
    mov rcx, qword 3     ; divisor
    div rcx              ; result is in rax, remainder is in rdx
    cmp rdx, 0
    je if_divisible_by_3
    jmp else_block

if_divisible_by_15:
    call print_fizz
    call print_buzz
    call print_nl

    jmp end_if
if_divisible_by_5:
    call print_buzz
    call print_nl
    
    jmp end_if
if_divisible_by_3:
    call print_fizz
    call print_nl
    
    jmp end_if
else_block:
    mov rdi, [rsp]
    call print_number
    call print_nl
end_if:

    add dword [rsp], 1
    jmp loop_body

after_loop:

    ; deallocate local variables
    add rsp, 8      ; remove iteration variable

    mov rax, 60     ; syscall number, 60 = exit
    mov rdi, 0      ; exit code
    syscall


print_nl:
    mov rax, 1         ; syscall number, 1 = write
    mov rdi, 1         ; file descriptor, 1 = stdout
    mov rsi, nl        ; pointer to data
    mov rdx, 1         ; size of the data
    syscall
    ret
    

print_fizz:
    mov rax, 1         ; syscall number, 1 = write
    mov rdi, 1         ; file descriptor, 1 = stdout
    mov rsi, fizz      ; pointer to data
    mov rdx, fizz_len  ; size of the data
    syscall
    ret
    

print_buzz:
    mov rax, 1         ; syscall number, 1 = write
    mov rdi, 1         ; file descriptor, 1 = stdout
    mov rsi, buzz      ; pointer to data
    mov rdx, buzz_len  ; size of the data
    syscall
    ret


; gets number to print through rdi
; this function won't print anything if number is 0
; but we will never try to print zero anyway
print_number:
    ; local variables:
    sub rsp, 24                 ; the string           [rsp + 16 + index]
    push 0                      ; length of the string [rsp + 8]
    push qword rdi              ; current number       [rsp]

    ; we will be filling the string with ascii digits from back

pn_loop_body:
    cmp qword [rsp], 0
    je pn_after_loop
    
    mov rdx, 0                  ; clear remainder
    mov rax, qword [rsp]        ; divided
    mov rcx, qword 10           ; divisor
    div rcx                     ; result is in rax, remainder is in rdx

    mov [rsp], rax              ; put result back into current number
    add rdx, 48                 ; add 48 to remainder to get ascii code

    inc qword [rsp + 8]         ; increment the length
    
    lea rbx, [rsp + 16 + 24]    ; store pointer to end of string in rbx
    sub rbx, [rsp + 8]          ; subtruct length of string to get pointer to beginning

    mov [rbx], dl               ; put the ascii character in its place
    
    jmp pn_loop_body
pn_after_loop:
    lea rbx, [rsp + 16 + 24]    ; store pointer to end of string in rbx
    sub rbx, [rsp + 8]          ; subtruct length of string to get pointer to beginning

    mov rax, 1                  ; syscall number, 1 = write
    mov rdi, 1                  ; file descriptor, 1 = stdout
    mov rsi, rbx                ; pointer to data
    mov rdx, [rsp + 8]          ; size of the data
    syscall
    
    ; deallocate local variables
    add rsp, 8 + 8 + 24 ; remove number, length, and string        
            
    ret
