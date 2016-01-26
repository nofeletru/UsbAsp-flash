unit usbasp95;

{$mode objfpc}

interface

uses
  Classes, SysUtils, libusb, usbhid;

const
  USBASP_FUNC_25_READ        = 51;
  USBASP_FUNC_25_WRITE  	 = 52;

function UsbAsp95_Read(devHandle: Pusb_dev_handle; ChipSize: integer; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
function UsbAsp95_Write(devHandle: Pusb_dev_handle; ChipSize: integer; Addr: longword; buffer: array of byte; bufflen: integer): integer;
function UsbAsp95_Wren(devHandle: Pusb_dev_handle): integer;
function UsbAsp95_Wrdi(devHandle: Pusb_dev_handle): integer;
function UsbAsp95_WriteSR(devHandle: Pusb_dev_handle; var sreg: byte): integer;
function UsbAsp95_ReadSR(devHandle: Pusb_dev_handle; var sreg: byte): integer;

implementation


function UsbAsp95_Read(devHandle: Pusb_dev_handle; ChipSize: integer; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
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

  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, len, buff);
  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 1, 0, bufflen, buffer);
end;

function UsbAsp95_Write(devHandle: Pusb_dev_handle; ChipSize: integer; Addr: longword; buffer: array of byte; bufflen: integer): integer;
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

  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, len, buff);
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, bufflen, buffer);
end;

function UsbAsp95_Wren(devHandle: Pusb_dev_handle): integer;
var
  buff: byte;
begin
  buff:= $06;
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 1, buff);
end;

function UsbAsp95_Wrdi(devHandle: Pusb_dev_handle): integer;
var
  buff: byte;
begin
  buff:= $04;
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 1, buff);
end;

function UsbAsp95_WriteSR(devHandle: Pusb_dev_handle; var sreg: byte): integer;
var
  buff: array[0..1] of byte;
begin
  Buff[0] := $01;
  Buff[1] := sreg;
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 2, buff);
end;

function UsbAsp95_ReadSR(devHandle: Pusb_dev_handle; var sreg: byte): integer;
begin
  sreg := $05;
  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 1, sreg);
  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 1, 0, 1, sreg);
end;

end.

