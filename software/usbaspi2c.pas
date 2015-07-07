unit usbaspi2c;

{$mode objfpc}

interface

uses
  Classes, SysUtils, libusb, usbhid;

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
function UsbAspI2C_Read(devHandle: Pusb_dev_handle; AddrType: byte; Address: word;var buffer: array of byte; bufflen: integer): integer;
function UsbAspI2C_Write(devHandle: Pusb_dev_handle; AddrType: byte; Addr: longword; buffer: array of byte; bufflen: integer): integer;

implementation

procedure EnterProgModeI2C(devHandle: Pusb_dev_handle);
var
  dummy: byte;
begin
  USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_I2C_INIT, 0, 0, 0, dummy);
  sleep(50);
end;

function UsbAspI2C_BUSY(devHandle: Pusb_dev_handle; Address: byte): Boolean;
var
  Status: byte;
begin
  USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_I2C_ACK, Address, 0, 1, Status);
  Result := not Boolean(Status);
end;

//Возвращает сколько байт прочитали
function UsbAspI2C_Read(devHandle: Pusb_dev_handle; AddrType: byte; Address: word;var buffer: array of byte; bufflen: integer): integer;
var
  value, index: Integer;
begin

  //шайтанама
  if (AddrType = I2C_ADDR_TYPE_2BYTE) or (AddrType = I2C_ADDR_TYPE_2BYTE_1BIT) then
  begin
    value := (I2C_2BYTE_ADDR shl 8) or (%10100000);
    index := Address;
  end else
  if AddrType = I2C_ADDR_TYPE_7BIT  then
  begin
    value := %00000000;
    index := 0;
  end else
  begin
    value := (I2C_1BYTE_ADDR shl 8) or (%10100000);
    index := 0;
  end;

  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_I2C_READ, value, index, bufflen, buffer);
end;

//Возвращает сколько байт записали
function UsbAspI2C_Write(devHandle: Pusb_dev_handle; AddrType: byte; Addr: longword; buffer: array of byte; bufflen: integer): integer;
var
  value, index: Integer;
begin
  //Low(value) = 2; Адрес устройства
  //Hi(value)  = 3; Посылать ли первый(lo) или второй(hi) байт
  //Lo(index)  = 4; Lo адрес
  //Hi(index)  = 5; Hi адрес
  //шайтанама
  //TODO: Moar addr types
  if AddrType = I2C_ADDR_TYPE_7BIT then
  begin
    Value := (I2C_0BYTE_ADDR shl 8) or (Byte(Addr) shl 1); //7 бит
    index := 0;
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE then
  begin
    Value := (I2C_1BYTE_ADDR shl 8) or (%10100000);
    index := Byte(Addr);
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_1BIT then
  begin
    Value := (I2C_1BYTE_ADDR shl 8) or (%10100000);

    if (Hi(Word(Addr)) and (1 shl 0)) <> 0 then
      value := value or (1 shl 1);

    index := Byte(Addr);
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_2BIT then
  begin
    Value := (I2C_1BYTE_ADDR shl 8) or (%10100000);

    if (Hi(Word(Addr)) and (1 shl 0)) <> 0 then
      value := value or (1 shl 1);

    if (Hi(Word(Addr)) and (1 shl 1)) <> 0 then
      value := value or (1 shl 2);

    index := Byte(Addr);
  end;

  if AddrType = I2C_ADDR_TYPE_1BYTE_3BIT then
  begin
    Value := (I2C_1BYTE_ADDR shl 8) or (%10100000);

    if (Hi(Word(Addr)) and (1 shl 0)) <> 0 then
      value := value or (1 shl 1);

    if (Hi(Word(Addr)) and (1 shl 1)) <> 0 then
      value := value or (1 shl 2);

    if (Hi(Word(Addr)) and (1 shl 2)) <> 0 then
      value := value or (1 shl 3);

    index := Byte(Addr);
  end;

  if AddrType = I2C_ADDR_TYPE_2BYTE then
  begin
    value := (I2C_2BYTE_ADDR shl 8) or (%10100000);
    index := Word(Addr);
  end;

  if AddrType = I2C_ADDR_TYPE_2BYTE_1BIT then
  begin
    value := (I2C_2BYTE_ADDR shl 8) or (%10100000);

    if Hi(Addr) and (1 shl 0) <> 0 then
      value := value or (1 shl 1);

    index := Word(Addr);
  end;


  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_I2C_WRITE, value, index, bufflen, buffer);
end;

end.

