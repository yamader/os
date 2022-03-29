module loader.string;

private
void memcpy(T)(T* buf, T* src, size_t len) {
  foreach(i; 0 .. len) buf[i] = src[i];
}

// 0を含まない長さを返す
int sprintf(C, T...)(C[] buf_a, immutable(C)[]fmt_a, T args) {
  C* buf = buf_a.ptr,
     fmt = cast(C*)fmt_a.ptr;
  int len = 0;
  foreach(arg; args) {
    int width;
    bool zeroflag, formatted;
    while(*fmt) {
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
          len += sprintf_u!(C, Digits.udec)
            (arg, &buf, zeroflag, cast(ubyte)(width));
          formatted = true;
          break;
        case 'x':
          len += sprintf_u!(C, Digits.uhex)
            (arg, &buf, zeroflag, cast(ubyte)(width));
          formatted = true;
          break;
        case 'b':
          len += sprintf_u!(C, Digits.ubin)
            (arg, &buf, zeroflag, cast(ubyte)(width));
          formatted = true;
          break;
        case 'c':
          *buf++ = cast(C)arg;
          ++len;
          formatted = true;
          break;
        default:
          formatted = false;
      }
      if(formatted) break;
    }
  }
  auto nokori = fmt_a.ptr + fmt_a.length - fmt;
  memcpy(buf, fmt, nokori);
  len += nokori;
  *(buf + nokori) = 0;
  return len;
}

enum Digits : ubyte {
  udec = 20,
  uhex = 16,
  ubin = 64, // 4n
}

private // 末尾に0を置かないので単体では危険
int sprintf_u(C, Digits buf_s)(ulong val, C** str, bool zero, ubyte width) {
  int len = 0;
  C[buf_s] _buf = void;
  C* buf = &_buf[$-1];
  if(val == 0) {
    *buf-- = '0';
    ++len;
  } else {
    if(width) {
      while(len < width && val) {
        // val, buf, len
        static if(buf_s == Digits.udec) mixin(parse_digit_dec);
        else static if(buf_s == Digits.uhex) mixin(parse_digit_hex);
        else static if(buf_s == Digits.ubin) mixin(parse_digit_bin);
        else break;
      }
    } else {
      while(val) {
        // val, buf, len
        static if(buf_s == Digits.udec) mixin(parse_digit_dec);
        else static if(buf_s == Digits.uhex) mixin(parse_digit_hex);
        else static if(buf_s == Digits.ubin) mixin(parse_digit_bin);
        else break;
      }
    }
  }
  while(len < width) {
    *buf-- = zero ? '0' : ' ';
    ++len;
  }
  memcpy(*str, ++buf, len);
  *str += len;
  return len;
}

private {
  // val, buf, len
  enum parse_digit_dec = "{
    *buf-- = val % 10 + '0';
    val /= 10;
    ++len;
  }";
  enum parse_digit_hex = "{
    *buf = val % 16;
    val /= 16;
    if(*buf < 10) *buf += '0';
    else *buf += 'a' - 0xa;
    --buf;
    ++len;
  }";
  enum parse_digit_bin = "{
    byte d16 = val % 16;
    val /= 16;
    *buf-- = (d16 & 0b0001) ? '1' : '0';
    *buf-- = (d16 & 0b0010) ? '1' : '0';
    *buf-- = (d16 & 0b0100) ? '1' : '0';
    *buf-- = (d16 & 0b1000) ? '1' : '0';
    len += 4;
  }";
}
