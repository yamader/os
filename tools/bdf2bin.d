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

  alias chrData = ubyte[][];
  chrData[FontLen] data;

  uint fbbx, fbby, xoff, yoff;
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

  auto chr = new ubyte[][](fbby, fbbx);
  uint fcur, bbw, bbh, bbxoff0x, bbyoff0y,
       fcnt = 0, phase = 0;
  while(true) {
    auto row = fin.readln.chomp;
    if(phase == 0 && row.startsWith("STARTCHAR"))
      phase++;
    else if(phase == 1 && row.startsWith("ENCODING"))
      fcur = row[9..$].to!uint;
    else if(phase == 1 && row.startsWith("BBX")) {
      auto a = row[4..$].split.map(to!int);
      bbw = a[0],
      bbh = a[1],
      bbxoff0x = a[2],
      bbxoff0y = a[3];
      chr = 0;
    } else if(phase == 1 && row.startsWith("BITMAP"))
      phase++;
    else if(phase == 2 && row.startsWith("ENDCHAR")) {
      // buf to data
      fcnt++;
      phase = 0;
    } else if(phase == 2) {
      // readln
    } else if(!row.length) break;
    if(fcnt >= FontLen) break;
  }

  data;
}
