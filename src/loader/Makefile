LDC         := ldc2
LINK        := lld-link
LDCFLAGS    += --mtriple=x86_64-unknown-windows-coff --betterC -I=..
LINKFLAGS   += /subsystem:efi_application /entry:${ENTRYPOINT}

TARGET      := loader.efi
ENTRYPOINT  := UefiMain
OBJS        := main.obj efi.obj string.obj libcfunc.obj

all: ${TARGET}

release: LDCFLAGS += --O3 --release
release: all Makefile

${TARGET}: ${OBJS} Makefile
	${LINK} ${LINKFLAGS} /out:$@ ${OBJS}

%.obj: %.d Makefile
	${LDC} ${LDCFLAGS} --of=$@ -c $<

%.obj: ../lib/%.d Makefile
	${LDC} ${LDCFLAGS} --of=$@ -c $<

clean:
	rm -f *.obj

.PHONY: all release clean
