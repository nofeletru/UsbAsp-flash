unit usbaspmulti;

{$mode objfpc}

interface

uses
  Classes, Forms, SysUtils, libusb, usbhid;

const

  USBASP_FUNC_DISCONNECT         = 2;
  USBASP_FUNC_SETISPSCK          = 10;

  USBASP_FUNC_25_CONNECT         = 50;
  USBASP_FUNC_25_READ            = 51;
  USBASP_FUNC_25_WRITE  	 = 52;


function UsbAspMulti_EnableEDI(devHandle: Pusb_dev_handle): integer;
function UsbAspMulti_WriteReg(devHandle: Pusb_dev_handle; RegAddr: Word; RegData: byte): integer;
function UsbAspMulti_ReadReg(devHandle: Pusb_dev_handle; RegAddr: Word; var RegData: byte): integer;

function UsbAspMulti_Read(devHandle: Pusb_dev_handle; Addr: longword; var Data: byte): integer;

function UsbAspMulti_ErasePage(devHandle: Pusb_dev_handle; page: longword): integer;
function UsbAspMulti_WritePage(devHandle: Pusb_dev_handle; page: longword; var Data: array of byte): integer;
function UsbAspMulti_Erase(devHandle: Pusb_dev_handle; chipsize: longword; pagesize: word): integer;

function UsbAspMulti_Busy(devHandle: Pusb_dev_handle): boolean;

implementation

uses Main;



function UsbAspMulti_EnableEDI(devHandle: Pusb_dev_handle): integer;
var
  Buff: array[0..4] of byte;
begin
  Buff[0] := $40;
  Buff[1] := 0;
  Buff[2] := $FE;
  Buff[3] := $AD;

  Buff[4] := $08;

  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 5, Buff);
end;

function UsbAspMulti_WriteReg(devHandle: Pusb_dev_handle; RegAddr: Word; RegData: byte): integer;
var
  Buff: array[0..4] of byte;
begin
  Buff[0] := $40;
  Buff[1] := 0;

  Buff[2] := hi(RegAddr);
  Buff[3] := lo(RegAddr);

  Buff[4] := RegData;

  result := USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 1, 0, 5, buff);
end;


function UsbAspMulti_ReadReg(devHandle: Pusb_dev_handle; RegAddr: Word; var RegData: byte): integer;
var
  Buff: array[0..4] of byte;
  ReadyStat: byte;
begin
  Buff[0] := $30;
  Buff[1] := 0;

  Buff[2] := hi(RegAddr);
  Buff[3] := lo(RegAddr);

  USBSendControlMessage(devHandle, PC2USB, USBASP_FUNC_25_WRITE, 0, 0, 4, buff);

  //Ready
  repeat
    Application.ProcessMessages;
    if MainForm.ButtonCancel.Tag <> 0 then Exit;

    USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 0, 0, 1, ReadyStat);
  until (ReadyStat = $50);


  result := USBSendControlMessage(devHandle, USB2PC, USBASP_FUNC_25_READ, 1, 0, 1, regdata);
end;

function UsbAspMulti_Read(devHandle: Pusb_dev_handle; Addr: longword; var Data: byte): integer;
begin

   UsbAspMulti_WriteReg(devHandle, $FEAA, lo(hi(Addr)) );
   UsbAspMulti_WriteReg(devHandle, $FEA9, hi(lo(Addr)) );
   UsbAspMulti_WriteReg(devHandle, $FEA8, lo(lo(Addr)) );

   UsbAspMulti_WriteReg(devHandle, $FEAC, $03);

   Result := UsbAspMulti_ReadReg(devHandle, $FEAB, Data);

end;

//Page128
function UsbAspMulti_WritePage(devHandle: Pusb_dev_handle; page: longword; var Data: array of byte): integer;
var
  i: integer;
  busy: boolean;
begin
  //busy
   repeat
     busy := UsbAspMulti_Busy(devHandle);
   until busy = false;

   UsbAspMulti_WriteReg(devHandle, $FEAA, lo(hi(page)) );
   UsbAspMulti_WriteReg(devHandle, $FEA9, hi(lo(page)) );
   UsbAspMulti_WriteReg(devHandle, $FEA8, lo(lo(page)) );

   UsbAspMulti_WriteReg(devHandle, $FEAC, $80); //clr buff

   for i:=0 to 127 do
   begin
     UsbAspMulti_WriteReg(devHandle, $FEA8, lo(page) + i );
     UsbAspMulti_WriteReg(devHandle, $FEAB, Data[i]);
     UsbAspMulti_WriteReg(devHandle, $FEAC, $02);
   end;

   UsbAspMulti_WriteReg(devHandle, $FEAC, $70);
end;

function UsbAspMulti_ErasePage(devHandle: Pusb_dev_handle; page: longword): integer;
var
  busy: boolean;
begin
  //busy
   repeat
     busy := UsbAspMulti_Busy(devHandle);
   until busy = false;

   UsbAspMulti_WriteReg(devHandle, $FEAA, lo(hi(page)) );
   UsbAspMulti_WriteReg(devHandle, $FEA9, hi(lo(page)) );
   UsbAspMulti_WriteReg(devHandle, $FEA8, lo(lo(page)) );

   result := UsbAspMulti_WriteReg(devHandle, $FEAC, $20);
end;

function UsbAspMulti_Erase(devHandle: Pusb_dev_handle; chipsize: longword; pagesize: word): integer;
var
  i: integer;
begin

  for i:= 0 to (chipsize div pagesize)-1 do UsbAspMulti_ErasePage(devHandle, i * pagesize);

end;

function UsbAspMulti_Busy(devHandle: Pusb_dev_handle): boolean;
var
  sreg: byte;
begin
    Application.ProcessMessages;
    if MainForm.ButtonCancel.Tag <> 0 then Exit;

    UsbAspMulti_ReadReg(devHandle, $FEAD, sreg);
    if (sreg and 2) = 0 then Result := False else Result := True;
end;

end.

