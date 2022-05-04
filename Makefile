export

MKISOFS         := xorriso -as mkisofs
OVMF_CODE       ?= /usr/share/edk2-ovmf/OVMF_CODE.fd

TARGET          := bootable.iso
WORK_DIR        := work
KERNEL_SRC      := src/kernel
KERNEL_BIN      := kernel.elf
LOADER_SRC      := src/loader
LOADER_BIN      := loader.efi

KERNEL_PATH     := ${KERNEL_SRC}/${KERNEL_BIN}
LOADER_PATH     := ${LOADER_SRC}/${LOADER_BIN}

all: ${TARGET}

release: RELEASE := yes
release: all Makefile

run: ${TARGET} Makefile
	qemu-system-x86_64 -bios ${OVMF_CODE} -cdrom ${TARGET}

ESP := ${WORK_DIR}/iso/esp.img
${TARGET}: ${KERNEL_PATH} ${LOADER_PATH} Makefile
	[ ! -f ${TARGET} ] || mv ${TARGET} ${TARGET}.bak
	rm -rf ${WORK_DIR}/iso && mkdir -p ${WORK_DIR}/iso

	dd if=/dev/zero of=${ESP} bs=1M count=128
	mkfs.fat -n "YAMADOS_ESP" ${ESP}
	mmd -i ${ESP} ::EFI ::EFI/BOOT
	mcopy -i ${ESP} ${LOADER_PATH} ::EFI/BOOT/BOOTX64.EFI
	mcopy -i ${ESP} ${KERNEL_PATH} ::kernel.elf

	${MKISOFS} -V "YAMADOS" \
		-iso-level 3 -full-iso9660-filenames \
		-eltorito-alt-boot -e esp.img -no-emul-boot \
		-o ${TARGET} ${WORK_DIR}/iso

	@echo
	@echo "DONE : ${TARGET}"
	@echo

${KERNEL_PATH}: ${KERNEL_SRC}
	@if [ -n "${RELEASE}" ]; then \
		${MAKE} ${MAKEFLAGS} -C ${KERNEL_SRC} release; \
	else \
		${MAKE} ${MAKEFLAGS} -C ${KERNEL_SRC} all; \
	fi

${LOADER_PATH}: ${LOADER_SRC}
	@if [ -n "${RELEASE}" ]; then \
		${MAKE} ${MAKEFLAGS} -C ${LOADER_SRC} release; \
	else \
		${MAKE} ${MAKEFLAGS} -C ${LOADER_SRC} all; \
	fi

clean:
	rm -rf ${WORK_DIR}
	${MAKE} ${MAKEFLAGS} -C ${KERNEL_SRC} clean
	${MAKE} ${MAKEFLAGS} -C ${LOADER_SRC} clean

.PHONY: all release run clean
