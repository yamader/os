module loader.efi;

extern(C):

// Data Types

// only 64bit
alias INTN  = long;
alias UINTN = ulong;
//
alias EFI_STATUS = UINTN;
alias EFI_HANDLE = void*;
alias EFI_EVENT = void*;
alias EFI_LBA = ulong;
alias EFI_TPL = UINTN;

enum Status {
  EFU_SUCCESS = 0,
  EFI_LOAD_ERROR = 1<<64| 1,
  EFI_INVALID_PARAMETER,
  EFI_UNSUPPORTED,
  EFI_BAD_BUFFER_SIZE,
  EFI_BUFFER_TOO_SMALL,
  EFI_NOT_READY,
  EFI_DEVICE_ERROR,
  EFI_WRITE_PROTECTED,
  EFI_OUT_OF_RESOURCES,
  EFI_VOLUME_CORRUPTED,
  EFI_VOLUME_FULL,
  EFI_NO_MEDIA,
  EFI_MEDIA_CHANGED,
  EFI_NOT_FOUND,
  EFI_ACCESS_DENIED,
  EFI_NO_RESPONSE,
  EFI_NO_MAPPING,
  EFI_TIMEOUT,
  EFI_NOT_STARTED,
  EFI_ALREADY_STARTED,
  EFI_ABORTED,
  EFI_ICMP_ERROR,
  EFI_TFTP_ERROR,
  EFI_PROTOCOL_ERROR,
  EFI_INCOMPATIBLE_VERSION,
  EFI_SECURITY_VIOLATION,
  EFI_CRC_ERROR,
  EFI_END_OF_MEDIA,
  EFI_END_OF_FILE = 1<<64| 31,
  EFI_INVALID_LANGUAGE,
  EFI_COMPROMISED_DATA,
  EFI_IP_ADDRESS_CONFLICT,
  EFI_HTTP_ERROR,
  EFI_WARN_UNKNOWN_GLYPH = 1,
  EFI_WARN_DELETE_FAILURE,
  EFI_WARN_WRITE_FAILURE,
  EFI_WARN_BUFFER_TOO_SMALL,
  EFI_WARN_STALE_DATA,
  EFI_WARN_FILE_SYSTEM,
  EFI_WARN_RESET_REQUIRED,
}

// Macros

bool EFI_ERROR(EFI_STATUS status) {
  return cast(INTN)(status) < 0;
}

// EFI System Table

alias EFI_TABLE_HEADER = byte[24];

struct EFI_SYSTEM_TABLE {
  EFI_TABLE_HEADER Hdr;
  wchar* FirmwareVendor;
  uint FirmwareRevision;
  EFI_HANDLE ConsoleInHandle;
  void* buf4;
  EFI_HANDLE ConsoleOutHandle;
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* ConOut;
  EFI_HANDLE StandardErrorHandle;
  void* buf8;
  EFI_RUNTIME_SERVICES* RuntimeServices;
  EFI_BOOT_SERVICES* BootServices;
  UINTN NumberOfTableEntries;
  void* buf12;
}
struct EFI_BOOT_SERVICES {
  EFI_TABLE_HEADER Hdr;
  void* buf1,buf2;
  EFI_ALLOCATE_PAGES AllocatePages;
  EFI_FREE_PAGES FreePages;
  EFI_GET_MEMORY_MAP GetMemoryMap;
  EFI_ALLOCATE_POOL AllocatePool;
  EFI_FREE_POOL FreePool;
  void* buf8,buf9,buf10,buf11,buf12,buf13,buf14,buf15,buf16,buf17,buf18,buf19,buf20,buf21;
  EFI_IMAGE_LOAD LoadImage;
  EFI_IMAGE_START StartImage;
  EFI_EXIT Exit;
  EFI_IMAGE_UNLOAD UnloadImage;
  EFI_EXIT_BOOT_SERVICES ExitBootServices;
  void* buf27,buf28,buf29,buf30,buf31,buf32,buf33,buf34,buf35,buf36,buf37,buf38,buf39,buf40;
  EFI_COPY_MEM CopyMem;
  EFI_SET_MEM SetMem;
  void* buf43;
}
struct EFI_RUNTIME_SERVICES {
  EFI_TABLE_HEADER Hdr;
  void* buf1,buf2,buf3,buf4,buf5,buf6,buf7,buf8,buf9,buf10;
  EFI_RESET_SYSTEM ResetSystem;
  void* buf12,buf13,buf14;
}

// Boot Services

alias EFI_PHYSICAL_ADDRESS = ulong;

enum EFI_ALLOCATE_TYPE {
  AllocateAnyPages,
  AllocateMaxAddress,
  AllocateAddress,
  MaxAllocateType
}
enum EFI_MEMORY_TYPE {
  EfiReservedMemoryType,
  EfiLoaderCode,
  EfiLoaderData,
  EfiBootServicesCode,
  EfiBootServicesData,
  EfiRuntimeServicesCode,
  EfiRuntimeServicesData,
  EfiConventionalMemory,
  EfiUnusableMemory,
  EfiACPIReclaimMemory,
  EfiACPIMemoryNVS,
  EfiMemoryMappedIO,
  EfiMemoryMappedIOPortSpace,
  EfiPalCode,
  EfiPersistentMemory,
  EfiUnacceptedMemoryType,
  EfiMaxMemoryType
}

