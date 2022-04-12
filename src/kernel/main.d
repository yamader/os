module kernel.main;
import lib.memmap;
import lib.framebuf;

extern(C):

enum stack_size = 1024 * 1024;

__gshared {
  ubyte[stack_size] stack_buf;
}

void kernel() {
  ulong stack_base = cast(ulong)stack_buf.ptr + stack_size;
  asm {
    mov RSP, stack_base;
    call kernel_main;
  }
  while(true) asm { hlt; }
}

void kernel_main(
    ref const MemMap memmap,
    ref const FBConf fb_efi) {
  auto fb = FBFullColor(&fb_efi);
  while(true) asm { hlt; }
}
