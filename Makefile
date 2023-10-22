
all: out/cat out/fizzbuzz out/hello-world out/is-even

out/%.o: %.asm out
	yasm -f elf64 -o $@ -g dwarf2 $<

out/%: out/%.o
	ld -o $@ $<

out:
	mkdir -p out

clean:
	rm -rf ./out
