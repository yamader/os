module efi;

extern(C):

alias EFI_STATUS = ulong;
alias EFI_HANDLE = void*;
alias EFI_TEXT_STRING = EFI_STATUS function(EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This,
                                            wchar* String);

struct EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL {
  byte[8] Reset;
  EFI_TEXT_STRING OutputString;
  byte[8] TestString;
  byte[8] QueryMode;
  byte[8] SetMode;
  byte[8] SetAttribute;
  byte[8] ClearScreen;
  byte[8] SetCursorPosition;
  byte[8] EnableCursor;
  byte[8] Mode;
}

struct EFI_SYSTEM_TABLE {
  byte[24] Hdr;
  byte[8] FirmwareVendor;
  byte[4] FirmwareRevision;
  byte[8] ConsoleInHandle;
  byte[8] ConIn;
  byte[8] ConsoleOutHandle;
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* ConOut;
  byte[8] StandardErrorHandle;
  byte[8] StdErr;
  byte[8] RuntimeServices;
  byte[8] BootServices;
  byte[8] NumberOfTableEntries;
  byte[8] ConfigurationTable;
}
