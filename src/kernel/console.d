module kernel.console;
import kernel.framebuf;
import kernel.graphics;
import kernel.font;

void putCharAt(
    ref const FBFullColor fb,
    uint startX, uint startY,
    char chr,
    const RGBColor color = RGBColor(0xff, 0xff, 0xff),
    ref const SimpleFont font = FontConsole) {
  auto fp = cast(ubyte*)font.getChr(chr);
  foreach(dy; 0 .. font.height)
    foreach(dx; 0 .. font.width)
      if(fp[dy] & (0x80u >> dx))
        fb.write(startX + dx, startY + dy, color);
}

struct Console {
  enum BGColor = RGBColor(0, 0, 0);
  enum FGColor = RGBColor(0, 0xff, 0);

  this(
      ref const FBFullColor fb,
      Vec2D!uint pos, Vec2D!uint size,
      ref const SimpleFont font = FontConsole) {
    this.fb = fb;
    this.font = &font;
    this.flush;
  }

  void flush() {
    fb.FillRect(pos, size, BGColor);
  }

  void putChar(char c) {
  }

private:
  // cursor
  Vec2D!uint pos,
             size;
  const FBFullColor fb;
  const SimpleFont* font;
}
