all: bootable.iso

bootable.iso: src/kernel/kernel.elf src/loader/loader.efi
	touch bootable.iso

src/kernel/kernel.elf:
	${MAKE} -C src/kernel

src/loader/loader.efi:
	${MAKE} -C src/loader

clean:
	rm -f bootable.iso
	${MAKE} -C src/kernel clean
	${MAKE} -C src/loader clean

.PHONY: all clean
