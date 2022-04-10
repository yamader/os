module loader.efi;

extern(C):
__gshared:

// Data Types

alias BOOLEAN = bool;
// only 64bit
alias INTN  = long;
alias UINTN = ulong;
//
alias INT8 = byte;
alias UINT8 = ubyte;
alias INT16 = short;
alias UINT16 = ushort;
alias INT32 = int;
alias UINT32 = uint;
alias INT64 = long;
alias UINT64 = ulong;
//alias INT128 = cent;
//alias UINT128 = ucent;
alias CHAR8 = char;
alias CHAR16 = wchar;
alias VOID = void;

alias EFI_HANDLE = VOID*;
alias EFI_EVENT = VOID*;
alias EFI_LBA = UINT64;
alias EFI_TPL = UINTN;

align(64)
struct EFI_GUID {
  uint buf0;
  ushort buf1, buf2;
  struct _ {
    ubyte buf0, buf1, buf2, buf3, buf4, buf5, buf6, buf7;
  } _ buf3;
}

enum EFI_STATUS : UINTN {
  // Success
  EFI_SUCCESS = 0UL,

  // Error
  EFI_LOAD_ERROR = 1UL << 63| 1,
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
  EFI_END_OF_FILE = 1UL << 63| 31,
  EFI_INVALID_LANGUAGE,
  EFI_COMPROMISED_DATA,
  EFI_IP_ADDRESS_CONFLICT,
  EFI_HTTP_ERROR,

  // Warning
  EFI_WARN_UNKNOWN_GLYPH = 1UL,
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

struct EFI_TABLE_HEADER {
  UINT64 Signature;
  UINT32 Revision;
  UINT32 HeaderSize;
  UINT32 CRC32;
  UINT32 Reserved;
}

struct EFI_SYSTEM_TABLE {
  EFI_TABLE_HEADER Hdr;
  CHAR16* FirmwareVendor;
  UINT32 FirmwareRevision;
  EFI_HANDLE ConsoleInHandle;
  EFI_SIMPLE_TEXT_INPUT_PROTOCOL* ConIn;
  EFI_HANDLE ConsoleOutHandle;
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* ConOut;
  EFI_HANDLE StandardErrorHandle;
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* StdErr;
  EFI_RUNTIME_SERVICES* RuntimeServices;
  EFI_BOOT_SERVICES* BootServices;
  UINTN NumberOfTableEntries;
  EFI_CONFIGURATION_TABLE* ConfigurationTable;
}

struct EFI_BOOT_SERVICES {
  EFI_TABLE_HEADER Hdr;
  void* buf1,buf2;
  EFI_ALLOCATE_PAGES AllocatePages;
  EFI_FREE_PAGES FreePages;
  EFI_GET_MEMORY_MAP GetMemoryMap;
  EFI_ALLOCATE_POOL AllocatePool;
  EFI_FREE_POOL FreePool;
  void* buf8, buf9, buf10, buf11, buf12, buf13,
    buf14, buf15, buf16, buf17;
  VOID* Reserved;
  void* buf19, buf20, buf21, buf22;
  EFI_IMAGE_LOAD LoadImage;
  EFI_IMAGE_START StartImage;
  EFI_EXIT Exit;
  EFI_IMAGE_UNLOAD UnloadImage;
  EFI_EXIT_BOOT_SERVICES ExitBootServices;
  void* buf28, buf29, buf30,
    buf31,buf32;
  EFI_OPEN_PROTOCOL OpenProtocol;
  EFI_CLOSE_PROTOCOL CloseProtocol;
  void* buf35, buf36;
  EFI_LOCATE_HANDLE_BUFFER LocateHandleBuffer;
  void* buf39, buf40, buf41;
  EFI_COPY_MEM CopyMem;
  EFI_SET_MEM SetMem;
  void* buf44;

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
    UINT32* DescriptorVersion);

  alias EFI_ALLOCATE_POOL = EFI_STATUS function(
    EFI_MEMORY_TYPE PoolType,
    UINTN Size,
    VOID** Buffer);

  alias EFI_FREE_POOL = EFI_STATUS function(
    VOID* Buffer);

