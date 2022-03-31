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

${TARGET}: ${KERNEL_PATH} ${LOADER_PATH} Makefile
	[ ! -f ${TARGET} ] || mv ${TARGET} ${TARGET}.bak
	rm -rf ${WORK_DIR}/iso && mkdir -p ${WORK_DIR}/iso

	dd if=/dev/zero of=efi.img bs=1k count=2880
	mformat -i efi.img ::
	mmd -i efi.img ::/EFI
	mmd -i efi.img ::/EFI/BOOT
	mcopy -i efi.img ${LOADER_PATH} ::/EFI/BOOT/BOOTX64.EFI
	mcopy -i efi.img ${KERNEL_PATH} ::/kernel.elf

	cp efi.img ${WORK_DIR}/iso/efi.img
	${MKISOFS} -V "YAMADOS" -e efi.img -o ${TARGET} ${WORK_DIR}/iso

	@echo
	@echo "DONE : ${TARGET}"
	@echo

${KERNEL_PATH}: ${KERNEL_SRC}
	@if [ -n "${RELEASE}" ]; then \
		${MAKE} ${MAKEFLAGS} -C ${KERNEL_SRC} release; \
	else \
		${MAKE} ${MAKEFLAGS} -C ${KERNEL_SRC}; \
	fi

${LOADER_PATH}: ${LOADER_SRC}
	@if [ -n "${RELEASE}" ]; then \
		${MAKE} ${MAKEFLAGS} -C ${LOADER_SRC} release; \
	else \
		${MAKE} ${MAKEFLAGS} -C ${LOADER_SRC}; \
	fi

clean:
	rm -rf ${WORK_DIR}
	${MAKE} ${MAKEFLAGS} -C ${KERNEL_SRC} clean
	${MAKE} ${MAKEFLAGS} -C ${LOADER_SRC} clean

.PHONY: all release run clean
