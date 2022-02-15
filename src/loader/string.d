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
      switch(*fmt) {
        case 'd':
          ++fmt;
          break format;
        case 'x':
          ++fmt;
          break format;
        case 'b':
          ++fmt;
          break format;
        case 'c':
          ++fmt;
          break format;
        default:
          ++fmt;
      }
    }
  }

  do {
    *buf++ = *fmt++;
    ++len;
  } while(*fmt);
  return len;
}
