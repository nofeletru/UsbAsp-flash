unit sregedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TsregeditForm }

  TsregeditForm = class(TForm)
    ButtonReadSreg: TButton;
    ButtonWriteSreg: TButton;
    CheckBoxSB7: TCheckBox;
    CheckBoxSB14: TCheckBox;
    CheckBoxSB13: TCheckBox;
    CheckBoxSB12: TCheckBox;
    CheckBoxSB11: TCheckBox;
    CheckBoxSB10: TCheckBox;
    CheckBoxSB9: TCheckBox;
    CheckBoxSB8: TCheckBox;
    CheckBoxSB6: TCheckBox;
    CheckBoxSB5: TCheckBox;
    CheckBoxSB4: TCheckBox;
    CheckBoxSB3: TCheckBox;
    CheckBoxSB2: TCheckBox;
    CheckBoxSB1: TCheckBox;
    CheckBoxSB0: TCheckBox;
    CheckBoxSB15: TCheckBox;
    EditSreg1: TEdit;
    EditSreg2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure ButtonReadSregClick(Sender: TObject);
    procedure ButtonWriteSregClick(Sender: TObject);
    procedure EditSreg1Change(Sender: TObject);
    procedure EditSreg2Change(Sender: TObject);
    procedure CheckBoxChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  sregeditForm: TsregeditForm;

implementation

uses main, usbasp25, usbhid, msgstr;

{$R *.lfm}

{ TsregeditForm }

procedure SetSreg1CheckBox(sreg1: byte);
begin
  with sregeditForm do
  begin
    if IsBitSet(sreg1, 0) then CheckBoxSB0.Checked:= true else CheckBoxSB0.Checked:= false;
    if IsBitSet(sreg1, 1) then CheckBoxSB1.Checked:= true else CheckBoxSB1.Checked:= false;
    if IsBitSet(sreg1, 2) then CheckBoxSB2.Checked:= true else CheckBoxSB2.Checked:= false;
    if IsBitSet(sreg1, 3) then CheckBoxSB3.Checked:= true else CheckBoxSB3.Checked:= false;
    if IsBitSet(sreg1, 4) then CheckBoxSB4.Checked:= true else CheckBoxSB4.Checked:= false;
    if IsBitSet(sreg1, 5) then CheckBoxSB5.Checked:= true else CheckBoxSB5.Checked:= false;
    if IsBitSet(sreg1, 6) then CheckBoxSB6.Checked:= true else CheckBoxSB6.Checked:= false;
    if IsBitSet(sreg1, 7) then CheckBoxSB7.Checked:= true else CheckBoxSB7.Checked:= false;
  end;
end;

function GetSreg1CheckBox(): byte;
begin
  with sregeditForm do
  begin
    result := 0;
    if CheckBoxSB0.Checked then result := SetBit(result, 0);
    if CheckBoxSB1.Checked then result := SetBit(result, 1);
    if CheckBoxSB2.Checked then result := SetBit(result, 2);
    if CheckBoxSB3.Checked then result := SetBit(result, 3);
    if CheckBoxSB4.Checked then result := SetBit(result, 4);
    if CheckBoxSB5.Checked then result := SetBit(result, 5);
    if CheckBoxSB6.Checked then result := SetBit(result, 6);
    if CheckBoxSB7.Checked then result := SetBit(result, 7);
  end;
end;

