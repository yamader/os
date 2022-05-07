module kernel.console;
import kernel.framebuf;
import kernel.graphics;
import kernel.font;

struct Console {
  enum BGColor = RGBColor(0, 0, 0);
  enum FGColor = RGBColor(0, 0xff, 0);

  this(
      ref const FBFullColor fb,
      Vec2D!uint pos,
      Vec2D!uint size,
      ref const SimpleFont font) {
    this.fb = &fb;
    this.pos = pos;
    this.size = size;
    this.font = &font;
    this.flush;
  }

  void flush() {
    FillRect(*fb, pos, size, BGColor);
  }

  void putChar(char c) {
    PutCharAt(*fb, 0, 0, c, FGColor, *font);
  }

private:
  // cursor
  Vec2D!uint pos,
             size;
  const FBFullColor* fb;
  const SimpleFont* font;
}

void PutCharAt(
    ref const FBFullColor fb,
    uint offx,
    uint offy,
    char chr,
    const RGBColor color,
    ref const SimpleFont font) {
  auto fp = cast(ubyte*)GetChr(font, chr);
  foreach(dy; 0 .. font.height)
    foreach(dx; 0 .. font.width)
      if(fp[dy] & (0x80u >> dx))
        fb.write(offx + dx, offy + dy, color);
}
