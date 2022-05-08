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
