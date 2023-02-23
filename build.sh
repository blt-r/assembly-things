#!/bin/sh
set -e

mkdir -p out

file=$(basename -- "$1")
name=$(sed -e 's/\.asm$//' -e 's/_/-/' <<< $file)

yasm -f elf64 -o out/$name.o -g dwarf2 $file 
ld -o out/$name out/$name.o
