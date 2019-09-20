unit spimulti;

{$mode objfpc}

interface

uses
  Classes, Forms, SysUtils;


function UsbAspMulti_EnableEDI(): integer;
function UsbAspMulti_WriteReg(RegAddr: Word; RegData: byte): integer;
function UsbAspMulti_ReadReg(RegAddr: Word; var RegData: byte): integer;

function UsbAspMulti_Read(Addr: longword; var Data: byte): integer;

function UsbAspMulti_ErasePage(Addr: longword): integer;
function UsbAspMulti_WritePage(Addr: longword; var Data: array of byte): integer;

function UsbAspMulti_Busy(): boolean;

implementation

uses Main;

//Первая команда, после ресета, должна быть на частоте не более 8MHz

//Write enable of EFCMD register,0xFEAC.
function UsbAspMulti_EnableEDI(): integer;
var
  Buff: array[0..4] of byte;
begin
  Buff[0] := $40;
  Buff[1] := 0;
  Buff[2] := $FE;
  Buff[3] := $AD;

  Buff[4] := $08;

  result := AsProgrammer.Programmer.SPIWrite(1, 5, Buff);
end;

function UsbAspMulti_WriteReg(RegAddr: Word; RegData: byte): integer;
var
  Buff: array[0..4] of byte;
begin
  Buff[0] := $40;
  Buff[1] := 0;

  Buff[2] := hi(RegAddr);
  Buff[3] := lo(RegAddr);

  Buff[4] := RegData;

  result := AsProgrammer.Programmer.SPIWrite(1, 5, Buff);
end;


function UsbAspMulti_ReadReg(RegAddr: Word; var RegData: byte): integer;
var
  Buff: array[0..4] of byte;
  ReadyStat: byte = 0;
begin
  Buff[0] := $30;
  Buff[1] := 0;

  Buff[2] := hi(RegAddr);
  Buff[3] := lo(RegAddr);

  AsProgrammer.Programmer.SPIWrite(0, 4, Buff);

  //Ready
  repeat
    Application.ProcessMessages;
    if UserCancel then Exit;

    AsProgrammer.Programmer.SPIRead(0, 1, ReadyStat);
  until (ReadyStat = $50);

  result := AsProgrammer.Programmer.SPIRead(1, 1, regdata);
end;

function UsbAspMulti_Read(Addr: longword; var Data: byte): integer;
begin

   UsbAspMulti_WriteReg($FEAA, lo(hi(Addr)) );
   UsbAspMulti_WriteReg($FEA9, hi(lo(Addr)) );
   UsbAspMulti_WriteReg($FEA8, lo(lo(Addr)) );

   UsbAspMulti_WriteReg($FEAC, $03);

   Result := UsbAspMulti_ReadReg($FEAB, Data);

end;

//Page128
function UsbAspMulti_WritePage(Addr: longword; var Data: array of byte): integer;
var
  i: integer;
  busy: boolean;
begin
   UsbAspMulti_WriteReg($FEAA, lo(hi(Addr)) );
   UsbAspMulti_WriteReg($FEA9, hi(lo(Addr)) );
   //UsbAspMulti_WriteReg($FEA8, lo(lo(page)) );

   UsbAspMulti_WriteReg($FEAC, $80); //clr buff

   for i:=0 to 127 do
   begin
     UsbAspMulti_WriteReg($FEA8, lo(lo(Addr)) + i );
     UsbAspMulti_WriteReg($FEAB, Data[i]);
     UsbAspMulti_WriteReg($FEAC, $02); //latch page
   end;

   UsbAspMulti_WriteReg($FEAC, $70); //prog page
end;

function UsbAspMulti_ErasePage(Addr: longword): integer;
begin
   UsbAspMulti_WriteReg($FEAA, lo(hi(Addr)) );
   UsbAspMulti_WriteReg($FEA9, hi(lo(Addr)) );
   UsbAspMulti_WriteReg($FEA8, lo(lo(Addr)) );

   result := UsbAspMulti_WriteReg($FEAC, $20);
end;

function UsbAspMulti_Busy(): boolean;
var
  sreg: byte = $FF;
begin
  UsbAspMulti_ReadReg($FEAD, sreg);
  if (sreg and 2) = 0 then Result := False else Result := True;
end;

end.

