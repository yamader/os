module loader.main;
import lib.elf;
import lib.memmap;
import lib.string;
import loader.efi;

extern(C):

enum PRINT_STRING_BUF_SIZE = 100;

__gshared {
  EFI_SYSTEM_TABLE* gST = void;
  EFI_BOOT_SERVICES* gBS = void;
  EFI_RUNTIME_SERVICES* gRT = void;
}

void Halt() {
  while(true) asm { hlt; }
}

EFI_STATUS Print(T...)(wstring fmt, T args) {
  static if(args.length > 0) {
    wchar[PRINT_STRING_BUF_SIZE] buf;
    sprintf(buf, fmt, args);
    return gST.ConOut.OutputString(gST.ConOut, buf.ptr);
  } else {
    return gST.ConOut.OutputString(gST.ConOut, cast(wchar*)(fmt.ptr));
  }
}

EFI_STATUS UefiMain(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE* SystemTable) {
  EFI_STATUS status = void;

  gST = SystemTable;
  gBS = gST.BootServices;
  gRT = gST.RuntimeServices;

  gST.ConOut.Reset(gST.ConOut, false);
  status = Print("hello, world (from Dlang)\r\n"w);
  if(EFI_ERROR(status)) {
    return status;
  }

  Halt();
  return EFI_STATUS.EFI_SUCCESS;
}
