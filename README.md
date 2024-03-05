# assembly-things
A couple of small programs I wrote in x86_64 assembly for Linux

- `hello-world.asm`: Prints `Hello, World!` to stdout
- `hello-world-c.asm`: Links to libc to print `Hello, World!`
- `fizzbuzz.asm`: A FizzBuzz program
- `cat.asm`: Prints files. Can con***cat***inate multiple files. If there are no arguments, prints from stdin.
- `is-even.asm`: Exit with 0 or 1 depending on the number provided being even or odd

Build: 
```shell
$ yasm -f elf64 -o cat.o cat.asm  # assemble with assembler
$ ld -o cat cat.o                 # link with linker
$ ./cat cat.asm                   # and it can print its own source code
```
