; cat written in assembly

section .data
    failed_to_open_file_msg     db     'Failed to open file!', 10
    failed_to_open_file_msg_len equ    $-failed_to_open_file_msg

    failed_to_read_file_msg     db     'Failed to read from file!', 10
    failed_to_read_file_msg_len equ    $-failed_to_read_file_msg

    buf_len                     equ    128 * 1024

section .text
global _start
_start:
    sub rsp, 24              ; allocate local variables

                             ; argv is already at    [rsp + 32 + index * 8]
                             ; argc is already at    [rsp + 24]
                             ; file descriptor       [rsp + 16]
                             ; pointer to buffer     [rsp + 8]
                             ; current arg index     [rsp]

    ; allocate the buffer
    mov rax, 9               ; syscall number, 9 = mmap
    mov rdi, 0               ; addr, 0 = don't care
    mov rsi, buf_len         ; len
    mov rdx, 3               ; prot, 3 = PROT_READ|PROT_WRITE
    mov r10, 34              ; flags, 34 = MAP_PRIVATE|MAP_ANONYMOUS
    mov r8 , -1              ; fd, -1 = no file
    mov r9 , 0               ; offset
    syscall
    ; we will assume allocation can't fail

    mov [rsp + 8], rax       ; place pointer to buffer in its place

    ; if we have only one argument, (the program name), then just print stdin
    cmp qword [rsp + 24], 1
    je print_stdin           ; print_stdin will exit after it's done

    mov qword [rsp], 1       ; we will start from second arg, it has index of 1
file_loop_body:
    ; put offset of current arg into rax
    mov rax, [rsp]
    mov rbx, 8
    mul rbx

    ; put pointer to current arg to rdi and dereference it
    lea rdi, [rsp + 32]
    add rdi, rax
    mov rdi, [rdi]
    
    ; open file
    mov rax, 2               ; syscall number, 2 = open
                             ; path is in rdi
    mov rsi, 0               ; flags, 0 = read only
    mov rdx, 0               ; mode, we don't create anything, so we don't care
    syscall

    cmp rax, 0               ; if return value less then 0, we faild
    jl failed_to_open_file

    mov [rsp + 16], rax      ; put the file descriptor in its place    

    mov rdi, rax             ; put the file descriptor into rdi
    mov rsi, [rsp + 8]       ; put pointer to buffer to rsi
    call print_file

    ; close the file after printing it
    mov rax, 3               ; syscall number, 3 = close
    mov rdi, [rsp + 16]      ; file descriptor
    syscall

    inc qword [rsp]          ; increment argument counter

    mov rax, [rsp]           ; put current arg into rax
    cmp rax, [rsp + 24]      ; compare it with argc    
    je file_loop_end         ; if it is greater or equal, then stop the loop

    jmp file_loop_body
file_loop_end:
    jmp exit_success
    
print_stdin:
    mov rdi, 0               ; file descriptor, 0 = stdin
    mov rsi, [rsp + 8]       ; put pointer to buffer to rsi
    call print_file

exit_success:
    mov rax, 60              ; syscall number, 60 = exit
    mov rdi, 0               ; exit code
    syscall

    


failed_to_open_file:
    mov rax, 1                           ; syscall number, 1 = write
    mov rdi, 2                           ; file descriptor, 2 = stderr
    mov rsi, failed_to_open_file_msg     ; pointer to data
    mov rdx, failed_to_open_file_msg_len ; size of the data
    syscall

    jmp exit_fail

failed_to_read_file:
    mov rax, 1                           ; syscall number, 1 = write
    mov rdi, 2                           ; file descriptor, 2 = stderr
    mov rsi, failed_to_read_file_msg     ; pointer to data
    mov rdx, failed_to_read_file_msg_len ; size of the data
    syscall

exit_fail:
    mov rax, 60                          ; syscall number, 60 = exit
    mov rdi, 1                           ; exit code
    syscall



; gets file descriptor through rdi
; gets pointer to buffer through rsi
print_file:
    push rdi               ; file descriptor   [rsp]

write_loop_body:
    ; write into the buffer
    mov rax, 0             ; syscall number, 0 = read
    mov rdi, [rsp]         ; file descriptor
    mov rdx, buf_len       ; length of the buffer
    ; pointer to buffer is already in rsi
    syscall

    cmp rax, 0
    jl failed_to_read_file ; if write returned negative number, error has occured
    je write_loop_end      ; if write returned 0, EOF is reached
    
    mov rdx, rax           ; number of bytes to write, from return value of read
    mov rax, 1             ; syscall number, 1 = write
    mov rdi, 1             ; file descriptor, 1 = stdout
    ; pointer to buffer is already in rsi
    syscall

    jmp write_loop_body    
write_loop_end:
    ; deallocate local variables
    add rsp, 8             ; remove file descriptor from the stack
    ret
