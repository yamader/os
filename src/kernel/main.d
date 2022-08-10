module kernel.main;
import lib.string;
import loader.memmap;
import kernel.paging;
import kernel.mem;
import kernel.framebuf;
import kernel.graphics;
import kernel.font;
import kernel.console;

enum YAMADOS_KERNEL_VERSION = "v0.1";

extern(C):

//
// Kernel Initialize
//

enum stack_size = 1024 * 1024; // bytes

__gshared {
  ulong stack_base = void;
  ubyte[stack_size] stack_buf = void;
}

void kernel_entry() {
  // UEFIが用意したスタックも空き領域として使用する為
  stack_base = cast(ulong)stack_buf.ptr + stack_size;
  version(X86_64) asm {
    mov RSP, stack_base;
    mov RBP, RSP;
    call kernel_main;
  end:
    hlt;
    jmp end;
  }
}

//
// Kernel Main
//

enum PRINT_STRING_BUF_SIZE = 1000;

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
  printk("kernel stack : 0x%x\n", cast(ulong)stack_base);

  printk("memmap : 0x%x\n", cast(ulong)&memmap);
  with(memmap) printk(
`  size      : %d
  buf_ptr   : 0x%x
  buf_size  : %d
  desc_size : %d
`, map_size, cast(ulong)buf, buf_size, desc_size);

  initSegment;
  printk("\ngdt : 0x%x\n", cast(ulong)&gdt);
  printk("  gdt[0] { %x }\n", gdt[0].storage);
  printk("  gdt[1] { %x }\n", gdt[1].storage);
  printk("  gdt[2] { %x }\n", gdt[2].storage);

  printk("\npml4tab head : 0x%x\n", cast(ulong)&pml4tab[0]);
  initPaging;
}
