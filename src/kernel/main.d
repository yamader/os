module kernel.main;
import lib.memmap;

extern(C):

enum stack_size = 1024 * 1024;

__gshared {
  ubyte[stack_size] stack_buf;
}

void kernel() {
  asm {
    mov stack_buf + stack_size, RSP;
    call kernel_main;
  }
  while(true) asm { hlt; }
}

void kernel_main(MemMap* memmap) {
  while(true) asm { hlt; }
}