  alias EFI_OPEN_PROTOCOL = EFI_STATUS function(
    EFI_HANDLE Handle,
    EFI_GUID* Protocol,
    VOID** Interface,
    EFI_HANDLE AgentHandle,
    EFI_HANDLE ControllerHandle,
    UINT32 Attributes);

  alias EFI_CLOSE_PROTOCOL = EFI_STATUS function(
    EFI_HANDLE Handle,
    EFI_GUID* Protocol,
    EFI_HANDLE AgentHandle,
    EFI_HANDLE ControllerHandle);

  alias EFI_IMAGE_LOAD = EFI_STATUS function(
    BOOLEAN BootPilicy,
    EFI_HANDLE ParentImageHandle,
    EFI_DEVICE_PATH_PROTOCOL* DevicePath,
    VOID* SourceBuffer,
    UINTN SourceSize,
    EFI_HANDLE* ImageHandle);

  alias EFI_IMAGE_START = EFI_STATUS function(
    EFI_HANDLE ImageHandle,
    UINTN* ExitDataSize,
    CHAR16** ExitData);

  // EFI_IMAGE_UNLOAD;

  alias EFI_EXIT = EFI_STATUS function(
    EFI_HANDLE ImageHandle,
    EFI_STATUS ExitStatus,
    UINTN ExitDataSize,
    CHAR16* ExitData);

  alias EFI_EXIT_BOOT_SERVICES = EFI_STATUS function(
    EFI_HANDLE ImageHandle,
    UINTN MapKey);

  alias EFI_LOCATE_HANDLE_BUFFER = EFI_STATUS function(
    EFI_LOCATE_SEARCH_TYPE SearchType,
    EFI_GUID* Protocol,
    VOID* SearchKey,
    UINTN* NoHandles,
    EFI_HANDLE** Buffer);

  alias EFI_COPY_MEM = void function(
    VOID* Destination,
    VOID* Source,
    UINTN Length);

  alias EFI_SET_MEM = void function(
    VOID* Buffer,
    UINTN Size,
    UINT8 Value);
}

alias EFI_IMAGE_UNLOAD = EFI_STATUS function(
  EFI_HANDLE ImageHandle);

struct EFI_RUNTIME_SERVICES {
  EFI_TABLE_HEADER Hdr;
  void* buf1, buf2, buf3, buf4,
    buf5, buf6,
    buf7, buf8, buf9,
    buf10;
  EFI_RESET_SYSTEM ResetSystem;
  void* buf12, buf13,
    buf14;

  alias EFI_RESET_SYSTEM = void function(
    EFI_RESET_TYPE ResetType,
    EFI_STATUS ResetStatus,
    UINTN DataSize,
    VOID* ResetData);
}

struct EFI_CONFIGURATION_TABLE {
  EFI_GUID VendorGuid;
  VOID* VendorTable;
}

// Boot Services

alias EFI_PHYSICAL_ADDRESS = UINT64;
alias EFI_VIRTUAL_ADDRESS = UINT64;

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

enum EFI_OPEN_PROTOCOL_ATTRIBUTES {
  BY_HANDLE_PROTOCOL            = 0x00000001,
  GET_PROTOCOL                  = 0x00000002,
  TEST_PROTOCOL                 = 0x00000004,
  BY_CHILD_CONTROLLER           = 0x00000008,
  BY_DRIVER                     = 0x00000010,
  EXCLUSIVE                     = 0x00000020,
}

enum EFI_LOCATE_SEARCH_TYPE {
  AllHandles,
  ByRegisterNotify,
  ByProtocol,
}

struct EFI_MEMORY_DESCRIPTOR {
  UINT32 Type;
  EFI_PHYSICAL_ADDRESS PhysicalStart;
  EFI_VIRTUAL_ADDRESS VirtualStart;
  UINT64 NumberOfPages;
  UINT64 Attribute;
}

// Runtime Services

enum EFI_RESET_TYPE {
  EfiResetCold,
  EfiResetWarm,
  EfiResetShutdown,
  EfiResetPlatformSpecific,
}

struct EFI_TIME {
  UINT16 Year;
  UINT8 Month;
  UINT8 Day;
  UINT8 Hour;
  UINT8 Minute;
  UINT8 Second;
  UINT8 Pad1;
  UINT32 Nanosecond;
  INT16 TimeZone;
  UINT8 Daylight;
  UINT8 Pad2;
}

