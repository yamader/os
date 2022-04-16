extern(C):

version(assert)
void __assert() {}

void* memset(void* buf, int val, size_t len) {
  auto s = cast(ubyte*)buf;
  while(len--)
    *s++ = cast(ubyte)val;
  return buf;
}
