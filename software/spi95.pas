unit spi95;

{$mode objfpc}

interface

uses
  Classes, SysUtils, spi25;

function UsbAsp95_Read(ChipSize: integer; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
function UsbAsp95_Write(ChipSize: integer; Addr: longword; buffer: array of byte; bufflen: integer): integer;
function UsbAsp95_Wren(): integer;
function UsbAsp95_Wrdi(): integer;
function UsbAsp95_WriteSR(var sreg: byte): integer;
function UsbAsp95_ReadSR(var sreg: byte): integer;

implementation


function UsbAsp95_Read(ChipSize: integer; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
var
  len: byte;
  buff: array[0..3] of byte;
begin

  if ChipSize < 512 then //1 байт
  begin
    buff[0] := $03;
    buff[1] := Addr;
    len := 2;
  end;

  if ChipSize = 512 then  //1 байт с разными запросами
  begin
    //Нижняя часть памяти
    if Addr < 256 then
    begin
      buff[0] := $03;
      buff[1] := Addr;
    end;

    //Верхняя часть памяти
    if Addr > 255 then
    begin
      buff[0] := $0b;
      buff[1] := Addr - 256;
    end;

    len := 2;
  end;

  if (ChipSize > 512) and (ChipSize <= 65536) then  // 2 байта
  begin
    buff[0] := $03;
    buff[1] := hi(lo(addr));
    buff[2] := lo(lo(addr));
    len := 3;
  end;

  if (ChipSize > 65536)  then  // 3 байта
    begin
    buff[0] := $03;
    buff[1] := hi(addr);
    buff[2] := hi(lo(addr));
    buff[3] := lo(addr);
    len := 4;
  end;

  SPIWrite(0, len, buff);
  result := SPIRead(1, bufflen, buffer);
end;

function UsbAsp95_Write(ChipSize: integer; Addr: longword; buffer: array of byte; bufflen: integer): integer;
var
  len: byte;
  buff: array[0..3] of byte;
begin

  if ChipSize < 512 then //1 байт
  begin
    buff[0] := $02;
    buff[1] := Addr;
    len := 2;
  end;

  if ChipSize = 512 then  //1 байт с разными запросами
  begin
    //Нижняя часть памяти
    if Addr < 256 then
    begin
      buff[0] := $02;
      buff[1] := Addr;
    end;

    //Верхняя часть памяти
    if Addr > 255 then
    begin
      buff[0] := $0a;
      buff[1] := Addr - 256;
    end;

    len := 2;
  end;

  if (ChipSize > 512) and (ChipSize <= 65536) then  // 2 байта
  begin
    buff[0] := $02;
    buff[1] := hi(lo(addr));
    buff[2] := lo(lo(addr));
    len := 3;
  end;

  if (ChipSize > 65536)  then  // 3 байта
    begin
    buff[0] := $02;
    buff[1] := hi(addr);
    buff[2] := hi(lo(addr));
    buff[3] := lo(addr);
    len := 4;
  end;

  SPIWrite(0, len, buff);
  result := SPIWrite(1, bufflen, buffer);
end;

function UsbAsp95_Wren(): integer;
var
  buff: byte;
begin
  buff:= $06;
  result := SPIWrite(1, 1, buff);
end;

function UsbAsp95_Wrdi(): integer;
var
  buff: byte;
begin
  buff:= $04;
  result := SPIWrite(1, 1, buff);
end;

function UsbAsp95_WriteSR(var sreg: byte): integer;
var
  buff: array[0..1] of byte;
begin
  Buff[0] := $01;
  Buff[1] := sreg;
  result := SPIWrite(1, 2, buff);
end;

function UsbAsp95_ReadSR(var sreg: byte): integer;
begin
  sreg := $05;
  SPIWrite(0, 1, sreg);
  result := SPIRead(1, 1, sreg);
end;

end.

