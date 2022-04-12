LDC         := ldc2
LD          := ld.lld
LDCFLAGS    += --mtriple=x86_64-unknown-none-elf --betterC -I=..
LDFLAGS     += --entry=${ENTRYPOINT} --image-base=${IMG_BASE} --static

TARGET      := kernel.elf
ENTRYPOINT  := kernel
IMG_BASE    := 0x100000
OBJS        := main.o framebuf.o support.o

all: ${TARGET}

release: LDCFLAGS += --O3 --release
release: LDFLAGS += --strip-all
release: all Makefile

${TARGET}: ${OBJS} Makefile
	${LD} ${LDFLAGS} -o $@ ${OBJS}

%.o: %.d Makefile
	${LDC} ${LDCFLAGS} --of=$@ -c $<

%.o: ../lib/%.d Makefile
	${LDC} ${LDCFLAGS} --of=$@ -c $<

clean:
	rm -f *.o

.PHONY: all release clean
