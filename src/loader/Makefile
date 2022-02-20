LDC         := ldc2
LD          := x86_64-w64-mingw32-ld
LDCFLAGS    += --mtriple=x86_64-w64-mingw32 --betterC -I=..
LDFLAGS     += -e ${ENTRYPOINT} --subsystem 10 -static

TARGET      := loader.efi
ENTRYPOINT  := efi_main
OBJS        := main.obj efi.obj string.obj

all: ${TARGET}

${TARGET}: ${OBJS} Makefile
	${LD} ${LDFLAGS} -o $@ ${OBJS}

%.obj: %.d Makefile
	${LDC} ${LDCFLAGS} --of=$@ -c $<

clean:
	rm -f ${TARGET} ${OBJS}

.PHONY: all clean
