module lib.elf;

struct Elf64_Ehdr {
  ubyte[16] e_ident;
  ushort    e_type;
  ushort    e_machine;
  uint      e_version;
  ulong     e_entry;
  ulong     e_phoff;
  ulong     e_shoff;
  uint      e_flags;
  ushort    e_ehsize;
  ushort    e_phentsize;
  ushort    e_phnum;
  ushort    e_shentsize;
  ushort    e_shnum;
  ushort    e_shstrndx;
}

struct Elf64_Phdr {
  uint      p_type;
  uint      p_flags;
  ulong     p_offset;
  ulong     p_vaddr;
  ulong     p_paddr;
  ulong     p_filesz;
  ulong     p_memsz;
  ulong     p_align;
}

enum P_TYPE : uint {
  NULL = 0,
  LOAD,
  DYNAMIC,
  INTERP,
  NOTE,
  SHLIB,
  PHDR,
  TLS,
}
