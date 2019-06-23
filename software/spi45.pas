unit spi45;

{$mode objfpc}

interface

uses
  Classes, Forms, SysUtils, utilfunc, spi25;

function UsbAsp45_Busy(): boolean;

function UsbAsp45_isPagePowerOfTwo(): boolean;

function UsbAsp45_Write(PageAddr: word; buffer: array of byte; bufflen: integer): integer;
function UsbAsp45_Read(PageAddr: word; var buffer: array of byte; bufflen: integer): integer;

//
function UsbAsp45_ChipErase(): integer;

//Disable Sector protect
function UsbAsp45_DisableSP(): integer;
//
function UsbAsp45_ReadSR(var sreg: byte): integer;
//read sector lockdown
function UsbAsp45_ReadSectorLockdown(var buffOut: array of byte): integer;


implementation

uses Main;

//Пока отлипнет ромка
function UsbAsp45_Busy(): boolean;
var
  sreg: byte;
begin
  Result := True;
  sreg := 0;
  UsbAsp45_ReadSR(sreg);
  if IsBitSet(Sreg, 7) then Result := False;
end;

function UsbAsp45_isPagePowerOfTwo(): boolean;
var
  sreg: byte;
begin
  sreg := 0;

  UsbAsp45_ReadSR(sreg);
  if (sreg and 1) = 1 then Result := True else Result := false;
end;

function UsbAsp45_ChipErase(): integer;
var
  buff: array[0..3] of byte;
begin
  buff[0]:= $C7;
  buff[1]:= $94;
  buff[2]:= $80;
  buff[3]:= $9A;
  result := SPIWrite(1, 4, buff);
end;

function UsbAsp45_DisableSP(): integer;
var
  buff: array[0..3] of byte;
begin
  Buff[0] := $3D;
  Buff[1] := $2A;
  Buff[2] := $7F;
  Buff[2] := $9A;
  result := SPIWrite(1, 4, buff);
end;

function UsbAsp45_ReadSectorLockdown(var buffOut: array of byte): integer;
var
  buff: array[0..3] of byte;
begin
  Buff[0] := $35;
  Buff[1] := $00;
  Buff[2] := $00;
  Buff[3] := $00;
  SPIWrite( 0, 4, buff);
  result := SPIRead(1, 32, buffOut);
end;

function UsbAsp45_ReadSR(var sreg: byte): integer;
begin
  sreg := $D7; //57H Legacy
  SPIWrite(0, 1, sreg);
  result := SPIRead(1, 1, sreg);
end;

//Возвращает сколько байт записали
function UsbAsp45_Write(PageAddr: word; buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..3] of byte;
begin
 // rrrraaaa aaaaaaap pppppppp
 //r - reserved
 //a - page address
 //p - buffer address

  //Опкод
  buff[0] := $82;
  //В зависимости от размера страницы(не меньше 8 бит), адрес страницы будет занимать
  //столько-то старших бит
  PageAddr := ( PageAddr shl (BitNum(bufflen)-8) );

  buff[1] := hi(PageAddr);
  buff[2] := lo(PageAddr);

  buff[3] := 0;

  SPIWrite(0, 4, buff);
  result := SPIWrite(1, bufflen, buffer);
end;

function UsbAsp45_Read(PageAddr: word; var buffer: array of byte; bufflen: integer): integer;
begin
  //Опкод
  buffer[0] := $E8;
  //В зависимости от размера страницы(не меньше 8 бит), адрес страницы будет занимать
  //столько-то старших бит
  PageAddr := ( PageAddr shl (BitNum(bufflen)-8) );

  buffer[1] := hi(PageAddr);
  buffer[2] := lo(PageAddr);

  buffer[3] := 0;

  SPIWrite(0, 8, buffer);
  result := SPIRead(1, bufflen, buffer);
end;

end.

