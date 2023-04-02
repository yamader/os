module kernel.font;

extern(C):

// objcopied font assets
extern immutable {
  SimpleFont ter_u16b;
}

alias FontConsole = ter_u16b;

struct SimpleFont {
  const ubyte width, height, bytesPerLine;

 private:
  const ubyte[256] data;
}

void* GetChr(ref const SimpleFont f, char c) {
  with(f)
    return cast(void*)data.ptr + (bytesPerLine * height) * c;
}
