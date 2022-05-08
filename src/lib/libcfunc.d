extern(C):

version(assert)
void __assert() {}

void __chkstk() {} // loader

void* memset(void* dst, int val, size_t len) {
  auto _dst = dst;
  while(len--)
    *cast(ubyte*)dst++ = cast(ubyte)val;
  return _dst;
}

void* memcpy(void* dst, void* src, size_t len) {
  auto _dst = dst;
  while(len--)
    *cast(ubyte*)dst++ = *cast(ubyte*)src++;
  return _dst;
}
