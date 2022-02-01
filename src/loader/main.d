module main;
import efi;

extern(C):

EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE* SystemTable) {
  SystemTable.ConOut.OutputString(SystemTable.ConOut, cast(wchar*)"hello, world (from Dlang)"w);
  while(true) asm { hlt; }
}
