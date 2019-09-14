unit i2c;

{$mode objfpc}

interface

uses
  Classes, SysUtils, utilfunc;

const

  //Как посылать адрес ячейки в чип
  I2C_ADDR_TYPE_7BIT             = 0;
  I2C_ADDR_TYPE_1BYTE            = 1;
  I2C_ADDR_TYPE_1BYTE_1BIT       = 2;
  I2C_ADDR_TYPE_1BYTE_2BIT       = 3;
  I2C_ADDR_TYPE_1BYTE_3BIT       = 4;
  I2C_ADDR_TYPE_2BYTE            = 5;
  I2C_ADDR_TYPE_2BYTE_1BIT       = 6;


procedure EnterProgModeI2C();
function UsbAspI2C_BUSY(Address: byte): Boolean;
function UsbAspI2C_Read(DevAddr, AddrType: byte; Address: longword;var buffer: array of byte; bufflen: integer): integer;
function UsbAspI2C_Write(DevAddr, AddrType: byte; Address: longword; buffer: array of byte; bufflen: integer): integer;

implementation

uses main;

procedure EnterProgModeI2C();
begin
  AsProgrammer.Programmer.I2CInit;
  sleep(50);
end;

function UsbAspI2C_BUSY(Address: byte): Boolean;
begin
  AsProgrammer.Programmer.I2CStart;
  Result := not AsProgrammer.Programmer.I2CWriteByte(Address);
  AsProgrammer.Programmer.I2CStop;
end;

//Возвращает сколько байт прочитали
function UsbAspI2C_Read(DevAddr, AddrType: byte; Address: longword; var buffer: array of byte; bufflen: integer): integer;
var
  value, index: Integer;
  wBuffer: array of byte;
begin

   //TODO: 24LC1025


  if AddrType = I2C_ADDR_TYPE_7BIT  then
  begin
    value := 0;
    value := (Byte(Address) shl 1);
    index := 0;
    SetLength(wBuffer, 0);
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE  then
  begin
    value := DevAddr;
    index := Byte(Address);
    SetLength(wBuffer, 1);
    wBuffer[0] := index;
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_1BIT then
  begin
    if IsBitSet(Hi(Word(Address)), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    value := DevAddr;
    index := Byte(Address);
    SetLength(wBuffer, 1);
    wBuffer[0] := index;
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_2BIT then
  begin
    if IsBitSet(Hi(Word(Address)), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    if IsBitSet(Hi(Word(Address)), 1) then
      DevAddr := SetBit(DevAddr, 2)
    else
      DevAddr := ClearBit(DevAddr, 2);

    value := DevAddr;
    index := Byte(Address);
    SetLength(wBuffer, 1);
    wBuffer[0] := index;
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_3BIT then
  begin
    if IsBitSet(Hi(Word(Address)), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    if IsBitSet(Hi(Word(Address)), 1) then
      DevAddr := SetBit(DevAddr, 2)
    else
      DevAddr := ClearBit(DevAddr, 2);

    if IsBitSet(Hi(Word(Address)), 2) then
      DevAddr := SetBit(DevAddr, 3)
    else
      DevAddr := ClearBit(DevAddr, 3);

    value := DevAddr;
    index := Byte(Address);
    SetLength(wBuffer, 1);
    wBuffer[0] := index;
  end;

  if (AddrType = I2C_ADDR_TYPE_2BYTE) then
  begin
    value := DevAddr;
    index := Word(Address);
    SetLength(wBuffer, 2);
    wBuffer[0] := hi(word(index));
    wBuffer[1] := lo(word(index));
  end;

  if (AddrType = I2C_ADDR_TYPE_2BYTE_1BIT) then
  begin
    if IsBitSet(Hi(Address), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    value := DevAddr;
    index := Word(Address);
    SetLength(wBuffer, 2);
    wBuffer[0] := hi(word(index));
    wBuffer[1] := lo(word(index));
  end;

  //value адрес устройства
  //index адреса памяти
  result := AsProgrammer.Programmer.I2CReadWrite(value, Length(wBuffer), wBuffer, bufflen, buffer)-Length(wBuffer);
end;

//Возвращает сколько байт записали
function UsbAspI2C_Write(DevAddr, AddrType: byte; Address: longword; buffer: array of byte; bufflen: integer): integer;
var
  value, index, address_size: Integer;
  wBuffer: array of byte;
  dummy: byte;
begin
  //value Адрес устройства
  //Lo(index)  = 4; Lo адрес
  //Hi(index)  = 5; Hi адрес

  //TODO: 24LC1025

  if AddrType = I2C_ADDR_TYPE_7BIT then
  begin
    Value := Byte(Address) shl 1; //7 бит
    index := 0;
    SetLength(wBuffer, 0);
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE then
  begin
    Value := DevAddr;
    index := Byte(Address);
    SetLength(wBuffer, 1);
    wBuffer[0] := index;
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_1BIT then
  begin
    if IsBitSet(Hi(Word(Address)), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    value := DevAddr;
    index := Byte(Address);
    SetLength(wBuffer, 1);
    wBuffer[0] := index;
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_2BIT then
  begin
    if IsBitSet(Hi(Word(Address)), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    if IsBitSet(Hi(Word(Address)), 1) then
      DevAddr := SetBit(DevAddr, 2)
    else
      DevAddr := ClearBit(DevAddr, 2);

    value := DevAddr;
    index := Byte(Address);
    SetLength(wBuffer, 1);
    wBuffer[0] := index;
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_3BIT then
  begin
    if IsBitSet(Hi(Word(Address)), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    if IsBitSet(Hi(Word(Address)), 1) then
      DevAddr := SetBit(DevAddr, 2)
    else
      DevAddr := ClearBit(DevAddr, 2);

    if IsBitSet(Hi(Word(Address)), 2) then
      DevAddr := SetBit(DevAddr, 3)
    else
      DevAddr := ClearBit(DevAddr, 3);

    value := DevAddr;
    index := Byte(Address);
    SetLength(wBuffer, 1);
    wBuffer[0] := index;
  end;

  if AddrType = I2C_ADDR_TYPE_2BYTE then
  begin
    value := DevAddr;
    index := Word(Address);
    SetLength(wBuffer, 2);
    wBuffer[0] := hi(word(index));
    wBuffer[1] := lo(word(index));
  end;

  if AddrType = I2C_ADDR_TYPE_2BYTE_1BIT then
  begin
    if IsBitSet(Hi(Address), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    value := DevAddr;
    index := Word(Address);
    SetLength(wBuffer, 2);
    wBuffer[0] := hi(word(index));
    wBuffer[1] := lo(word(index));
  end;

  address_size := Length(wBuffer);
  SetLength(wBuffer, bufflen+address_size);
  move(buffer, wBuffer[address_size], bufflen);

  result := AsProgrammer.Programmer.I2CReadWrite(value, bufflen+address_size, wBuffer, 0, dummy)-address_size;
end;

end.

