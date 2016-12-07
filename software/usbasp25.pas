unit usbasp25;

{$mode objfpc}

interface

uses
  Classes, Forms, SysUtils, libusb, usbhid, CH341DLL;

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

  USBASP_FUNC_25_CONNECT         = 50;
  USBASP_FUNC_25_READ            = 51;
  USBASP_FUNC_25_WRITE  	 = 52;

  WT_PAGE = 0;
  WT_SSTB = 1;
  WT_SSTW = 2;


function UsbAsp25_Busy(devHandle: Pusb_dev_handle): boolean;

procedure EnterProgMode25(devHandle: Pusb_dev_handle);
procedure ExitProgMode25(devHandle: Pusb_dev_handle);

function UsbAsp25_Read(devHandle: Pusb_dev_handle; Opcode: Byte; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
function UsbAsp25_Read32bitAddr(devHandle: Pusb_dev_handle; Opcode: byte; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
function UsbAsp25_Write(devHandle: Pusb_dev_handle; Opcode: byte; Addr: longword; buffer: array of byte; bufflen: integer): integer;
function UsbAsp25_Write32bitAddr(devHandle: Pusb_dev_handle; Opcode: byte; Addr: longword; buffer: array of byte; bufflen: integer): integer;

function UsbAsp25_ReadID(devHandle: Pusb_dev_handle; var ID: array of byte): integer;

function UsbAsp25_Wren(devHandle: Pusb_dev_handle): integer;
function UsbAsp25_Wrdi(devHandle: Pusb_dev_handle): integer;
function UsbAsp25_ChipErase(devHandle: Pusb_dev_handle): integer;

function UsbAsp25_WriteSR(devHandle: Pusb_dev_handle; sreg: byte; opcode: byte = $01): integer;
function UsbAsp25_WriteSR_2byte(devHandle: Pusb_dev_handle; sreg1, sreg2: byte): integer;
function UsbAsp25_ReadSR(devHandle: Pusb_dev_handle; var sreg: byte; opcode: byte = $05): integer;

function UsbAsp_SetISPSpeed(devHandle: Pusb_dev_handle; speed: byte): integer;

function UsbAsp25_WriteSSTB(devHandle: Pusb_dev_handle; Opcode: byte; Data: byte): integer;
function UsbAsp25_WriteSSTW(devHandle: Pusb_dev_handle; Opcode: byte; Data1, Data2: byte): integer;

implementation

uses Main;

//Пока отлипнет ромка
function UsbAsp25_Busy(devHandle: Pusb_dev_handle): boolean;
var
  sreg: byte;
begin
  Result := False;
  sreg := $FF;

  repeat
    UsbAsp25_ReadSR(devHandle, sreg);

    Application.ProcessMessages;
    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      Result := True;
      Exit;
    end;
  until((sreg and 1 = 0));
end;

//Вход в режим программирования
procedure EnterProgMode25(devHandle: Pusb_dev_handle);
var
  dummy: byte;
begin
  if CH341 then
  begin
    //CH341SetTimeout(0, 1000,1000);
     CH341SetStream(0, %10000001);
     exit;
  end;

  USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_CONNECT, 0, 0, 0, dummy);
  sleep(50);
end;

//Выход из режима программирования
procedure ExitProgMode25(devHandle: Pusb_dev_handle);
var
  dummy: byte;
begin
  if CH341 then
  begin
     CH341Set_D5_D0(0, 0, 0);
     exit;
  end;

  if devHandle <> nil then
    USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_DISCONNECT, 0, 0, 0, dummy);
end;

//Читает 3 байта id
function UsbAsp25_ReadID(devHandle: Pusb_dev_handle; var ID: array of byte): integer;
var
  buffer: array[0..2] of byte;
begin
  FillByte(buffer, 3, $FF);
  buffer[0] := $9F;
  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 1, buffer);
  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 1, 0, 3, buffer);
  move(buffer, ID, 3);
end;

//Возвращает сколько байт прочитали
function UsbAsp25_Read(devHandle: Pusb_dev_handle; Opcode: byte; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..3] of byte;
begin

  buff[0] := Opcode;
  buff[1] := hi(addr);
  buff[2] := hi(lo(addr));
  buff[3] := lo(addr);

  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 4, buff);
  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 1, 0, bufflen, buffer);
