module loader.main;
import lib.memmap;
import loader.efi;

extern(C):

__gshared {
  EFI_SYSTEM_TABLE* gST;
  EFI_BOOT_SERVICES* gBS;
  EFI_RUNTIME_SERVICES* gRT;
}

void Halt() {
  while(true) asm { hlt; }
}

EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE* SystemTable) {
  EFI_STATUS status;

  gST = SystemTable;
  gBS = gST.BootServices;
  gRT = gST.RuntimeServices;

  status = gST.ConOut.OutputString(gST.ConOut, cast(wchar*)"hello, world (from Dlang)"w);
  if(EFI_ERROR(status)) {
    return status;
  }

  Halt();
  return Status.EFI_SUCCESS;
}
