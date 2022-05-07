extern(C):

version(assert)
void __assert() {}

void __chkstk() {} // loader

void* memset(void* _dst, int _val, size_t len) {
  auto dst = cast(ubyte*)_dst;
  auto val = cast(ubyte)_val;
  while(len--) *dst++ = val;
  return _dst;
}

void* memcpy(void* _dst, void* _src, size_t len) {
  auto dst = cast(ubyte*)_dst;
  auto src = cast(ubyte*)_src;
  while(len--) *dst++ = *src++;
  return _dst;
}
