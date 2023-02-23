; Is Even in assembly
; program accepts 1 command line arguments and exits with 0 if it is even
; otherwise, it exits with 1
; if there is not exactly one argument, the program exits with 2
; usage in shell scripts: 
;     if is-even 42; then
;         echo forty two is even
;     fi

section .data
    err       db    'ERROR: You need to provide one non-empty command line argument'
              db    10 ; 10 is ascii for new line
    err_len   equ   $-err

section .text
global _start
_start:
    mov rcx, [rsp]   ; argc is the first thing on the stack

    cmp rcx, 2       ; if we hove not exactly 2 arguments, arguments are wrong
    jne bad_args

    mov rcx, [rsp + 16] ; argv is at rsp + 8, argv[1] is at rsp + 16, put it in rcx

    mov ah, [rcx]       ; put first character in rax
    cmp ah, 0           ; if argv[1] points to null, the argument is empty
    je bad_args         ; which is bad

loop_body:
    mov dil, [rcx]  ; put current character into rdi, (dil is lowest byte of rdi)
    inc rcx         ; increment pointer to argument
    mov al, [rcx]   ; put next character to rbx

    cmp al, 0       ; if next character is null;
    je after_loop   ; break from the loop
    jmp loop_body   ; otherwise, continue looping
after_loop:
    ; after loop we will have last character of argv[1] in rdi.
    and rdi, 1       ; look at most significant bit of rdi
                     ; if it is one, the ascii value of character is odd
                     ; if ascii value of digit is odd, that digit is odd
                     ; now we have 1 in rax if the number is odd, and 0 if it's even
                     ; that is the exit code we need
                     ; and it is already in rdi where it should be for exit syscall

    mov rax, 60      ; syscall number, 60 = exit
    syscall

bad_args:
    mov rax, 1       ; syscall number, 1 = write
    mov rdi, 1       ; file descriptor, 1 = stdout
    mov rsi, err     ; pointer to data
    mov rdx, err_len ; size of the data
    syscall

    mov rax, 60      ; syscall number, 60 = exit
    mov rdi, 2       ; exit code
    syscall





