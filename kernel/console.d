module kernel.console;
import kernel.framebuf;
import kernel.graphics;
import kernel.font;

private
void memcpy(T)(T* dst, T* src, size_t len) {
  import kernel.support: memcpy;
  memcpy(cast(void*)dst, cast(void*)src, len);
}

struct Console {
  enum BGColor = RGBColor(0, 0, 0);
  enum FGColor = RGBColor(0, 0xff, 0);
  enum ConsoleBufCol = 1920 / 8 + 1; // temp
  enum ConsoleBufRow = 1080 / 16; //

  this(
      FBFullColor* fb,
      Vec2D!uint pos,
      Vec2D!uint size,
      SimpleFont* font) {
    this.fb = fb;
    this.pos = pos;
    this.size = size;
    this.font = font;
    this.row = size.y / font.height;
    this.col = size.x / font.width;
    this.curRow = this.curCol = 0;
    this.zeroX = pos.x;
    this.zeroY = pos.y;
    this.curX = zeroX;
    this.curY = zeroY;
    this.flush;
  }

  void flush() {
    FillRect(*fb, pos, size, BGColor);
  }

  void putChr(char c) {
    switch(c) {
      case '\0':
        buf[curRow][curCol] = '\0';
        break;
      case '\n':
        buf[curRow][curCol] = '\0';
        newLine();
        break;
      default:
        buf[curRow][curCol++] = c;
        PutCharAt(*fb, curX, curY, c, FGColor, *font);
        curX += font.width;
    }
    if(col - 1 <= curCol) {
      buf[curRow][curCol] = '\0';
      newLine();
    }
  }

  void putStr(string s) {
    foreach(c; s) {
      if(!c) break;
      putChr(c);
    }
  }

private:
  Vec2D!uint pos,
             size;
  FBFullColor* fb;
  SimpleFont* font;
  char[ConsoleBufCol][ConsoleBufRow] buf;
  uint row, col,
       curRow, curCol,
       zeroX, zeroY, //
       curX, curY; // used in putChr()

  void newLine() {
    if(curRow < row - 1) {
      curRow++;
    } else {
      flush();
      foreach(i; 0 .. row - 1) {
        curX = zeroX;
        curY = zeroY + font.height * i;
        memcpy(buf[i].ptr, buf[i + 1].ptr, col + 1);
        foreach(c; buf[i]) {
          if(!c) break;
          PutCharAt(*fb, curX, curY, c, FGColor, *font);
          curX += font.width;
        }
      }
    }
    curCol = 0;
    curX = zeroX;
    curY = zeroY + font.height * curRow;
  }
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
