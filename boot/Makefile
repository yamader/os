mbr.bin: mbr.o
	$(LD) -e start -Ttext 0x7c00 -o $@ $^

clean:
	rm -f *.{bin,o}
