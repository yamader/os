module lib.memmap;
import loader.efi: UINTN;

extern(C):

struct MemMap {
  UINTN map_size;
  UINTN buf_size;
  void* buf;
  UINTN key;
  UINTN desc_size;
  uint desc_ver;
}
