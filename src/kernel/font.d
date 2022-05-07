module kernel.font;

extern(C):

alias FontConsole = _binary_ter_u16b_bin_start;

private extern {
  const SimpleFont _binary_ter_u16b_bin_start;
}

struct SimpleFont {
  const ubyte width,
              height,
              bytesPerLine;

private:
  const ubyte[256] data;
}

void* GetChr(ref const SimpleFont f, char c) {
  with(f)
    return cast(void*)data.ptr + (bytesPerLine * height) * c;
}
