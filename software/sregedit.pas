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
    CheckBoxSB23: TCheckBox;
    CheckBoxSB22: TCheckBox;
    CheckBoxSB21: TCheckBox;
    CheckBoxSB20: TCheckBox;
    CheckBoxSB19: TCheckBox;
    CheckBoxSB18: TCheckBox;
    CheckBoxSB17: TCheckBox;
    CheckBoxSB16: TCheckBox;
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
    EditSreg3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure ButtonReadSregClick(Sender: TObject);
    procedure ButtonWriteSregClick(Sender: TObject);
    procedure EditSreg1Change(Sender: TObject);
    procedure EditSreg2Change(Sender: TObject);
    procedure CheckBoxChange(Sender: TObject);
    procedure EditSreg3Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  sregeditForm: TsregeditForm;

implementation

uses main, spi25, usbhid, msgstr, utilfunc;

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

procedure SetSreg3CheckBox(sreg3: byte);
begin
  with sregeditForm do
  begin
    if IsBitSet(sreg3, 0) then CheckBoxSB16.Checked:= true else CheckBoxSB16.Checked:= false;
    if IsBitSet(sreg3, 1) then CheckBoxSB17.Checked:= true else CheckBoxSB17.Checked:= false;
    if IsBitSet(sreg3, 2) then CheckBoxSB18.Checked:= true else CheckBoxSB18.Checked:= false;
    if IsBitSet(sreg3, 3) then CheckBoxSB19.Checked:= true else CheckBoxSB19.Checked:= false;
    if IsBitSet(sreg3, 4) then CheckBoxSB20.Checked:= true else CheckBoxSB20.Checked:= false;
    if IsBitSet(sreg3, 5) then CheckBoxSB21.Checked:= true else CheckBoxSB21.Checked:= false;
    if IsBitSet(sreg3, 6) then CheckBoxSB22.Checked:= true else CheckBoxSB22.Checked:= false;
    if IsBitSet(sreg3, 7) then CheckBoxSB23.Checked:= true else CheckBoxSB23.Checked:= false;
  end;
end;

function GetSreg3CheckBox(): byte;
begin
  with sregeditForm do
  begin
    result := 0;
    if CheckBoxSB16.Checked then result := SetBit(result, 0);
    if CheckBoxSB17.Checked then result := SetBit(result, 1);
    if CheckBoxSB18.Checked then result := SetBit(result, 2);
    if CheckBoxSB19.Checked then result := SetBit(result, 3);
    if CheckBoxSB20.Checked then result := SetBit(result, 4);
    if CheckBoxSB21.Checked then result := SetBit(result, 5);
    if CheckBoxSB22.Checked then result := SetBit(result, 6);
    if CheckBoxSB23.Checked then result := SetBit(result, 7);
  end;
end;

procedure TsregeditForm.ButtonReadSregClick(Sender: TObject);
var sreg1, sreg2, sreg3: byte;
begin
  if MainForm.ComboSPICMD.ItemIndex = SPI_CMD_25 then
  begin
  try
    if not OpenDevice() then exit;
    EnterProgMode25(SetSPISpeed(0));

    UsbAsp25_ReadSR(sreg1);
    UsbAsp25_ReadSR(sreg2, $35);
    UsbAsp25_ReadSR(sreg3, $15);

    SetSreg1CheckBox(sreg1);
    SetSreg2CheckBox(sreg2);
    SetSreg3CheckBox(sreg3);

    Editsreg1.Text:= IntToHex(sreg1, 2);
    Editsreg2.Text:= IntToHex(sreg2, 2);
    Editsreg3.Text:= IntToHex(sreg3, 2);

  finally
    ExitProgMode25;
    AsProgrammer.Programmer.DevClose;
  end;
  end;
end;

procedure TsregeditForm.ButtonWriteSregClick(Sender: TObject);
begin
  if MainForm.ComboSPICMD.ItemIndex = SPI_CMD_25 then
  begin
  try
    if not OpenDevice() then exit;
    EnterProgMode25(SetSPISpeed(0));

    UsbAsp25_WREN();
    UsbAsp25_WriteSR(GetSreg1CheckBox());

    while UsbAsp25_Busy() do
    begin
      Application.ProcessMessages;
      if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL);
        Exit;
      end;
    end;

    UsbAsp25_WREN();
    UsbAsp25_WriteSR_2byte(GetSreg1CheckBox(), GetSreg2CheckBox());

    while UsbAsp25_Busy() do
    begin
      Application.ProcessMessages;
      if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL);
        Exit;
      end;
    end;

    UsbAsp25_WREN();
    UsbAsp25_WriteSR(GetSreg3CheckBox(), $11);

    while UsbAsp25_Busy() do
    begin
      Application.ProcessMessages;
      if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL);
        Exit;
      end;
    end;

  finally
    ExitProgMode25;
    AsProgrammer.Programmer.DevClose;
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

procedure TsregeditForm.EditSreg3Change(Sender: TObject);
begin
  if IsNumber('$'+EditSreg3.Text) then
    SetSreg3CheckBox(StrToInt('$'+EditSreg3.Text));
end;

procedure TsregeditForm.CheckBoxChange(Sender: TObject);
begin
  EditSreg1.Text := IntToHex(GetSreg1CheckBox(), 2);
  EditSreg2.Text := IntToHex(GetSreg2CheckBox(), 2);
  EditSreg3.Text := IntToHex(GetSreg3CheckBox(), 2);
end;


end.

