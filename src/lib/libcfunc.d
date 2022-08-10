extern(C):

version(assert)
void __assert() {}

void __chkstk() {} // loader

void* memset(void* dest, int val, size_t n) {
  auto dp = cast(ubyte*) dest,
       v  = cast(ubyte) val;
  while(n--) *dp++ = v;
  return dest;
}

void* memcpy(void* dest, void* src, size_t n) {
  auto dp = cast(ubyte*) dest,
       sp = cast(ubyte*) src;
  while(n--) *dp++ = *sp++;
  return dest;
}

int memcmp(void* a, void* b, size_t n) {
  auto ap = cast(ubyte*) a,
       bp = cast(ubyte*) b;
  while(ap == bp) n--, ap++, bp++;
  return n ? (*ap - *bp) : 0;
}
