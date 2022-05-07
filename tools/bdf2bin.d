#!/usr/bin/env rdmd

import std;

enum FontLen = 256;

enum Help = `
  usage: bdf2bin.d input output
`;

void die(string msg) {
  Help.writeln;
  throw new StringException(msg);
}

void main(string[] args) {
  args.writeln;
  if(args.length != 3) die("Invalid params number");

  auto fin = File(args[1], "r");
  auto fout = File(args[2], "w");
  scope(exit) {
    fin.close;
    fout.close;
  }

  ubyte fbbx, fbby;
  byte fbbxoff, fbbyoff;
  while(true) {
    auto row = fin.readln.chomp;
    if(row.startsWith("FONTBOUNDINGBOX")) {
      auto a = row[16..$].split.map!(to!byte);
      fbbx = a[0],
      fbby = a[1],
      fbbxoff = a[2],
      fbbyoff = a[3];
      break;
    } else if(!row.length)
      die("FONTBOUNDINGBOX not found");
  }

  ubyte bytesPerLine = (fbbx + 7) / 8;
  auto font = new ubyte[][][](FontLen, fbby, bytesPerLine);

  byte bbx, bby, bbxoff, bbyoff;
  int fcur, phase = 0;
  while(true) {
    auto row = fin.readln.chomp;

    final switch(phase) {
      case 0: {
        if(row.startsWith("STARTCHAR"))
          phase++;
      } break;

      case 1: {
        if(row.startsWith("ENCODING")) {
          fcur = row[9..$].to!uint;
          if(fcur >= FontLen) phase = 0;
        }
        if(row.startsWith("BBX")) {
          auto a = row[4..$].split.map!(to!byte);
          bbx = a[0],
          bby = a[1],
          bbxoff = a[2],
          bbyoff = a[3];
        }
        if(row.startsWith("BITMAP"))
          phase++;
      } break;

      case 2: {
        auto hexStr2BitArr(string s) {
          auto h2d(char c) {
            return ('0' <= c && c <= '9')
              ? c - '0'
              : 0xA + c - 'A';
          }
          ubyte[] ret;
          foreach(d; s.toUpper.split("").map!(a => h2d(a[0]))) {
            ret ~= [
              d & 0b1000 ? 1 : 0,
              d & 0b0100 ? 1 : 0,
              d & 0b0010 ? 1 : 0,
              d & 0b0001 ? 1 : 0,
            ];
          }
          return ret;
        }

        auto offx = fbbxoff + bbxoff,
             offy = (fbby + fbbyoff) - (bby + bbyoff);
        if(offx < 0 || offy < 0) die("BBX cannot overflow FBBX");

        auto data = [hexStr2BitArr(row)];
        foreach(_; 1 .. bby)
          data ~= hexStr2BitArr(fin.readln.chomp);
        foreach(i; 0 .. bby)
          foreach(j; 0 .. bbx)
            if(data[i][j])
              font[fcur][i + offy][(j + offx) / 8] |=
                0x80u >> (j + offx) % 8;

        phase = 0;
      } break;
    }

    if(!row.length) break;
  }

  fout.rawWrite([fbbx, fbby, bytesPerLine]);
  fout.rawWrite(font.join.join);
}
