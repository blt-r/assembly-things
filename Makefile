
all: out/hello-world out/cat out/fizzbuzz out/is-even out/hello-world-c

out/%.o: %.asm out
	yasm -f elf64 -o $@ -g dwarf2 $<

out/%: out/%.o
	ld -o $@ $<

out/hello-world-c: out/hello-world-c.o
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -o $@ $<

out:
	mkdir -p out

clean:
	rm -rf ./out
