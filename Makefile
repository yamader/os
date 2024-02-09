OBJCOPY = objcopy --remove-section=.note.gnu.property
QEMU    = qemu-system-x86_64

xv6.img: mbr.img kernel.img
	dd if=/dev/zero of=$@ count=4096
	dd if=mbr.img of=$@ conv=notrunc
	dd if=kernel.img of=$@ seek=1 conv=notrunc

mbr.img:
	make -C boot mbr.bin
	$(OBJCOPY) -O binary boot/mbr.bin $@
	truncate -s 510 $@
	printf "\x55\xaa" >> $@

kernel.img:
	touch $@

clean:
	make -C boot clean
	make -C kernel clean
	rm -f *.img

qemu: xv6.img
	$(QEMU) -hda $< -monitor stdio

qemu-nox: xv6.img
	$(QEMU) -hda $< -nographic
