LDC := ldc2
LD := x86_64-w64-mingw32-ld
LDCFLAGS += -mtriple=x86_64-w64-mingw32 -betterC
LDFLAGS += -e ${ENTRYPOINT} -static

TARGET := loader.efi
ENTRYPOINT := uefi_main
OBJS := main.obj

all: ${TARGET}

${TARGET}: ${OBJS} makefile
	${LD} ${LDFLAGS} -o $@ ${OBJS}

%.obj: %.d
	${LDC} -c ${LDCFLAGS} --of=$@ $<

clean:
	rm -f ${TARGET} ${OBJS}

.PHONY: all clean
