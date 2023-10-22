; Hello World in assebly

section .data
    msg       db     'Hello, World!', 10 ; 10 is ascii for new line
    msg_len   equ    $-msg

section .text
global _start
_start:
    mov rax, 1       ; syscall number, 1 = write
    mov rdi, 1       ; file descriptor, 1 = stdout
    mov rsi, msg     ; pointer to data
    mov rdx, msg_len ; size of the data
    syscall

    mov rax, 60      ; syscall number, 60 = exit
    mov rdi, 0       ; exit code
    syscall
