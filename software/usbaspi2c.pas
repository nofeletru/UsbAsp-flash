unit usbaspi2c;

{$mode objfpc}

interface

uses
  Classes, SysUtils, libusb, usbhid, utilfunc, CH341DLL, avrispmk2;

const
  USBASP_FUNC_I2C_INIT		 = 70;
  USBASP_FUNC_I2C_READ		 = 71;
  USBASP_FUNC_I2C_WRITE		 = 72;
  USBASP_FUNC_I2C_ACK 		 = 73;

  //Как посылать адрес ячейки в чип
  I2C_ADDR_TYPE_7BIT             = 0;
  I2C_ADDR_TYPE_1BYTE            = 1;
  I2C_ADDR_TYPE_1BYTE_1BIT       = 2;
  I2C_ADDR_TYPE_1BYTE_2BIT       = 3;
  I2C_ADDR_TYPE_1BYTE_3BIT       = 4;
  I2C_ADDR_TYPE_2BYTE            = 5;
  I2C_ADDR_TYPE_2BYTE_1BIT       = 6;

  //Байт в микрокоде отвечающий за режим адресации
  I2C_0BYTE_ADDR                 = 0;
  I2C_1BYTE_ADDR                 = 1;
  I2C_2BYTE_ADDR                 = 2;


procedure EnterProgModeI2C(devHandle: Pusb_dev_handle);
function UsbAspI2C_BUSY(devHandle: Pusb_dev_handle; Address: byte): Boolean;
function UsbAspI2C_Read(devHandle: Pusb_dev_handle; DevAddr, AddrType: byte; Address: longword;var buffer: array of byte; bufflen: integer): integer;
function UsbAspI2C_Write(devHandle: Pusb_dev_handle; DevAddr, AddrType: byte; Address: longword; buffer: array of byte; bufflen: integer): integer;

implementation

uses main;

procedure EnterProgModeI2C(devHandle: Pusb_dev_handle);
var
  dummy: byte;
begin
  if AVRISP then exit;
  USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_I2C_INIT, 0, 0, 0, dummy);
  sleep(50);
end;

function UsbAspI2C_BUSY(devHandle: Pusb_dev_handle; Address: byte): Boolean;
procedure SendBit(bit: byte);
begin
  if boolean(bit) then
  begin
    CH341SetOutput(0, $10, 0, $0); //scl low
    CH341SetOutput(0, $10, 0, $80000); //1
    CH341SetOutput(0, $10, 0, $C0000); //scl hi
  end
  else
  begin
    CH341SetOutput(0, $10, 0, $0); //scl low
    CH341SetOutput(0, $10, 0, $0); //0
    CH341SetOutput(0, $10, 0, $40000); //scl hi
  end;
end;

var
  Status: byte;
  pins, i: cardinal;

begin
  if CH341 then
  begin
    CH341SetOutput(0, $10, 0, $40000); //sda low(start)

    for i:=7 downto 1 do
    begin
      if IsBitSet(Address, i) then SendBit(1) else SendBit(0);
    end;

    //rw
    SendBit(0);
    //ack
    SendBit(1);
    CH341GetStatus(0, @pins);
    Result := IsBitSet(pins, 23);
    //stop
    SendBit(0);

    CH341SetOutput(0, $10, 0, $C0000); //sda hi
    exit;
  end;

  if AVRISP then
  begin
    result := not avrisp_i2c_ack(Address);
    exit;
  end;

  USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_I2C_ACK, Address, 0, 1, Status);
  Result := not Boolean(Status);
end;

//Возвращает сколько байт прочитали
function UsbAspI2C_Read(devHandle: Pusb_dev_handle; DevAddr, AddrType: byte; Address: longword;var buffer: array of byte; bufflen: integer): integer;
var
  value, index: Integer;
begin

  DevAddr := DevAddr or %10100000;

  //TODO: 24LC1025


  if AddrType = I2C_ADDR_TYPE_7BIT  then
  begin
    value := 0;
    value := (Byte(Address) shl 1);
    index := 0;
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE  then
  begin
    value := (I2C_1BYTE_ADDR shl 8) or (DevAddr);
    index := Byte(Address);
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_1BIT then
  begin
    if IsBitSet(Hi(Word(Address)), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    value := (I2C_1BYTE_ADDR shl 8) or (DevAddr);
    index := Byte(Address);
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

    value := (I2C_1BYTE_ADDR shl 8) or (DevAddr);
    index := Byte(Address);
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

    value := (I2C_1BYTE_ADDR shl 8) or (DevAddr);
    index := Byte(Address);
  end;

  if (AddrType = I2C_ADDR_TYPE_2BYTE) then
  begin
    value := (I2C_2BYTE_ADDR shl 8) or (DevAddr);
    index := Word(Address);
  end;

  if (AddrType = I2C_ADDR_TYPE_2BYTE_1BIT) then
  begin
    if IsBitSet(Hi(Address), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    value := (I2C_2BYTE_ADDR shl 8) or (DevAddr);
    index := Word(Address);
  end;

  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_I2C_READ, value, index, bufflen, buffer);
end;

//Возвращает сколько байт записали
function UsbAspI2C_Write(devHandle: Pusb_dev_handle; DevAddr, AddrType: byte; Address: longword; buffer: array of byte; bufflen: integer): integer;
var
  value, index: Integer;
begin
  //Low(value) = 2; Адрес устройства
  //Hi(value)  = 3; Посылать ли первый(lo) или второй(hi) байт
  //Lo(index)  = 4; Lo адрес
  //Hi(index)  = 5; Hi адрес

  //TODO: 24LC1025

  DevAddr := DevAddr or %10100000;

  if AddrType = I2C_ADDR_TYPE_7BIT then
  begin
    Value := (I2C_0BYTE_ADDR shl 8) or (Byte(Address) shl 1); //7 бит
    index := 0;
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE then
  begin
    Value := (I2C_1BYTE_ADDR shl 8) or (DevAddr);
    index := Byte(Address);
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_1BIT then
  begin
    if IsBitSet(Hi(Word(Address)), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    value := (I2C_1BYTE_ADDR shl 8) or (DevAddr);
    index := Byte(Address);
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

    value := (I2C_1BYTE_ADDR shl 8) or (DevAddr);
    index := Byte(Address);
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

    value := (I2C_1BYTE_ADDR shl 8) or (DevAddr);
    index := Byte(Address);
  end;

  if AddrType = I2C_ADDR_TYPE_2BYTE then
  begin
    value := (I2C_2BYTE_ADDR shl 8) or (DevAddr);
    index := Word(Address);
  end;

  if AddrType = I2C_ADDR_TYPE_2BYTE_1BIT then
  begin
    if IsBitSet(Hi(Address), 0) then
      DevAddr := SetBit(DevAddr, 1)
    else
      DevAddr := ClearBit(DevAddr, 1);

    value := (I2C_2BYTE_ADDR shl 8) or (DevAddr);
    index := Word(Address);
  end;


  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_I2C_WRITE, value, index, bufflen, buffer);
end;

end.

