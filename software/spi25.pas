unit spi25;

{$mode objfpc}

interface

uses
  Classes, Forms, SysUtils, utilfunc;

const

  WT_PAGE = 0;
  WT_SSTB = 1;
  WT_SSTW = 2;

type

  MEMORY_ID = record
    ID9FH: array[0..2] of byte;
    ID90H: array[0..1] of byte;
    IDABH: byte;
    ID15H: array[0..1] of byte;
  end;

function UsbAsp25_Busy(): boolean;

function EnterProgMode25(spiSpeed: integer): boolean;
procedure ExitProgMode25;

function UsbAsp25_Read(Opcode: Byte; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
function UsbAsp25_Read32bitAddr(Opcode: byte; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
function UsbAsp25_Write(Opcode: byte; Addr: longword; buffer: array of byte; bufflen: integer): integer;
function UsbAsp25_Write32bitAddr(Opcode: byte; Addr: longword; buffer: array of byte; bufflen: integer): integer;

function UsbAsp25_ReadID(var ID: MEMORY_ID): integer;

function UsbAsp25_Wren(): integer;
function UsbAsp25_Wrdi(): integer;
function UsbAsp25_ChipErase(): integer;

function UsbAsp25_WriteSR(sreg: byte; opcode: byte = $01): integer;
function UsbAsp25_WriteSR_2byte(sreg1, sreg2: byte): integer;
function UsbAsp25_ReadSR(var sreg: byte; opcode: byte = $05): integer;

function UsbAsp25_WriteSSTB(Opcode: byte; Data: byte): integer;
function UsbAsp25_WriteSSTW(Opcode: byte; Data1, Data2: byte): integer;

function UsbAsp25_EN4B(): integer;
function UsbAsp25_EX4B(): integer;

function SPIRead(CS: byte; BufferLen: integer; out buffer: array of byte): integer;
function SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer;

implementation

uses Main;

//Пока отлипнет ромка
function UsbAsp25_Busy: boolean;
var
  sreg: byte;
begin
  Result := True;
  sreg := $FF;

  UsbAsp25_ReadSR(sreg);
  if not IsBitSet(sreg, 0) then Result := False;
end;

//Вход в режим программирования
function EnterProgMode25(spiSpeed: integer): boolean;
begin
  result := AsProgrammer.Programmer.SPIInit(spiSpeed);
  sleep(50);

  //release power-down
  SPIWrite(1, 1, $AB);
  sleep(2);
end;

//Выход из режима программирования
procedure ExitProgMode25;
begin
  AsProgrammer.Programmer.SPIDeinit;
end;

//Читает id и заполняет структуру
function UsbAsp25_ReadID(var ID: MEMORY_ID): integer;
var
  buffer: array[0..3] of byte;
begin
  //9F
  buffer[0] := $9F;
  SPIWrite(0, 1, buffer);
  FillByte(buffer, 4, $FF);
  result := SPIRead(1, 3, buffer);
  move(buffer, ID.ID9FH, 3);
  //90
  FillByte(buffer, 4, 0);
  buffer[0] := $90;
  SPIWrite(0, 4, buffer);
  result := SPIRead(1, 2, buffer);
  move(buffer, ID.ID90H, 2);
  //AB
  FillByte(buffer, 4, 0);
  buffer[0] := $AB;
  SPIWrite(0, 4, buffer);
  result := SPIRead(1, 1, buffer);
  move(buffer, ID.IDABH, 1);
  //15
  buffer[0] := $15;
  SPIWrite(0, 1, buffer);
  FillByte(buffer, 4, $FF);
  result := SPIRead(1, 2, buffer);
  move(buffer, ID.ID15H, 2);
end;

//Возвращает сколько байт прочитали
function UsbAsp25_Read(Opcode: byte; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..3] of byte;
begin

  buff[0] := Opcode;
  buff[1] := hi(addr);
  buff[2] := hi(lo(addr));
  buff[3] := lo(addr);

  SPIWrite(0, 4, buff);
  result := SPIRead(1, bufflen, buffer);
end;

function UsbAsp25_Read32bitAddr(Opcode: byte; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..4] of byte;
begin

  buff[0] := Opcode;
  buff[1] := hi(hi(addr));
  buff[2] := lo(hi(addr));
  buff[3] := hi(lo(addr));
  buff[4] := lo(lo(addr));

  SPIWrite(0, 5, buff);
  result := SPIRead(1, bufflen, buffer);
end;

function UsbAsp25_Wren(): integer;
var
  buff: byte;
begin
  buff:= $06;
  result := SPIWrite(1, 1, buff);
end;

function UsbAsp25_Wrdi(): integer;
var
  buff: byte;
begin
  buff:= $04;
  result := SPIWrite(1, 1, buff);
end;

function UsbAsp25_ChipErase(): integer;
var
  buff: byte;
begin
  //Некоторые atmel'ы требуют 62H
  buff:= $62;
  SPIWrite(1, 1, buff);
  //Старые SST требуют 60H
  buff:= $60;
  SPIWrite(1, 1, buff);
  buff:= $C7;
  result := SPIWrite(1, 1, buff);
end;

function UsbAsp25_WriteSR(sreg: byte; opcode: byte = $01): integer;
var
  buff: array[0..1] of byte;
begin
  //Старые SST требуют Enable-Write-Status-Register (50H)
  Buff[0] := $50;
  SPIWrite(1, 1, buff);
  //
  Buff[0] := opcode;
  Buff[1] := sreg;
  result := SPIWrite(1, 2, buff);
end;

function UsbAsp25_WriteSR_2byte(sreg1, sreg2: byte): integer;
var
  buff: array[0..2] of byte;
begin
  //Старые SST требуют Enable-Write-Status-Register (50H)
  Buff[0] := $50;
  SPIWrite(1, 1, buff);

  //Если регистр из 2х байт
  Buff[0] := $01;
  Buff[1] := sreg1;
  Buff[2] := sreg2;
  result := SPIWrite(1, 3, buff);
end;

function UsbAsp25_ReadSR(var sreg: byte; opcode: byte = $05): integer;
begin
  SPIWrite(0, 1, opcode);
  result := SPIRead(1, 1, sreg);
end;

//Возвращает сколько байт записали
function UsbAsp25_Write(Opcode: byte; Addr: longword; buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..3] of byte;
begin

  buff[0] := Opcode;
  buff[1] := lo(hi(addr));
  buff[2] := hi(lo(addr));
  buff[3] := lo(lo(addr));

  SPIWrite(0, 4, buff);
  result := SPIWrite(1, bufflen, buffer);
end;

function UsbAsp25_Write32bitAddr(Opcode: byte; Addr: longword; buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..4] of byte;
begin

  buff[0] := Opcode;
  buff[1] := hi(hi(addr));
  buff[2] := lo(hi(addr));
  buff[3] := hi(lo(addr));
  buff[4] := lo(lo(addr));

  SPIWrite(0, 5, buff);
  result := SPIWrite(1, bufflen, buffer);
end;

function UsbAsp25_WriteSSTB(Opcode: byte; Data: byte): integer;
var
  buff: array[0..1] of byte;
begin
  buff[0] := Opcode;
  buff[1] := Data;

  result := SPIWrite(1, 2, buff)-1;
end;

function UsbAsp25_WriteSSTW(Opcode: byte; Data1, Data2: byte): integer;
var
  buff: array[0..2] of byte;
begin
  buff[0] := Opcode;
  buff[1] := Data1;
  buff[2] := Data2;

  result := SPIWrite(1, 3, buff)-1;
end;

//Enter 4-byte mode
function UsbAsp25_EN4B(): integer;
var
  buff: byte;
begin
  UsbAsp25_Wren;
  buff:= $B7;
  result := SPIWrite(1, 1, buff);
  //Access Spansion Bank Register to enable Extended address control bit (EXTADD) for 4-byte addressing
  buff:= $17;
  SPIWrite(0, 1, buff);
  buff:= %10000000; //EXTADD=1
  result := SPIWrite(1, 1, buff);
end;

//Exit 4-byte mode
function UsbAsp25_EX4B(): integer;
var
  buff: byte;
begin
  UsbAsp25_Wren;
  buff:= $E9;
  result := SPIWrite(1, 1, buff);
end;

function SPIRead(CS: byte; BufferLen: integer; out buffer: array of byte): integer;
begin
  result := AsProgrammer.Programmer.SPIRead(CS, BufferLen, buffer);
end;

function SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer;
begin
  result := AsProgrammer.Programmer.SPIWrite(CS, BufferLen, buffer);
end;

end.