// EFI Loaded Image

EFI_GUID gEfiLoadedImageProtocolGuid =
  {0x5b1b31a1,0x9562,0x11d2,{0x8e,0x3f,0x00,0xa0,0xc9,0x69,0x72,0x3b}};

struct EFI_LOADED_IMAGE_PROTOCOL {
  UINT32 Revision;
  EFI_HANDLE ParentHandle;
  EFI_SYSTEM_TABLE* SystemTable;
  EFI_HANDLE DeviceHandle;
  EFI_DEVICE_PATH_PROTOCOL* FilePath;
  VOID* Reserved;
  UINT32 LoadOptionsSize;
  VOID* LoadOptions;
  VOID* ImageBase;
  UINT64 ImageSize;
  EFI_MEMORY_TYPE ImageCodeType;
  EFI_MEMORY_TYPE ImageDataType;
  EFI_IMAGE_UNLOAD Unload;
}

// Device Path Protocol

struct EFI_DEVICE_PATH_PROTOCOL {
  UINT8 Type;
  UINT8 SubType;
  UINT8[2] Length;
}

// Console Support

struct EFI_SIMPLE_TEXT_INPUT_PROTOCOL {
  EFI_INPUT_RESET Reset;
  EFI_INPUT_READ_KEY ReadKeyStroke;
  EFI_EVENT WaitForKey;

  struct EFI_INPUT_KEY {
    UINT16 ScanCode;
    CHAR16 UnicodeChar;
  }

  alias EFI_INPUT_RESET = EFI_STATUS function(
    EFI_SIMPLE_TEXT_INPUT_PROTOCOL* This,
    BOOLEAN ExtendedVerfication);

  alias EFI_INPUT_READ_KEY = EFI_STATUS function(
    EFI_SIMPLE_TEXT_INPUT_PROTOCOL* This,
    EFI_INPUT_KEY* Key);
}

struct EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL {
  EFI_TEXT_RESET Reset;
  EFI_TEXT_STRING OutputString;
  void* buf2, buf3, buf4, buf5;
  EFI_TEXT_CLEAR_SCREEN ClearScreen;
  EFI_TEXT_SET_CURSOR_POSITION SetCursorPosition;
  EFI_TEXT_ENABLE_CURSOR EnableCursor;
  SIMPLE_TEXT_OUTPUT_MODE* Mode;

  struct SIMPLE_TEXT_OUTPUT_MODE {
    INT32 MaxMode;
    INT32 Mode;
    INT32 Attribute;
    INT32 CursorColumn;
    INT32 CursorRow;
    BOOLEAN CursorVisible;
  }

  alias EFI_TEXT_RESET = EFI_STATUS function(
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This,
    BOOLEAN ExtendedVerfication);

  alias EFI_TEXT_STRING = EFI_STATUS function(
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This,
    CHAR16* String);

  alias EFI_TEXT_CLEAR_SCREEN = EFI_STATUS function(
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This);

  alias EFI_TEXT_SET_CURSOR_POSITION = EFI_STATUS function(
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This,
    UINTN Column,
    UINTN Row);

  alias EFI_TEXT_ENABLE_CURSOR = EFI_STATUS function(
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL* This,
    BOOLEAN Visible);
}

EFI_GUID gEfiGraphicsOutputProtocolGuid =
  {0x9042a9de,0x23dc,0x4a38,{0x96,0xfb,0x7a,0xde,0xd0,0x80,0x51,0x6a}};

struct EFI_GRAPHICS_OUTPUT_PROTOCOL {
  void* buf0, buf1, buf2;
  EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE* Mode;

  struct EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE {
    uint MaxMode;
    uint Mode;
    EFI_GRAPHICS_OUTPUT_MODE_INFORMATION* Info;
    UINTN SizeOfInfo;
    EFI_PHYSICAL_ADDRESS FrameBufferBase;
    UINTN FrameBufferSize;
  }

  struct EFI_GRAPHICS_OUTPUT_MODE_INFORMATION {
    UINT32 Version;
    UINT32 HorizontalResolution;
    UINT32 VerticalResolution;
    EFI_GRAPHICS_PIXEL_FORMAT PixelFormat;
    EFI_PIXEL_BITMASK PixelInformation;
    UINT32 PixelsPerScanLine;
  }

