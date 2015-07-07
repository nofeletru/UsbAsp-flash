unit usbaspmw;

{$mode objfpc}

interface

uses
  Classes, SysUtils, libusb, usbhid;

const
  USBASP_FUNC_CONNECT        = 1;
  USBASP_FUNC_MW_4BITOPCODE  = 91;
  USBASP_FUNC_MW_READ        = 92;
  USBASP_FUNC_MW_WRITE	     = 93;
  USBASP_FUNC_MW_BUSY	     = 94;

  function UsbAspMW_Busy(devHandle: Pusb_dev_handle): boolean;
  function UsbAspMW_Read(devHandle: Pusb_dev_handle; AddrBitLen: byte; Addr: word; var buffer: array of byte; bufflen: integer): integer;
  function UsbAspMW_Write(devHandle: Pusb_dev_handle; AddrBitLen: byte; Addr: word; buffer: array of byte; bufflen: integer): integer;
  function UsbAspMW_ChipErase(devHandle: Pusb_dev_handle; AddrBitLen: byte): integer;
  function UsbAspMW_Ewen(devHandle: Pusb_dev_handle; AddrBitLen: byte): integer;

implementation

function UsbAspMW_Busy(devHandle: Pusb_dev_handle): boolean;
var
  buf: byte;
begin
  buf := 0;
  result := False;

  USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_MW_BUSY, 0, 0, 1, buf);

  if buf = 1 then
    result := True;
end;

//Возвращает сколько байт прочитали
function UsbAspMW_Read(devHandle: Pusb_dev_handle; AddrBitLen: byte; Addr: word; var buffer: array of byte; bufflen: integer): integer;
var
  value, index: integer;
begin

  //Собираем пакет
  value := 2; //Опкод
  value := (value shl AddrBitLen) or Addr; //Адрес
  index := AddrBitLen+2; //Сколько бит слать

  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_MW_READ, value, index, bufflen, buffer);
end;

//Возвращает сколько байт записали
function UsbAspMW_Write(devHandle: Pusb_dev_handle; AddrBitLen: byte; Addr: word; buffer: array of byte; bufflen: integer): integer;
var
  value, index: Integer;
begin
  //Собираем пакет
  value := addr; //Адрес
  index := 1;
  index := (index shl 8) or (AddrBitLen+2); //Сколько бит слать

  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_MW_WRITE, value, index, bufflen, buffer);
end;

function UsbAspMW_ChipErase(devHandle: Pusb_dev_handle; AddrBitLen: byte): integer;
var
  dummybuff: byte;
  value, index: Integer;
begin
  //Собираем пакет
  value := 2; //Опкод 0010
  value := (value shl (AddrBitLen-2));
  index := AddrBitLen+2; //Сколько бит слать

  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_MW_READ, value, index, 0, dummybuff);
end;

function UsbAspMW_Ewen(devHandle: Pusb_dev_handle; AddrBitLen: byte): integer;
var
  dummybuff: byte;
  value, index: Integer;
begin
  //Собираем пакет
  value := 3; //Опкод 0011
  value := (value shl (AddrBitLen-2));
  index := AddrBitLen+2; //Сколько бит слать

  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_MW_READ, value, index, 0, dummybuff);
end;

end.