procedure SetSreg2CheckBox(sreg2: byte);
begin
  with sregeditForm do
  begin
    if IsBitSet(sreg2, 0) then CheckBoxSB8.Checked:= true else CheckBoxSB8.Checked:= false;
    if IsBitSet(sreg2, 1) then CheckBoxSB9.Checked:= true else CheckBoxSB9.Checked:= false;
    if IsBitSet(sreg2, 2) then CheckBoxSB10.Checked:= true else CheckBoxSB10.Checked:= false;
    if IsBitSet(sreg2, 3) then CheckBoxSB11.Checked:= true else CheckBoxSB11.Checked:= false;
    if IsBitSet(sreg2, 4) then CheckBoxSB12.Checked:= true else CheckBoxSB12.Checked:= false;
    if IsBitSet(sreg2, 5) then CheckBoxSB13.Checked:= true else CheckBoxSB13.Checked:= false;
    if IsBitSet(sreg2, 6) then CheckBoxSB14.Checked:= true else CheckBoxSB14.Checked:= false;
    if IsBitSet(sreg2, 7) then CheckBoxSB15.Checked:= true else CheckBoxSB15.Checked:= false;
  end;
end;

function GetSreg2CheckBox(): byte;
begin
  with sregeditForm do
  begin
    result := 0;
    if CheckBoxSB8.Checked then result := SetBit(result, 0);
    if CheckBoxSB9.Checked then result := SetBit(result, 1);
    if CheckBoxSB10.Checked then result := SetBit(result, 2);
    if CheckBoxSB11.Checked then result := SetBit(result, 3);
    if CheckBoxSB12.Checked then result := SetBit(result, 4);
    if CheckBoxSB13.Checked then result := SetBit(result, 5);
    if CheckBoxSB14.Checked then result := SetBit(result, 6);
    if CheckBoxSB15.Checked then result := SetBit(result, 7);
  end;
end;

procedure TsregeditForm.ButtonReadSregClick(Sender: TObject);
var sreg1, sreg2: byte;
begin
  if MainForm.ComboSPICMD.ItemIndex = SPI_CMD_25 then
  begin
  try
    if not OpenDevice() then exit;
    if not SetSPISpeed(0) then exit;
    EnterProgMode25(hUSBdev);

    UsbAsp25_ReadSR(hUSBDev, sreg1);
    UsbAsp25_ReadSR(hUSBDev, sreg2, $35);

    SetSreg1CheckBox(sreg1);
    SetSreg2CheckBox(sreg2);

    Editsreg1.Text:= IntToHex(sreg1, 2);
    Editsreg2.Text:= IntToHex(sreg2, 2);

  finally
    ExitProgMode25(hUSBdev);
    USB_Dev_Close(hUSBdev);
  end;
  end;
end;

procedure TsregeditForm.ButtonWriteSregClick(Sender: TObject);
begin
  if MainForm.ComboSPICMD.ItemIndex = SPI_CMD_25 then
  begin
  try
    if not OpenDevice() then exit;
    if not SetSPISpeed(0) then exit;
    EnterProgMode25(hUSBdev);

    UsbAsp25_WREN(hUSBDev);
    UsbAsp25_WriteSR(hUSBDev, GetSreg1CheckBox());

    if UsbAsp25_Busy(hUSBDev) then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Exit;
    end;

    UsbAsp25_WREN(hUSBDev);
    UsbAsp25_WriteSR_2byte(hUSBDev, GetSreg1CheckBox(), GetSreg2CheckBox());

    if UsbAsp25_Busy(hUSBDev) then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Exit;
    end;

  finally
    ExitProgMode25(hUSBdev);
    USB_Dev_Close(hUSBdev);
  end;
  end;
end;

procedure TsregeditForm.EditSreg1Change(Sender: TObject);
begin
  if IsNumber('$'+EditSreg1.Text) then
    SetSreg1CheckBox(StrToInt('$'+EditSreg1.Text));
end;

procedure TsregeditForm.EditSreg2Change(Sender: TObject);
begin
  if IsNumber('$'+EditSreg2.Text) then
    SetSreg2CheckBox(StrToInt('$'+EditSreg2.Text));
end;

procedure TsregeditForm.CheckBoxChange(Sender: TObject);
begin
  EditSreg1.Text := IntToHex(GetSreg1CheckBox(), 2);
  EditSreg2.Text := IntToHex(GetSreg2CheckBox(), 2);
end;

end.

