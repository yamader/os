module kernel.paging;

// Paging

enum ulong
  PageSize4K = 4096,
  PageSize2M = 512 * PageSize4K,
  PageSize1G = 512 * PageSize2M,
  PageDirs = 64;

__gshared {
  align(PageSize4K):
    ulong[512] pml4tab;
    ulong[512] pdptab;
    ulong[512][PageDirs] pagedir;
}

extern(C) void setcr3(ulong v);
void initPaging() {
  pml4tab[0] = cast(ulong)&pdptab[0] | 0x003;
  foreach(i; 0 .. PageDirs) {
    pdptab[i] = cast(ulong)&pagedir[i] | 0x003;
    foreach(j; 0 .. 512) {
      pagedir[i][j] = i*PageSize1G + j*PageSize2M | 0x083;
    }
  }
  auto pml4tabHd = cast(ulong)&pml4tab[0];
  setcr3(pml4tabHd); // インラインアセンブラが使えない
}

// x64 Segment

__gshared {
  SegmDesc[3] gdt = void;
}

union SegmDesc {
  ulong storage;

  struct {
    import std.bitmanip: bitfields;
    mixin(bitfields!(
      ulong,  "limitLow",       16,
      ulong,  "baseLow",        16,
      ulong,  "baseMiddle",     8,
      Type,   "type",           4,
      ulong,  "systemSegment",  1,
      ulong,  "descriptorPrivilegeLevel", 2,
      ulong,  "present",        1,
      ulong,  "limitHigh",      4,
      ulong,  "available",      1,
      ulong,  "longMode",       1,
      ulong,  "defaultOperationSize", 1,
      ulong,  "granularity",    1,
      ulong,  "baseHigh",       8,
    ));
  }

  enum Type {
    Upper8Bytes   = 0x0,
    LDT           = 0x2,
    TSSAvailable  = 0x9,
    TSSBusy       = 0xb,
    CallGate      = 0xc,
    InterruptGate = 0xd,
    TrapGate      = 0xe,

    RW  = 0x2,
    RE  = 0xa,
  }
}

extern(C) void ret(); // temp
void initSegment() {
  gdt[0].storage = 0;
  setCSegm(gdt[1], SegmDesc.Type.RE, 0, 0, 0xfffff);
  setDSegm(gdt[2], SegmDesc.Type.RW, 0, 0, 0xfffff);

  struct GDTR {
   align(1):
    ushort limit;
    ulong offset;
  }
  GDTR gdtr = { gdt.sizeof - 1, cast(ulong)&gdt[0] };
  version(X86_64) asm {
    lgdt gdtr;
  }

  // misc register
  auto _ret = cast(ulong)&ret; // temp
  ushort
    _0 = 0, // ?!?!
    ss = 2 << 3,
    cs = 1 << 3;
  version(X86_64) asm {
    mov DS, _0;
    mov ES, _0;
    mov FS, _0;
    mov GS, _0;
    mov SS, ss;
    push cs;
    //push next;
    push _ret; // ラベルだとなんか動かない
    db 0x48;
    retf;
  //next:;
  }
}

void setCSegm(ref SegmDesc desc,
              SegmDesc.Type descType,
              uint descPrivilegeLevel,
              uint base,
              uint limit) {
  desc.storage = 0;
  with(desc) {
    baseLow       = base & 0xffff;
    baseMiddle    = (base >> 16) & 0xff;
    baseHigh      = (base >> 24) & 0xf;
    limitLow      = limit & 0xffff;
    limitHigh     = (limit >> 16) & 0xf;
    type          = descType;
    systemSegment = 1;
    descriptorPrivilegeLevel = descPrivilegeLevel;
    present       = 1;
    available     = 0;
    longMode      = 1;
    defaultOperationSize = 0; // should be 0 when longMode == 1
    granularity   = 1;
  }
}

void setDSegm(ref SegmDesc desc,
              SegmDesc.Type descType,
              uint descPrivilegeLevel,
              uint base,
              uint limit) {
  setCSegm(desc, descType, descPrivilegeLevel, base, limit);
  desc.longMode = 0;
  desc.defaultOperationSize = 1;
}
