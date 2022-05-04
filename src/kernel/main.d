module kernel.main;
import loader.memmap;
import kernel.framebuf;
import kernel.graphics;

extern(C):

enum stack_size = 1024 * 1024;

__gshared {
  ulong stack_base;
  ubyte[stack_size] stack_buf;
}

void kernel_entry() {
  stack_base = cast(ulong)stack_buf.ptr + stack_size;
  asm {
    mov RSP, stack_base;
    mov RBP, RSP;
    call kernel_main;
  end:
    hlt;
    jmp end;
  }
}

void kernel_main(
    ref const MemMap memmap,
    ref const FBConf fb_efi) {
  auto fb = FBFullColor(&fb_efi);
  fb.FlushScr;
}
