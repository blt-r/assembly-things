; Hello World in assebly with libc

extern printf
extern exit

section .data
    ; 10 is ascii for new line, 0 is null terminator
    msg       db     'Hello, World!', 10, 0

section .text
global _start
_start:

    mov rdi, msg
    call printf

    mov rdi, 0
    call exit

