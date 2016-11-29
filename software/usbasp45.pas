unit usbasp45;

{$mode objfpc}

interface

uses
  Classes, Forms, SysUtils, libusb, usbhid, utilfunc;

const
  // ISP SCK speed identifiers
  USBASP_ISP_SCK_AUTO         = 0;
  USBASP_ISP_SCK_0_5          = 1;   // 500 Hz
  USBASP_ISP_SCK_1            = 2;   //   1 kHz
  USBASP_ISP_SCK_2            = 3;   //   2 kHz
  USBASP_ISP_SCK_4            = 4;   //   4 kHz
  USBASP_ISP_SCK_8            = 5;   //   8 kHz
  USBASP_ISP_SCK_16           = 6;   //  16 kHz
  USBASP_ISP_SCK_32           = 7;   //  32 kHz
  USBASP_ISP_SCK_93_75        = 8;   //  93.75 kHz
  USBASP_ISP_SCK_187_5        = 9;   // 187.5  kHz
  USBASP_ISP_SCK_375          = 10;  // 375 kHz
  USBASP_ISP_SCK_750          = 11;  // 750 kHz
  USBASP_ISP_SCK_1500         = 12;  // 1.5 MHz
  USBASP_ISP_SCK_3000         = 13;   // 3 Mhz
  USBASP_ISP_SCK_6000         = 14;   // 6 Mhz

  USBASP_FUNC_GETCAPABILITIES = 127;

  USBASP_FUNC_DISCONNECT         = 2;
  USBASP_FUNC_TRANSMIT           = 3;
  USBASP_FUNC_SETISPSCK          = 10;

  USBASP_FUNC_GPIO_CONFIG	 = 40;
  USBASP_FUNC_GPIO_READ	         = 41;
  USBASP_FUNC_GPIO_WRITE	 = 42;

  USBASP_FUNC_25_CONNECT         = 50;
  USBASP_FUNC_25_READ            = 51;
  USBASP_FUNC_25_WRITE  	 = 52;

function UsbAsp45_Busy(devHandle: Pusb_dev_handle): boolean;

function UsbAsp45_isPagePowerOfTwo(devHandle: Pusb_dev_handle): boolean;

function UsbAsp45_Write(devHandle: Pusb_dev_handle; PageAddr: word; buffer: array of byte; bufflen: integer): integer;
function UsbAsp45_Read(devHandle: Pusb_dev_handle; PageAddr: word; var buffer: array of byte; bufflen: integer): integer;

//
function UsbAsp45_ChipErase(devHandle: Pusb_dev_handle): integer;

//Disable Sector protect
function UsbAsp45_DisableSP(devHandle: Pusb_dev_handle): integer;
//
function UsbAsp45_ReadSR(devHandle: Pusb_dev_handle; var sreg: byte): integer;
//read sector lockdown
function UsbAsp45_ReadSectorLockdown(devHandle: Pusb_dev_handle; var buffOut: array of byte): integer;


implementation

uses Main;

//Пока отлипнет ромка
function UsbAsp45_Busy(devHandle: Pusb_dev_handle): boolean;
var
  sreg: byte;
begin
  Result := False;
  sreg := 0;
  repeat
    UsbAsp45_ReadSR(devHandle, sreg);
    Application.ProcessMessages;
    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      Result := True;
      Exit;
    end;
  until((sreg shr 7) and 1 = 1);
end;

function UsbAsp45_isPagePowerOfTwo(devHandle: Pusb_dev_handle): boolean;
var
  sreg: byte;
begin
  sreg := 0;

  UsbAsp45_ReadSR(devHandle, sreg);
  if (sreg and 1) = 1 then Result := True else Result := false;
end;

function UsbAsp45_ChipErase(devHandle: Pusb_dev_handle): integer;
var
  buff: array[0..3] of byte;
begin
  buff[0]:= $C7;
  buff[1]:= $94;
  buff[2]:= $80;
  buff[3]:= $9A;
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 4, buff);
end;

function UsbAsp45_DisableSP(devHandle: Pusb_dev_handle): integer;
var
  buff: array[0..3] of byte;
begin
  Buff[0] := $3D;
  Buff[1] := $2A;
  Buff[2] := $7F;
  Buff[2] := $9A;
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 4, buff);
end;

function UsbAsp45_ReadSectorLockdown(devHandle: Pusb_dev_handle; var buffOut: array of byte): integer;
var
  buff: array[0..3] of byte;
begin
  Buff[0] := $35;
  Buff[1] := $00;
  Buff[2] := $00;
  Buff[3] := $00;
  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 4, buff);
  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 1, 0, 32, buffOut);
end;

function UsbAsp45_ReadSR(devHandle: Pusb_dev_handle; var sreg: byte): integer;
begin
  sreg := $D7; //57H Legacy
  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 1, sreg);
  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 1, 0, 1, sreg);
end;

//Возвращает сколько байт записали
function UsbAsp45_Write(devHandle: Pusb_dev_handle; PageAddr: word; buffer: array of byte; bufflen: integer): integer;
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

  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 4, buff);
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, bufflen, buffer);
end;

function UsbAsp45_Read(devHandle: Pusb_dev_handle; PageAddr: word; var buffer: array of byte; bufflen: integer): integer;
begin
  //Опкод
  buffer[0] := $E8;
  //В зависимости от размера страницы(не меньше 8 бит), адрес страницы будет занимать
  //столько-то старших бит
  PageAddr := ( PageAddr shl (BitNum(bufflen)-8) );

  buffer[1] := hi(PageAddr);
  buffer[2] := lo(PageAddr);

  buffer[3] := 0;

  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 8, buffer);
  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 1, 0, bufflen, buffer);
end;

end.

