unit ch341mw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, CH341DLL, utilfunc, dialogs;

function ch341mw_busy(): boolean;
function ch341mw_sendop(opcode: byte; AddrBitLen: byte): boolean;
function ch341mw_read(AddrBitLen: byte; Addr: word; var buffer: array of byte; bufflen: integer): integer;
function ch341mw_write(AddrBitLen: byte; Addr: word; var buffer: array of byte; bufflen: integer): integer;

implementation

function ch341mw_busy(): boolean;
var
  port: byte;
begin
  CH341Set_D5_D0(0, %00101001, 0);
  CH341Set_D5_D0(0, %00101001, 1); //cs hi

  CH341GetStatus(0, @port);
  result := not IsBitSet(port, 7);

  CH341Set_D5_D0(0, %00101001, 0);
end;

function ch341mw_sendop(opcode: byte; AddrBitLen: byte): boolean;
var
  buff: array[0..15] of byte;
begin
  result := true;
  CH341Set_D5_D0(0, %00101001, 0);
  CH341Set_D5_D0(0, %00101001, 1); //cs hi

  FillByte(buff, sizeOf(buff), 1); //cs hi
  BitSet(1, buff[0], 5); //стартовый бит
  BitSet(0, buff[1], 5);
  BitSet(0, buff[2], 5);
  //Опкод
  if IsBitSet(opcode, 1) then
    BitSet(1, buff[3], 5)
  else
    BitSet(0, buff[3], 5);

  if IsBitSet(opcode, 0) then
    BitSet(1, buff[4], 5)
  else
    BitSet(0, buff[4], 5);

  if not CH341BitStreamSPI(0, AddrBitLen+3, @buff) then result := false;

  CH341Set_D5_D0(0, %00101001, 0);
end;

function ch341mw_read(AddrBitLen: byte; Addr: word; var buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..15] of byte;
  bit_buffer: array of byte;
  i,j: integer;
begin
  result := bufflen;
  CH341Set_D5_D0(0, %00101001, 0);
  FillByte(buff, SizeOf(buff), 1); //cs hi


  BitSet(1, buff[0], 5); //стартовый бит
  //Опкод 10b
  BitSet(1, buff[1], 5);
  BitSet(0, buff[2], 5);
  //адрес
  for i:=0 to AddrBitLen-1 do
  begin
     if IsBitSet(Addr, AddrBitLen-1-i) then  //устанавливаем биты от старшего к младшему
      BitSet(1, buff[i+3], 5)
     else
      BitSet(0, buff[i+3], 5);
  end;

  //Засылаем адрес
  if not CH341BitStreamSPI(0, AddrBitLen+3, @buff) then result :=0; //стартовый бит + 2 бита опкод

  SetLength(bit_buffer, Bufflen*8);
  FillByte(bit_buffer[0], Bufflen*8, 1); //cs hi
  if not CH341BitStreamSPI(0, Bufflen*8, @bit_buffer[0]) then result :=0; //читаем биты

  for i:=0 to bufflen-1 do
  begin
    for j:=0 to 7 do
    begin
      if IsBitSet(bit_buffer[(i*8)+j], 7) then //читаем DIN
        BitSet(1, buffer[i], 7-j) //устанавливаем биты от старшего к младшему
      else
        BitSet(0, buffer[i], 7-j);
    end;
  end;

  CH341Set_D5_D0(0, %00101001, 0); //кончаем
end;

function ch341mw_write(AddrBitLen: byte; Addr: word; var buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..15] of byte;
  bit_buffer: array of byte;
  i,j: integer;
begin
  result := bufflen;
  CH341Set_D5_D0(0, %00101001, 0);
  FillByte(buff, 16, 1); //cs hi


  BitSet(1, buff[0], 5); //стартовый бит
  //Опкод 01b
  BitSet(0, buff[1], 5);
  BitSet(1, buff[2], 5);
  //адрес
  for i:=0 to AddrBitLen-1 do
  begin
     if IsBitSet(Addr, AddrBitLen-1-i) then  //устанавливаем биты от старшего к младшему
      BitSet(1, buff[i+3], 5)
     else
      BitSet(0, buff[i+3], 5);
  end;

  //Засылаем адрес
  if not CH341BitStreamSPI(0, AddrBitLen+3, @buff) then result :=0; //стартовый бит + 2 бита опкод

  SetLength(bit_buffer, Bufflen*8);
  FillByte(bit_buffer[0], Bufflen*8, 1); //cs hi

  for i:=0 to bufflen-1 do
  begin
    for j:=0 to 7 do
    begin
      if IsBitSet(buffer[i], 7-j) then //читаем буфер
        BitSet(1, bit_buffer[(i*8)+j], 5) //устанавливаем биты от старшего к младшему
      else
        BitSet(0, bit_buffer[(i*8)+j], 5);
    end;
  end;

  if not CH341BitStreamSPI(0, Bufflen*8, @bit_buffer[0]) then result :=0; //записываем биты

  CH341Set_D5_D0(0, %00101001, 0); //кончаем
end;

end.