end;

function UsbAsp25_Read32bitAddr(devHandle: Pusb_dev_handle; Opcode: byte; Addr: longword; var buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..4] of byte;
begin

  buff[0] := Opcode;
  buff[1] := hi(hi(addr));
  buff[2] := lo(hi(addr));
  buff[3] := hi(lo(addr));
  buff[4] := lo(lo(addr));

  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 5, buff);
  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 1, 0, bufflen, buffer);
end;


function UsbAsp_SetISPSpeed(devHandle: Pusb_dev_handle; speed: byte): integer;
var
  buff: byte;
begin

  if CH341 then
  begin
    result := 0;
    exit;
  end;

  buff := $FF;
  USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_SETISPSCK, speed, 0, 1, buff);
  result := buff;

end;

function UsbAsp25_Wren(devHandle: Pusb_dev_handle): integer;
var
  buff: byte;
begin
  buff:= $06;
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 1, buff);
end;

function UsbAsp25_Wrdi(devHandle: Pusb_dev_handle): integer;
var
  buff: byte;
begin
  buff:= $04;
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 1, buff);
end;

function UsbAsp25_ChipErase(devHandle: Pusb_dev_handle): integer;
var
  buff: byte;
begin
  //Старые SST требуют 60H
  buff:= $60;
  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 1, buff);
  buff:= $C7;
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 1, buff);
end;

function UsbAsp25_WriteSR(devHandle: Pusb_dev_handle; sreg: byte; opcode: byte = $01): integer;
var
  buff: array[0..1] of byte;
begin
  //Старые SST требуют Enable-Write-Status-Register (50H)
  Buff[0] := $50;
  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 1, buff);
  //
  Buff[0] := opcode;
  Buff[1] := sreg;
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 2, buff);
end;

function UsbAsp25_WriteSR_2byte(devHandle: Pusb_dev_handle; sreg1, sreg2: byte): integer;
var
  buff: array[0..2] of byte;
begin
  //Старые SST требуют Enable-Write-Status-Register (50H)
  Buff[0] := $50;
  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 1, buff);

  //Если регистр из 2х байт
  Buff[0] := $01;
  Buff[1] := sreg1;
  Buff[2] := sreg2;
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 3, buff);
end;

function UsbAsp25_ReadSR(devHandle: Pusb_dev_handle; var sreg: byte; opcode: byte = $05): integer;
begin
  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 1, opcode);
  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 1, 0, 1, sreg);
end;

//Возвращает сколько байт записали
function UsbAsp25_Write(devHandle: Pusb_dev_handle; Opcode: byte; Addr: longword; buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..3] of byte;
begin

  buff[0] := Opcode;
  buff[1] := lo(hi(addr));
  buff[2] := hi(lo(addr));
  buff[3] := lo(lo(addr));

  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 4, buff);
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, bufflen, buffer);
end;

function UsbAsp25_Write32bitAddr(devHandle: Pusb_dev_handle; Opcode: byte; Addr: longword; buffer: array of byte; bufflen: integer): integer;
var
  buff: array[0..4] of byte;
begin

  buff[0] := Opcode;
  buff[1] := hi(hi(addr));
  buff[2] := lo(hi(addr));
  buff[3] := hi(lo(addr));
  buff[4] := lo(lo(addr));

  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 5, buff);
  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, bufflen, buffer);
end;

function UsbAsp25_WriteSSTB(devHandle: Pusb_dev_handle; Opcode: byte; Data: byte): integer;
var
  buff: array[0..1] of byte;
begin
  buff[0] := Opcode;
  buff[1] := Data;

  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 2, buff)-1;
end;

function UsbAsp25_WriteSSTW(devHandle: Pusb_dev_handle; Opcode: byte; Data1, Data2: byte): integer;
var
  buff: array[0..2] of byte;
begin
  buff[0] := Opcode;
  buff[1] := Data1;
  buff[2] := Data2;

  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 3, buff)-1;
end;

end.

