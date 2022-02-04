module main;
import efi;

extern(C):

EFI_SYSTEM_TABLE* gST;
EFI_BOOT_SERVICES* gBS;
EFI_RUNTIME_SERVICES* gRT;

EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE* SystemTable) {
  EFI_STATUS status;

  gST = SystemTable;
  gBS = gST.BootServices;
  gRT = gST.RuntimeServices;

  gST.ConOut.OutputString(gST.ConOut, cast(wchar*)"hello, world (from Dlang)"w);
  if(EFI_ERROR(status)) {
    return status;
  }

  while(true) asm { hlt; }
}
