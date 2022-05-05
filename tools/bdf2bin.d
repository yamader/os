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
  if(args.length != 3) die("Invalid params number");

  auto fin = File(args[1], "r");
  auto fout = File(args[2], "w");
  scope(exit) {
    fin.close;
    fout.close;
  }

  ubyte fbbx, fbby, xoff, yoff;
  while(true) {
    auto row = fin.readln.chomp;
    if(row.startsWith("FONTBOUNDINGBOX")) {
      auto a = row[16..$].split.map!(to!int);
      fbbx = a[0],
      fbby = a[1],
      xoff = a[2],
      yoff = a[3];
      break;
    } else if(!row.length)
      die("FONTBOUNDINGBOX not found");
  }

  ubyte bytesPerLine = (fbbx + 7) / 8;
  auto data = new ubyte[bytesPerLine][fbby][FontLen];

  ubyte[][] chr;
  uint fcur, bbw, bbh, bbxoff0x, bbyoff0y,
       fcnt = 0, phase = 0;
  while(true) {
    auto row = fin.readln.chomp;

    if(phase == 0) {
      if(row.startsWith("STARTCHAR")) {
        chr = [];
        phase++;
      }
    }

    if(phase == 1) {
      if(row.startsWith("ENCODING"))
        fcur = row[9..$].to!uint;
      if(row.startsWith("BBX")) {
        auto a = row[4..$].split.map(to!int);
        bbw = a[0],
        bbh = a[1],
        bbxoff0x = a[2],
        bbxoff0y = a[3];
      }
      if(row.startsWith("BITMAP"))
        phase++;
    }

    if(phase == 2) {
      if(!row.startsWith("ENDCHAR")) {
        chr ~= row.split("").map!(to!ubyte);
      } else {
        // chr to data
        fcnt++;
        phase = 0;
      }
    }

    if(fcnt >= FontLen || !row.length) break;
  }

  fout.rawWrite([fbbx, fbby, bytesPerLine]);
  fout.rawWrite(data);
}
