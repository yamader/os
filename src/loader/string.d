module loader.string;

int sprintf(C, T...)(C[] buf_a, immutable(C)[]fmt_a, T args) {
  C* buf = buf_a.ptr,
     fmt = cast(C*)fmt_a.ptr;
  int len = 0;
  foreach(arg; args) {
    bool zeroflag;
    int width;
    format: while(*fmt) {
      if(*fmt != '%') {
        *buf++ = *fmt++;
        ++len;
        continue;
      }
      zeroflag = width = 0;
      ++fmt;
      if(*fmt == '0') {
        zeroflag = true;
        ++fmt;
      }
      if('0' <= *fmt && *fmt <= '9') {
        width = *fmt++ - '0';
      }
      switch(*fmt++) {
        case 'd':
          len += sprintf_udec(arg, buf, zeroflag, width);
          break format;
        case 'x':
          len += sprintf_uhex(arg, buf, zeroflag, width);
          break format;
        case 'b':
          len += sprintf_ubin(arg, buf, zeroflag, width);
          break format;
        case 'c':
          *buf++ = arg;
          ++len;
          break format;
        default:
      }
    }
  }
  do {
    *buf++ = *fmt++;
    ++len;
  } while(*fmt);
  return len;
}

enum Digits_ulong_dec = 20,
     Digits_ulong_hex = 16,
     Digits_ulong_bin = 64;

int sprintf_udec(ulong val, char* buf, bool zero, ubyte width) {
  int len = 0;
  char[Digits_ulong_dec] str = 0;
  ubyte cur = std.length - 1;
  if(val == 0) {
    *cur-- = '0';
  } else {
    
  }
}

int sprintf_uhex(ulong val, char* buf, bool zero, ubyte width) {
  int len = 0;
  char[Digits_ulong_hex] str = 0;
}

int sprintf_ubin(ulong val, char* buf, bool zero, ubyte width) {
  int len = 0;
  char[Digits_ulong_bin] str = 0;
}
