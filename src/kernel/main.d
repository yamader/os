module kernel.main;
import lib.string;
import loader.memmap;
import kernel.framebuf;
import kernel.graphics;
import kernel.font;
import kernel.console;

enum YAMADOS_KERNEL_VERSION = "v0.1.0";

extern(C):

enum stack_size = 1024 * 1024;
enum PRINT_STRING_BUF_SIZE = 1000;

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

__gshared {
  Console kConsole = void;
}

auto printk(T...)(string fmt, T args) {
  static if(args.length > 0) {
    char[PRINT_STRING_BUF_SIZE] buf;
    sprintf(buf, fmt, args);
    return kConsole.putStr(cast(string)buf);
  } else {
    return kConsole.putStr(fmt);
  }
}

void kernel_main(
    ref const MemMap memmap,
    ref const FBConf fb_efi) {
  auto fb = FBFullColor(&fb_efi);
  kConsole = Console(
    &fb,
    Vec2D!uint(0, 0),
    Vec2D!uint(fb.horiz, fb.vert),
    cast(SimpleFont*)&FontConsole);

  printk("yamadOS Kernel : " ~ YAMADOS_KERNEL_VERSION ~ "\n\n");
}
