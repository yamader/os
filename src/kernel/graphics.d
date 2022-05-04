module kernel.graphics;
import kernel.framebuf;

struct Vec2D(T) {
  T x, y;

  bool opEquals(const Vec2D v) const {
    return this.x == v.x && this.y == v.y;
  }
}

void FillRect(ref const FBFullColor fb,
              const Vec2D!uint start,
              const Vec2D!uint size,
              const RGBColor c) {
  foreach(y; start.y .. start.y + size.y)
    foreach(x; start.x .. start.x + size.x)
      fb.write(x, y, c);
}

void FlushScr(ref const FBFullColor fb,
              const RGBColor c = RGBColor(0, 0, 0)) {
  FillRect(fb, Vec2D!uint(0, 0), Vec2D!uint(fb.horiz, fb.vert), c);
}
