module loader.string;

int sprintf(T...)(size_t buf_s, char[buf_s] buf_a, string fmt_a, T args) {
  char* buf = buf_a.ptr,
        fmt = fmt_a.ptr;
  int len = 0;

  foreach(arg; args) {
    bool zeroflag;
    byte width;
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

  while(*buf++ = *fmt++) ++len;
  return len;
}
