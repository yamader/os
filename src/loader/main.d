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

EFI_STATUS OpenRootDir(EFI_HANDLE ImageHandle, EFI_FILE_PROTOCOL** root) {
  EFI_STATUS status;

  EFI_LOADED_IMAGE_PROTOCOL* img;
  status = gBS.OpenProtocol(
    ImageHandle,
    &gEfiLoadedImageProtocolGuid,
    cast(void**)&img,
    ImageHandle,
    null,
    EFI_OPEN_PROTOCOL_ATTRIBUTES.BY_HANDLE_PROTOCOL);
  if(EFI_ERROR(status)) {
    Print("!! Error opening Loaded Image Protocol : 0x%x\r\n"w, status);
    return status;
  }

  EFI_SIMPLE_FILE_SYSTEM_PROTOCOL* fs;
  status = gBS.OpenProtocol(
    img.DeviceHandle,
    &gEfiSimpleFileSystemProtocolGuid,
    cast(void**)&fs,
    ImageHandle,
    null,
    EFI_OPEN_PROTOCOL_ATTRIBUTES.BY_HANDLE_PROTOCOL);
  if(EFI_ERROR(status)) {
    Print("!! Error opening Simple File System Protocol : 0x%x\r\n"w, status);
    return status;
  }

  return fs.OpenVolume(fs, root);
}

EFI_STATUS UefiMain(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE* SystemTable) {
  EFI_STATUS status;

  gST = SystemTable;
  gBS = gST.BootServices;
  gRT = gST.RuntimeServices;

  // hello, world
  gST.ConOut.Reset(gST.ConOut, false);
  status = Print("Loading yamadOS ...\r\n"w);
  if(EFI_ERROR(status)) {
    return status;
  }

  // load kernel file
  EFI_FILE_PROTOCOL* root_dir;
  status = OpenRootDir(ImageHandle, &root_dir);
  if(EFI_ERROR(status)) {
    Print("!! Error opening root dir\r\n");
    return status;
  }

  // catch
  Halt();
  return EFI_STATUS.EFI_SUCCESS;
}