struct EFI_MEMORY_DESCRIPTOR {
  uint Type;
  EFI_PHYSICAL_ADDRESS PhysicalStart;
  ulong NumberOfPages;
  ulong Attributes;
}

alias EFI_ALLOCATE_PAGES = EFI_STATUS function(
  EFI_ALLOCATE_TYPE Type,
  EFI_MEMORY_TYPE MemoryType,
  UINTN Pages,
  EFI_PHYSICAL_ADDRESS* Memory);
alias EFI_FREE_PAGES = EFI_STATUS function(
  EFI_PHYSICAL_ADDRESS Memory,
  UINTN Pages);
alias EFI_GET_MEMORY_MAP = EFI_STATUS function(
  UINTN* MemoryMapSize,
  EFI_MEMORY_DESCRIPTOR* MemoryMap,
  UINTN* MapKey,
  UINTN* DescriptorSize,
  uint* DescriptorVersion);
alias EFI_ALLOCATE_POOL = EFI_STATUS function(
  EFI_MEMORY_TYPE PoolType,
  UINTN Size,
  void** Buffer);
alias EFI_FREE_POOL = EFI_STATUS function(
  void* Buffer);
alias EFI_IMAGE_LOAD = EFI_STATUS function(
  bool BootPilicy,
  EFI_HANDLE ParentImageHandle,
  EFI_DEVICE_PATH_PROTOCOL* DevicePath,
  void* SourceBuffer,
  UINTN SourceSize,
  EFI_HANDLE* ImageHandle);
alias EFI_IMAGE_START = EFI_STATUS function(
  EFI_HANDLE ImageHandle,
  UINTN* ExitDataSize,
  wchar** ExitData);
alias EFI_IMAGE_UNLOAD = EFI_STATUS function(
  EFI_HANDLE ImageHandle);
alias EFI_EXIT = EFI_STATUS function(
  EFI_HANDLE ImageHandle,
  EFI_STATUS ExitStatus,
  UINTN ExitDataSize,
  wchar* ExitData);
alias EFI_EXIT_BOOT_SERVICES = EFI_STATUS function(
  EFI_HANDLE ImageHandle,
  UINTN MapKey);
alias EFI_COPY_MEM = void function(
  void* Destination,
  void* Source,
  UINTN Length);
alias EFI_SET_MEM = void function(
  void* Buffer,
  UINTN Size,
  ubyte Value);

// Runtime Services

enum EFI_RESET_TYPE {
  EfiResetCold,
  EfiResetWarm,
  EfiResetShutdown,
  EfiResetPlatformSpecific
}

alias EFI_RESET_SYSTEM = void function(
  EFI_RESET_TYPE ResetType,
  EFI_STATUS ResetStatus,
  UINTN DataSize,
  void* ResetData);

// Device Path Protocol

struct EFI_DEVICE_PATH_PROTOCOL {
  ubyte Type;
  ubyte SubType;
  ubyte[2] Length;
}

// Console Support

struct EFI_SIMPLE_TEXT_INPUT_PROTOCOL {
  EFI_INPUT_RESET Reset;
  EFI_INPUT_READ_KEY ReadKeyStroke;
  EFI_EVENT WaitForKey;
}
struct EFI_INPUT_KEY {
  ushort ScanCode;
  wchar UnicodeChar;
}
struct EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL {
  EFI_TEXT_RESET Reset;
  EFI_TEXT_STRING OutputString;
  void* buf2,buf3,buf4,buf5;
  EFI_TEXT_CLEAR_SCREEN ClearScreen;
  EFI_TEXT_SET_CURSOR_POSITION SetCursorPosition;
  EFI_TEXT_ENABLE_CURSOR EnableCursor;
  SIMPLE_TEXT_OUTPUT_MODE* Mode;
}
struct SIMPLE_TEXT_OUTPUT_MODE {
  int MaxMode;
  int Mode;
  int Attribute;
  int CursorColumn;
  int CursorRow;
  bool CursorVisible;
}

alias EFI_INPUT_RESET = EFI_STATUS function(
  EFI_SIMPLE_TEXT_INPUT_PROTOCOL* This,
  bool ExtendedVerfication);
alias EFI_INPUT_READ_KEY = EFI_STATUS function(
  EFI_SIMPLE_TEXT_INPUT_PROTOCOL* This,
  EFI_INPUT_KEY* Key);
alias EFI_TEXT_RESET = EFI_STATUS function(
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This,
  bool ExtendedVerfication);
alias EFI_TEXT_STRING = EFI_STATUS function(
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This,
  wchar* String);
alias EFI_TEXT_CLEAR_SCREEN = EFI_STATUS function(
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This);
alias EFI_TEXT_SET_CURSOR_POSITION = EFI_STATUS function(
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This,
  UINTN Column,
  UINTN Row);
alias EFI_TEXT_ENABLE_CURSOR = EFI_STATUS function(
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This,
  bool Visible);
