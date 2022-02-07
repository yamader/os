export

MAKEOPTS        ?= --warn-undefined-variables
MKISOFS         := xorriso -as mkisofs

TARGET          := bootable.iso
WORK_DIR        := dist
KERNEL_SRC      := src/kernel
KERNEL_BIN      := kernel.elf
LOADER_SRC      := src/loader
LOADER_BIN      := loader.efi

KERNEL_PATH     := ${KERNEL_SRC}/${KERNEL_BIN}
LOADER_PATH     := ${LOADER_SRC}/${LOADER_BIN}

all: ${TARGET}

${TARGET}: ${KERNEL_PATH} ${LOADER_PATH}
	[ ! -f ${TARGET} ] || mv ${TARGET} ${TARGET}.bak
	rm -rf ${WORK_DIR} && mkdir -p ${WORK_DIR}

	dd if=/dev/zero of=efi.img bs=1k count=2880
	mformat -i efi.img ::
	mmd -i efi.img ::/EFI
	mmd -i efi.img ::/EFI/BOOT
	mcopy -i efi.img ${LOADER_PATH} ::/EFI/BOOT/BOOTX64.EFI

	cp efi.img ${WORK_DIR}/efi.img
	cp ${KERNEL_PATH} ${WORK_DIR}/kernel.elf
	${MKISOFS} -V "YAMADOS" -e efi.img -o ${TARGET} ${WORK_DIR}

	@echo
	@echo "DONE : ${TARGET}"
	@echo

${KERNEL_PATH}: ${KERNEL_SRC}
	${MAKE} ${MAKEOPTS} -C ${KERNEL_SRC}

${LOADER_PATH}: ${LOADER_SRC}
	${MAKE} ${MAKEOPTS} -C ${LOADER_SRC}

clean:
	rm -f ${TARGET}
	rm -rf ${WORK_DIR}
	${MAKE} ${MAKEOPTS} -C ${KERNEL_SRC} clean
	${MAKE} ${MAKEOPTS} -C ${LOADER_SRC} clean

.PHONY: all clean
