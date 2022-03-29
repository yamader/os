module loader.main;
import lib.elf;
import lib.memmap;
import lib.string;
import loader.efi;

extern(C):

enum YAMADOS_LOADER_VERSION = "v0.1.0";
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

void BytesCpy(ubyte* buf, ubyte* src, size_t len) {
  foreach(i; 0 .. len) buf[i] = src[i];
}

void BytesSet(ubyte* buf, size_t len, ubyte val) {
  foreach(i; 0 .. len) buf[i] = val;
}

EFI_STATUS ReadFile(wstring name)(EFI_FILE_PROTOCOL* file, void** buf) {
  EFI_STATUS status;

  const ulong file_info_s = EFI_FILE_INFO.sizeof + wchar.sizeof * name.length + 1;
  ubyte[file_info_s] file_info_buf = void;
  auto file_info = cast(EFI_FILE_INFO*)(file_info_buf.ptr);
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

EFI_STATUS GetMemMap(MemMap* memmap) {
  memmap.map_size = memmap.buf_size;

  return gBS.GetMemoryMap(
    &memmap.map_size,
    cast(EFI_MEMORY_DESCRIPTOR*)(memmap.buf),
    &memmap.key,
    &memmap.desc_size,
    &memmap.desc_ver);
}

EFI_STATUS UefiMain(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE* SystemTable) {
  EFI_STATUS status;

  gST = SystemTable;
  gBS = gST.BootServices;
  gRT = gST.RuntimeServices;

  // hello, world

  gST.ConOut.Reset(gST.ConOut, false);
  status = Print("yamadOS Loader : "w ~ YAMADOS_LOADER_VERSION ~ "\r\n\n"w);
  if(EFI_ERROR(status)) {
    Halt();
  }

  // get memory map

  enum size_t memmap_buf_size = 1024 * 16;

  MemMap memmap = void;
  ubyte[memmap_buf_size] memmap_buf = void;
  memmap.buf = memmap_buf.ptr;
  memmap.buf_size = memmap_buf_size;
  Print("Getting memory map ...\r\n"w);
  status = GetMemMap(&memmap);
  if(EFI_ERROR(status)) {
    Print("!! Error getting memory map : 0x%x\r\n"w, status);
    Halt();
  }

  // open GOP

  // load kernel

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
    Halt();
  }

  void* kernel_file_buf;
  Print("Reading kernel file ...\r\n"w);
  status = ReadFile!kernel_file_name(kernel_file, &kernel_file_buf);
  if(EFI_ERROR(status)) {
    Print("Error reading kernel file\r\n"w);
    Halt();
  }

  auto kernel_ehdr = cast(Elf64_Ehdr*)kernel_file_buf;
  auto kernel_phdr = cast(Elf64_Phdr*)(cast(UINTN)kernel_ehdr + kernel_ehdr.e_phoff);
  auto kernel_program_head = cast(void*)ulong.max;
  auto kernel_program_tail = cast(void*)0;
  foreach(i; 0 .. kernel_ehdr.e_phnum) if(kernel_phdr[i].p_type == P_TYPE.LOAD) {
    auto max(T)(T a, T b) { return a > b ? a : b; }
    auto min(T)(T a, T b) { return a < b ? a : b; }
    kernel_program_head = min(
      kernel_program_head, cast(void*)(kernel_phdr[i].p_vaddr));
    kernel_program_tail = max(
      kernel_program_tail, cast(void*)(kernel_phdr[i].p_vaddr + kernel_phdr[i].p_memsz));
  }

  ulong kernel_entry;
  Print("Loading kernel ...\r\n"w);
  status = gBS.AllocatePages(
    EFI_ALLOCATE_TYPE.AllocateAddress,
    EFI_MEMORY_TYPE.EfiLoaderData,
    (kernel_program_tail - kernel_program_head + 0xfff) / 0x1000,
    cast(EFI_PHYSICAL_ADDRESS*)&kernel_program_head);
  if(EFI_ERROR(status)) {
    Print("!! Error allocating kernel buffer : 0x%x\r\n"w, status);
    Halt();
  }
  foreach(i; 0 .. kernel_ehdr.e_phnum) if(kernel_phdr[i].p_type == P_TYPE.LOAD) {
    BytesCpy(
      cast(ubyte*)(kernel_phdr[i].p_vaddr),
      cast(ubyte*)(cast(ulong)kernel_ehdr + kernel_phdr[i].p_offset),
      kernel_phdr[i].p_filesz);
    BytesSet(
      cast(ubyte*)(kernel_phdr[i].p_vaddr + kernel_phdr[i].p_filesz),
      cast(ubyte*)(kernel_phdr[i].p_memsz - kernel_phdr[i].p_filesz),
      0);
  }
  kernel_entry = *cast(ulong*)(kernel_program_head + 24);

  Print("\r\nKernel loaded : 0x%x\r\n\n"w, kernel_entry);

  Print("Freeing kernel file buf ...\r\n"w);
  status = gBS.FreePool(kernel_file_buf);
  if(EFI_ERROR(status)) {
    Print("!! Error freeing kernel file buf : 0x%x\r\n"w, status);
    Halt();
  }

  // exit uefi boot services

  Print("Exiting uefi boot services ...\r\n"w);
  status = gBS.ExitBootServices(ImageHandle, memmap.key);
  if(status == EFI_STATUS.EFI_INVALID_PARAMETER) {
    Print("Updating memory map ...\r\n"w);
    status = GetMemMap(&memmap);
    if(EFI_ERROR(status)) {
      Print("!! Error updating memory map : 0x%x\r\n"w, status);
      Halt();
    }
    status = gBS.ExitBootServices(ImageHandle, memmap.key);
    if(EFI_ERROR(status)) {
      Print("!! Error exiting uefi boot services : 0x%x\r\n"w, status);
      Halt();
    }
  }

  // start kernel

  alias EntryPoint = int function(
    const MemMap*);

  auto kernel = cast(EntryPoint)kernel_entry;

  kernel(&memmap);

  Halt();

  return EFI_STATUS.EFI_SUCCESS;
}
