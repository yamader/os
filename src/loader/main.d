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

EFI_STATUS ReadFile(wstring name)(EFI_FILE_PROTOCOL* file, void** buf) {
  EFI_STATUS status;

  const ulong file_info_s = EFI_FILE_INFO.sizeof + wchar.sizeof * name.length + 1;
  ubyte[file_info_s] file_info_buf = void;
  EFI_FILE_INFO* file_info = cast(EFI_FILE_INFO*)(file_info_buf.ptr);
  status = file.GetInfo(
    file, &gEfiFileInfoGuid, cast(ulong*)&file_info_s, file_info_buf.ptr);
  if(EFI_ERROR(status)) {
    Print("!! Error getting info of file "w ~ name ~ " : 0x%x\r\n"w, status);
    return status;
  }

  status = gBS.AllocatePool(
    EFI_MEMORY_TYPE.EfiLoaderData, file_info.FileSize, buf);
  if(EFI_ERROR(status)) {
    Print("!! Error allocating buffer on memory : 0x%x\r\n"w, status);
    return status;
  }

  return file.Read(file, &file_info.FileSize, *buf);
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
    Halt();
  }

  // load kernel file

  enum kernel_file_name = "\\kernel.elf"w;

  EFI_FILE_PROTOCOL* root_dir;
  Print("Opening root dir ...\r\n"w);
  status = OpenRootDir(ImageHandle, &root_dir);
  if(EFI_ERROR(status)) {
    Print("Error opening root dir\r\n"w);
    Halt();
  }

  EFI_FILE_PROTOCOL* kernel_file;
  Print("Opening kernel file ...\r\n"w);
  status = root_dir.Open(
    root_dir, &kernel_file, cast(wchar*)kernel_file_name, EFI_FILE_OPEN_MODE.READ, 0);
  if(EFI_ERROR(status)) {
    Print("!! Error opening kernel file : 0x%x\r\n"w, status);
    return status;
  }

  void* kernel_file_buf;
  Print("Reading kernel file ...\r\n"w);
  status = ReadFile!kernel_file_name(kernel_file, &kernel_file_buf);
  if(EFI_ERROR(status)) {
    Print("Error reading kernel file\r\n"w);
    Halt();
  }

  // catch

  Halt();
  return EFI_STATUS.EFI_SUCCESS;
}
