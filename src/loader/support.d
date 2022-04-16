extern(C):

void __chkstk() {}

void* memset(void* buf, int val, size_t len) {
  auto s = cast(ubyte*)buf;
  while(len--)
    *s++ = cast(ubyte)val;
  return buf;
}
