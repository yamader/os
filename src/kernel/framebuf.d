module kernel.framebuf;

extern(C):

enum ColorFmt {
  RGB,
  BGR,
  Unknown,
}

struct FBConf {
  void* Base;
  ColorFmt PixFmt;
  uint PixVert,
       PixHoriz,
       PixScanLine;
}

struct RGBColor {
  ubyte R, G, B;
}

struct FBFullColor {
  const uint vert, horiz;
  void delegate(
    const uint x,
    const uint y,
    const RGBColor c) write;

  this(const FBConf* conf) {
    this.conf = conf;
    this.vert = conf.PixVert;
    this.horiz = conf.PixHoriz;
    final switch(conf.PixFmt) {
      case ColorFmt.RGB: this.write = &WriteRGB; break;
      case ColorFmt.BGR: this.write = &WriteBGR; break;
      case ColorFmt.Unknown: this.write = &WriteNop; break;
    }
  }

private:
  const FBConf* conf;

  auto PixelAt(
      const uint x,
      const uint y) {
    return cast(ubyte*)conf.Base + 4 * (conf.PixScanLine * y + x);
  }

  void WriteRGB(
      const uint x,
      const uint y,
      const RGBColor c) {
    auto pix = PixelAt(x, y);
    pix[0] = c.R;
    pix[1] = c.G;
    pix[2] = c.B;
  }

  void WriteBGR(
      const uint x,
      const uint y,
      const RGBColor c) {
    auto pix = PixelAt(x, y);
    pix[0] = c.B;
    pix[1] = c.G;
    pix[2] = c.R;
  }

  void WriteNop(
      const uint x,
      const uint y,
      const RGBColor c) {}
}
