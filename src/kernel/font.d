module kernel.font;

extern(C):

alias FontConsole = _binary_ter_u16b_bin_start;

private extern {
  const SimpleFont _binary_ter_u16b_bin_start;
}

struct SimpleFont {
  const ubyte width,
              height;
  private const ubyte[] data;

  void* getChr(char c) const {
    return cast(void*)data.ptr + (width * height) * c;
  }
}
