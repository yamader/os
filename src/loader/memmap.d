module loader.memmap;
import loader.efi: UINTN, UINT32;

extern(C):

struct MemMap {
  UINTN map_size;
  UINTN buf_size;
  void* buf;
  UINTN key;
  UINTN desc_size;
  UINT32 desc_ver;
}

//import loader.efi: EFI_MEMORY_DESCRIPTOR;
//alias MemDesc = EFI_MEMORY_DESCRIPTOR;
struct MemDesc {
  import loader.efi: UINT64, EFI_PHYSICAL_ADDRESS, EFI_VIRTUAL_ADDRESS;

  EfiMemType type;
  EFI_PHYSICAL_ADDRESS physStart;
  EFI_VIRTUAL_ADDRESS virtStart;
  UINT64 numPages;
  UINT64 attr;
}

enum EfiMemType: UINT32 {
  ReservedMemoryType,
  LoaderCode,
  LoaderData,
  BootServicesCode,
  BootServicesData,
  RuntimeServicesCode,
  RuntimeServicesData,
  ConventionalMemory,
  UnusableMemory,
  ACPIReclaimMemory,
  ACPIMemoryNVS,
  MemoryMappedIO,
  MemoryMappedIOPortSpace,
  PalCode,
  PersistentMemory,
  UnacceptedMemoryType,
  MaxMemoryType
}

bool CanUse(EfiMemType t) {
  return
    t == EfiMemType.BootServicesCode ||
    t == EfiMemType.BootServicesData ||
    t == EfiMemType.ConventionalMemory;
}