  struct EFI_PIXEL_BITMASK {
    UINT32 RedMask;
    UINT32 GreenMask;
    UINT32 BlueMask;
    UINT32 ReservedMask;
  }
}

enum EFI_GRAPHICS_PIXEL_FORMAT {
  PixelRedGreenBlueReserved8BitPerColor,
  PixelBlueGreenRedReserved8BitPerColor,
  PixelBitMask,
  PixelBltOnly,
  PixelFormatMax
}

// Simple File System Protocol

EFI_GUID gEfiSimpleFileSystemProtocolGuid =
  {0x964e5b22,0x6459,0x11d2,{0x8e,0x39,0x00,0xa0,0xc9,0x69,0x72,0x3b}};

struct EFI_SIMPLE_FILE_SYSTEM_PROTOCOL {
  UINT64 Revision;
  EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_OPEN_VOLUME OpenVolume;

  alias EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_OPEN_VOLUME = EFI_STATUS function(
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL* This,
    EFI_FILE_PROTOCOL** Root);
}

// File Protocol

enum EFI_FILE_OPEN_MODE : ulong {
  READ                          = 0x0000000000000001,
  WRITE                         = 0x0000000000000002,
  CREATE                        = 0x8000000000000000,
}

enum EFI_FILE_OPEN_ATTRIBUTES : ulong {
  READ_ONLY                     = 0x0000000000000001,
  HIDDEN                        = 0x0000000000000002,
  SYSTEM                        = 0x0000000000000004,
  RESERVED                      = 0x0000000000000008,
  DIRECTORY                     = 0x0000000000000010,
  ARCHIVE                       = 0x0000000000000020,
  VALID_ATTR                    = 0x0000000000000037,
}

struct EFI_FILE_PROTOCOL {
  UINT64 Revision;
  EFI_FILE_OPEN Open;
  EFI_FILE_CLOSE Close;
  EFI_FILE_DELETE Delete;
  EFI_FILE_READ Read;
  EFI_FILE_WRITE Write;
  void* buf6, buf7;
  EFI_FILE_GET_INFO GetInfo;
  EFI_FILE_SET_INFO SetInfo;
  EFI_FILE_FLUSH Flush;
  void* buf11, buf12, buf13, buf14;

  alias EFI_FILE_OPEN = EFI_STATUS function(
    EFI_FILE_PROTOCOL* This,
    EFI_FILE_PROTOCOL** NewHandle,
    CHAR16* FileName,
    UINT64 OpenMode,
    UINT64 Attributes);

  alias EFI_FILE_CLOSE = EFI_STATUS function(
    EFI_FILE_PROTOCOL* This);

  alias EFI_FILE_DELETE = EFI_STATUS function(
    EFI_FILE_PROTOCOL* This);

  alias EFI_FILE_READ = EFI_STATUS function(
    EFI_FILE_PROTOCOL* This,
    UINTN* BufferSize,
    VOID* Buffer);

  alias EFI_FILE_WRITE = EFI_STATUS function(
    EFI_FILE_PROTOCOL* This,
    UINTN* BufferSize,
    VOID* Buffer);

  alias EFI_FILE_GET_INFO = EFI_STATUS function(
    EFI_FILE_PROTOCOL* This,
    EFI_GUID* InformationType,
    UINTN* BufferSize,
    VOID* Buffer);

  alias EFI_FILE_SET_INFO = EFI_STATUS function(
    EFI_FILE_PROTOCOL* This,
    EFI_GUID* InformationType,
    UINTN BufferSize,
    VOID* Buffer);

  alias EFI_FILE_FLUSH = EFI_STATUS function(
    EFI_FILE_PROTOCOL* This);
}

EFI_GUID gEfiFileInfoGuid =
  {0x09576e92,0x6d3f,0x11d2,{0x8e,0x39,0x00,0xa0,0xc9,0x69,0x72,0x3b}};

struct EFI_FILE_INFO {
  UINT64 Size;
  UINT64 FileSize;
  UINT64 PhysicalSize;
  EFI_TIME CreateTime;
  EFI_TIME LastAccessTime;
  EFI_TIME ModificationTime;
  UINT16 Attribute;
  CHAR16[] FileName;
}
