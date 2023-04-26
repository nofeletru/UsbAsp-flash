unit sregedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type
  TSregTypeList = (ST_MACRONIX, ST_WINBOND, ST_GIGADEVICE);

  { TsregeditForm }

  TsregeditForm = class(TForm)
    ButtonReadSreg: TButton;
    ButtonWriteSreg: TButton;
    CheckBoxSB0: TCheckBox;
    CheckBoxSB1: TCheckBox;
    CheckBoxSB10: TCheckBox;
    CheckBoxSB11: TCheckBox;
    CheckBoxSB12: TCheckBox;
    CheckBoxSB13: TCheckBox;
    CheckBoxSB14: TCheckBox;
    CheckBoxSB15: TCheckBox;
    CheckBoxSB16: TCheckBox;
    CheckBoxSB17: TCheckBox;
    CheckBoxSB18: TCheckBox;
    CheckBoxSB19: TCheckBox;
    CheckBoxSB2: TCheckBox;
    CheckBoxSB20: TCheckBox;
    CheckBoxSB21: TCheckBox;
    CheckBoxSB22: TCheckBox;
    CheckBoxSB23: TCheckBox;
    CheckBoxSB3: TCheckBox;
    CheckBoxSB4: TCheckBox;
    CheckBoxSB5: TCheckBox;
    CheckBoxSB6: TCheckBox;
    CheckBoxSB7: TCheckBox;
    CheckBoxSB8: TCheckBox;
    CheckBoxSB9: TCheckBox;
    ComboBoxSRType: TComboBox;
    GroupBoxSREG2: TGroupBox;
    GroupBoxSREG3: TGroupBox;
    GroupBoxSREG1: TGroupBox;
    procedure ButtonReadSregClick(Sender: TObject);
    procedure ButtonWriteSregClick(Sender: TObject);
    procedure ComboBoxSRTypeChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  sregeditForm: TsregeditForm;
  SREGType: TSregTypeList;

implementation

uses main, spi25, msgstr, utilfunc;

{$R *.lfm}




{ TsregeditForm }

procedure SetSreg1CheckBox(sreg1: byte);
begin
  with sregeditForm do
  begin
    CheckBoxSB0.Checked:= IsBitSet(sreg1, 0);
    CheckBoxSB1.Checked:= IsBitSet(sreg1, 1);
    CheckBoxSB2.Checked:= IsBitSet(sreg1, 2);
    CheckBoxSB3.Checked:= IsBitSet(sreg1, 3);
    CheckBoxSB4.Checked:= IsBitSet(sreg1, 4);
    CheckBoxSB5.Checked:= IsBitSet(sreg1, 5);
    CheckBoxSB6.Checked:= IsBitSet(sreg1, 6);
    CheckBoxSB7.Checked:= IsBitSet(sreg1, 7);
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
    CheckBoxSB8.Checked:= IsBitSet(sreg2, 0);
    CheckBoxSB9.Checked:= IsBitSet(sreg2, 1);
    CheckBoxSB10.Checked:= IsBitSet(sreg2, 2);
    CheckBoxSB11.Checked:= IsBitSet(sreg2, 3);
    CheckBoxSB12.Checked:= IsBitSet(sreg2, 4);
    CheckBoxSB13.Checked:= IsBitSet(sreg2, 5);
    CheckBoxSB14.Checked:= IsBitSet(sreg2, 6);
    CheckBoxSB15.Checked:= IsBitSet(sreg2, 7);
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
    CheckBoxSB16.Checked:= IsBitSet(sreg3, 0);
    CheckBoxSB17.Checked:= IsBitSet(sreg3, 1);
    CheckBoxSB18.Checked:= IsBitSet(sreg3, 2);
    CheckBoxSB19.Checked:= IsBitSet(sreg3, 3);
    CheckBoxSB20.Checked:= IsBitSet(sreg3, 4);
    CheckBoxSB21.Checked:= IsBitSet(sreg3, 5);
    CheckBoxSB22.Checked:= IsBitSet(sreg3, 6);
    CheckBoxSB23.Checked:= IsBitSet(sreg3, 7);
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
    EnterProgMode25(SetSPISpeed(0), MainForm.MenuSendAB.Checked);

    UsbAsp25_ReadSR(sreg1);

    if SREGType = ST_MACRONIX then
    begin
      UsbAsp25_ReadSR(sreg2, $15);
      sreg3 := 0;
    end;

    if (SREGType = ST_WINBOND) or (SREGType = ST_GIGADEVICE) then
    begin
      UsbAsp25_ReadSR(sreg2, $35);
      UsbAsp25_ReadSR(sreg3, $15);
    end;

    SetSreg1CheckBox(sreg1);
    SetSreg2CheckBox(sreg2);
    SetSreg3CheckBox(sreg3);

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
    EnterProgMode25(SetSPISpeed(0), MainForm.MenuSendAB.Checked);

    UsbAsp25_WREN();
    UsbAsp25_WriteSR(GetSreg1CheckBox());

    while UsbAsp25_Busy() do
    begin
      Application.ProcessMessages;
      if UserCancel then Exit;
    end;

    if SREGType = ST_MACRONIX then
    begin
      UsbAsp25_WREN();
      UsbAsp25_WriteSR_2byte(GetSreg1CheckBox(), GetSreg2CheckBox());

      while UsbAsp25_Busy() do
      begin
        Application.ProcessMessages;
        if UserCancel then Exit;
      end;
    end;

    if (SREGType = ST_WINBOND) or (SREGType = ST_GIGADEVICE) then
    begin
      UsbAsp25_WREN();
      UsbAsp25_WriteSR(GetSreg2CheckBox(), $31);

      while UsbAsp25_Busy() do
      begin
        Application.ProcessMessages;
        if UserCancel then Exit;
      end;

      UsbAsp25_WREN();
      UsbAsp25_WriteSR(GetSreg3CheckBox(), $11);

      while UsbAsp25_Busy() do
      begin
        Application.ProcessMessages;
        if UserCancel then Exit;
      end;
    end;

  finally
    ExitProgMode25;
    AsProgrammer.Programmer.DevClose;
  end;
  end;
end;

procedure TsregeditForm.ComboBoxSRTypeChange(Sender: TObject);
begin
  if UpCase(ComboBoxSRType.Text) = 'WINBOND' then
  begin
    SREGType := ST_WINBOND;
    GroupBoxSREG1.Enabled:= true;
    GroupBoxSREG2.Enabled:= true;
    GroupBoxSREG3.Enabled:= true;
  end;

  if UpCase(ComboBoxSRType.Text) = 'GIGADEVICE' then
  begin
    SREGType := ST_GIGADEVICE;
    GroupBoxSREG1.Enabled:= true;
    GroupBoxSREG2.Enabled:= true;
    GroupBoxSREG3.Enabled:= true;
  end;

  if UpCase(ComboBoxSRType.Text) = 'MACRONIX' then
  begin
    SREGType := ST_MACRONIX;
    GroupBoxSREG1.Enabled:= true;
    GroupBoxSREG2.Enabled:= true;
    GroupBoxSREG3.Enabled:= false;
  end;
end;

procedure TsregeditForm.FormShow(Sender: TObject);
begin
  ComboBoxSRTypeChange(Sender);
end;


end.

