LDC         := ldc2
LD          := x86_64-w64-mingw32-ld
LDCFLAGS    += -mtriple=x86_64-w64-mingw32 -betterC -I=..
LDFLAGS     += -static --subsystem 10 -e ${ENTRYPOINT}

TARGET      := loader.efi
ENTRYPOINT  := efi_main
OBJS        := main.obj efi.obj

all: ${TARGET}

${TARGET}: ${OBJS} Makefile
	${LD} ${LDFLAGS} -o $@ ${OBJS}

%.obj: %.d
	${LDC} -c ${LDCFLAGS} --of=$@ $<

clean:
	rm -f ${TARGET} ${OBJS}

.PHONY: all clean
