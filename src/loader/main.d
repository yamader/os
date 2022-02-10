module loader.main;
import lib.elf;
import lib.memmap;
import loader.efi;

extern(C):

__gshared {
  EFI_SYSTEM_TABLE* gST = void;
  EFI_BOOT_SERVICES* gBS = void;
  EFI_RUNTIME_SERVICES* gRT = void;
}

void Halt() {
  while(true) asm { hlt; }
}

EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE* SystemTable) {
  EFI_STATUS status = void;

  gST = SystemTable;
  gBS = gST.BootServices;
  gRT = gST.RuntimeServices;

  status = gST.ConOut.OutputString(gST.ConOut, cast(wchar*)"hello, world (from Dlang)"w);
  if(EFI_ERROR(status)) {
    return status;
  }

  Halt();
  return EFI_STATUS.EFI_SUCCESS;
}
