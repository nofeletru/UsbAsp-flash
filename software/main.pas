unit main;

//TODO: at45 установка размера странцы
//TODO: at45 Проверка размера страницы перед операциями


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazFileUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, Menus, ActnList, Buttons, RichMemo, KHexEditor,
  KEditCommon, StrUtils, usbasp25, usbasp45, usbasp95, usbaspi2c, usbaspmw,
  usbaspmulti, usbhid, libusb, dos, XMLRead, XMLWrite, DOM, KControls, msgstr,
  Translations, LCLProc, LCLTranslator, LResources, search, sregedit,
  utilfunc, CH341DLL, ch341mw, findchip, avrispmk2, DateUtils, lazUTF8, pascalc,
  ScriptsFunc, ScriptEdit;

type

  { TMainForm }

  TMainForm = class(TForm)
    CheckBox_I2C_A1: TToggleBox;
    CheckBox_I2C_A0: TToggleBox;
    CheckBox_I2C_ByteRead: TCheckBox;
    CheckBox_I2C_DevA6: TToggleBox;
    CheckBox_I2C_DevA5: TToggleBox;
    CheckBox_I2C_DevA4: TToggleBox;
    CheckBox_I2C_A2: TToggleBox;
    ComboAddrType: TComboBox;
    ComboSPICMD: TComboBox;
    KHexEditor: TKHexEditor;
    ComboChipSize: TComboBox;
    ComboMWBitLen: TComboBox;
    ComboPageSize: TComboBox;
    GroupChipSettings: TGroupBox;
    ImageList: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label_I2C_DevAddr: TLabel;
    LabelSPICMD: TLabel;
    LabelChipName: TLabel;
    MainMenu: TMainMenu;
    Menu32Khz: TMenuItem;
    Menu93_75Khz: TMenuItem;
    MenuChip: TMenuItem;
    MenuAutoCheck: TMenuItem;
    ComboItem1: TMenuItem;
    Menu3Mhz: TMenuItem;
    MenuIgnoreBusyBit: TMenuItem;
    MenuGotoOffset: TMenuItem;
    MenuFind: TMenuItem;
    MenuItem1: TMenuItem;
    MenuCopyToClip: TMenuItem;
    CopyLogMenuItem: TMenuItem;
    ClearLogMenuItem: TMenuItem;
    MenuHWUSBASP: TMenuItem;
    MenuHWCH341A: TMenuItem;
    MenuFindChip: TMenuItem;
    MenuHWAVRISP: TMenuItem;
    MenuAVRISPSPIClock: TMenuItem;
    MenuAVRISP8MHz: TMenuItem;
    MenuAVRISP4MHz: TMenuItem;
    MenuAVRISP2MHz: TMenuItem;
    MenuAVRISP1MHz: TMenuItem;
    MenuAVRISP500KHz: TMenuItem;
    MenuAVRISP250KHz: TMenuItem;
    MenuAVRISP125KHz: TMenuItem;
    LangMenuItem: TMenuItem;
    BlankCheckMenuItem: TMenuItem;
    ScriptsMenuItem: TMenuItem;
    MenuItemHardware: TMenuItem;
    MenuItemBenchmark: TMenuItem;
    MenuItemEditSreg: TMenuItem;
    MenuItemReadSreg: TMenuItem;
    MenuItemLockFlash: TMenuItem;
    MenuItem4: TMenuItem;
    MenuMW8Khz: TMenuItem;
    MenuMW16Khz: TMenuItem;
    MenuMicrowire: TMenuItem;
    MenuMW32Khz: TMenuItem;
    MenuMWClock: TMenuItem;
    MenuOptions: TMenuItem;
    MenuSPI: TMenuItem;
    MenuSPIClock: TMenuItem;
    Menu1_5Mhz: TMenuItem;
    Menu750Khz: TMenuItem;
    Menu375Khz: TMenuItem;
    Menu187_5Khz: TMenuItem;
    OpenDialog: TOpenDialog;
    DropDownMenu: TPopupMenu;
    EditorPopupMenu: TPopupMenu;
    LogPopupMenu: TPopupMenu;
    DropdownMenuLock: TPopupMenu;
    Panel_I2C_DevAddr: TPanel;
    BlankCheckDropDownMenu: TPopupMenu;
    ProgressBar: TProgressBar;
    RadioI2C: TRadioButton;
    RadioMw: TRadioButton;
    RadioSPI: TRadioButton;
    Log: TRichMemo;
    SaveDialog: TSaveDialog;
    StatusBar: TStatusBar;
    CheckBox_I2C_DevA7: TToggleBox;
    ToolBar: TToolBar;
    ButtonRead: TToolButton;
    ButtonWrite: TToolButton;
    ButtonVerify: TToolButton;
    ToolButton1: TToolButton;
    ButtonReadID: TToolButton;
    ButtonErase: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ButtonBlock: TToolButton;
    ButtonOpenHex: TToolButton;
    ButtonSaveHex: TToolButton;
    ButtonCancel: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    procedure BlankCheckMenuItemClick(Sender: TObject);
    procedure ButtonEraseClick(Sender: TObject);
    procedure ButtonReadClick(Sender: TObject);
    procedure ClearLogMenuItemClick(Sender: TObject);
    procedure ComboSPICMDChange(Sender: TObject);
    procedure CopyLogMenuItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChipClick(Sender: TObject);
    procedure ChangeLang(Sender: TObject);
    procedure KHexEditorChange(Sender: TObject);
    procedure ComboItem1Click(Sender: TObject);
    procedure KHexEditorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure MenuHWAVRISPClick(Sender: TObject);
    procedure MenuCopyToClipClick(Sender: TObject);
    procedure MenuFindChipClick(Sender: TObject);
    procedure MenuFindClick(Sender: TObject);
    procedure MenuGotoOffsetClick(Sender: TObject);
    procedure MenuHWCH341AClick(Sender: TObject);
    procedure MenuHWUSBASPClick(Sender: TObject);
    procedure MenuItemBenchmarkClick(Sender: TObject);
    procedure MenuItemEditSregClick(Sender: TObject);
    procedure MenuItemLockFlashClick(Sender: TObject);
    procedure MenuItemReadSregClick(Sender: TObject);
    procedure RadioI2CChange(Sender: TObject);
    procedure RadioMwChange(Sender: TObject);
    procedure RadioSPIChange(Sender: TObject);
    procedure ButtonWriteClick(Sender: TObject);
    procedure ButtonVerifyClick(Sender: TObject);
    procedure ButtonBlockClick(Sender: TObject);
    procedure ButtonReadIDClick(Sender: TObject);
    procedure ButtonOpenHexClick(Sender: TObject);
    procedure ButtonSaveHexClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure I2C_DevAddrChange(Sender: TObject);
    procedure ScriptsMenuItemClick(Sender: TObject);
    procedure VerifyFlash(BlankCheck: boolean = false);
  private
    { private declarations }
  public
    { public declarations }

  end;

  procedure LogPrint(text: string; AColor: TColor = clDefault);
  function UsbAspEEPROMSupport(): integer;
  procedure SaveOptions(XMLfile: TXMLDocument);
  Procedure LoadOptions(XMLfile: TXMLDocument);
  procedure LoadXML;
  procedure Translate(XMLfile: TXMLDocument);
  function OpenDevice: boolean;
  function SetSPISpeed(OverrideSpeed: byte): boolean;
  procedure SyncUI_ICParam();

const
  SPI_CMD_25             = 0;
  SPI_CMD_45             = 1;
  SPI_CMD_KB             = 2;
  SPI_CMD_95             = 3;

  HW_USBASP              = 0;
  HW_CH341A              = 1;
  HW_AVRISPMK2           = 2;

  ChipListFileName       = 'chiplist.xml';
  SettingsFileName       = 'settings.xml';
  ScriptsPath            = 'scripts'+DirectorySeparator;

type
  TCurrent_HW = (CH341, AVRISP, USBASP);

  TCurrentICParam = record
    Name: string;
    Page: Word;
    Size: Longword;
    SpiCmd: byte;
    I2CAddrType: byte;
    MWAddLen: byte;

    Script: string;
  end;


var
  MainForm: TMainForm;
  ChipListFile: TXMLDocument;
  SettingsFile: TXMLDocument;
  hUSBDev: pusb_dev_handle; //Хендл usbasp
  Current_HW: TCurrent_HW = USBASP;
  CurrentICParam: TCurrentICParam;
  ScriptEngine: TPasCalc;
  RomF: TMemoryStream;

implementation


var
  DeviceDescription: TDeviceDescription;
  avrisp_DeviceDescription: TDeviceDescription;
  TimeCounter: TDateTime;
  CurrentLang: string = 'ru';

{$R *.lfm}

procedure SyncUI_ICParam();
begin
  CurrentICParam.SpiCmd := MainForm.ComboSPICMD.ItemIndex;
  CurrentICParam.I2CAddrType := MainForm.ComboAddrType.ItemIndex;

  if IsNumber(MainForm.ComboMWBitLen.Text) then
    CurrentICParam.MWAddLen := StrToInt(MainForm.ComboMWBitLen.Text) else
      CurrentICParam.MWAddLen := 0;
  if IsNumber(MainForm.ComboPageSize.Text) then
    CurrentICParam.Page := StrToInt(MainForm.ComboPageSize.Text) else
      CurrentICParam.Page := 0;
  if IsNumber(MainForm.ComboChipSize.Text) then
    CurrentICParam.Size := StrToInt(MainForm.ComboChipSize.Text) else
      CurrentICParam.Size := 0;
end;

procedure LoadXML;
var
  RootNode: TDOMNode;
begin
  ChipListFile := nil;
  SettingsFile := nil;
  if FileExists(ChipListFileName) then
  begin
    try
      ReadXMLFile(ChipListFile, ChipListFileName);
    except
      on E: EXMLReadError do
      begin
        ShowMessage(E.Message);
        ChipListFile := nil;
      end;
    end;
  end;

  if FileExists(SettingsFileName) then
  begin
    try
      ReadXMLFile(SettingsFile, SettingsFileName);
    except
      on E: EXMLReadError do
      begin
        ShowMessage(E.Message);
        SettingsFile := nil;
      end;
    end;
  end else
  begin
    SettingsFile := TXMLDocument.Create;
    // Create a root node
    RootNode := SettingsFile.CreateElement('settings');
    SettingsFile.Appendchild(RootNode);
  end;

end;

procedure TMainForm.ChangeLang(Sender: TObject);
begin
  CurrentLang := TMenuItem(Sender).Hint;

  Translations.TranslateResourceStrings(GetCurrentDir + '/lang/' + CurrentLang + '.po');
  LRSTranslator.Free;
  LRSTranslator:= TPOTranslator.Create(GetCurrentDir + '/lang/' + CurrentLang + '.po');
  TPOTranslator(LRSTranslator).UpdateTranslation(MainForm);
end;

procedure LoadLangList();
var
  LangDir: string;
  LangName: string;
  LangFile: Text;
  SearchRec : TSearchRec;
  MenuItem: TMenuItem;
begin
  LangDir := GetCurrentDir + '/lang/';

  If FindFirstUTF8(LangDir+'*.po', faAnyFile, SearchRec) = 0 then
  begin
    Repeat
      AssignFile(LangFile, LangDir+SearchRec.Name);
      Reset(LangFile);
      ReadLn(LangFile, LangName);
      CloseFile(LangFile);
      Delete(LangName, 1, 1);

      MenuItem := NewItem(LangName, 0, False, True, @MainForm.ChangeLang, 0, '');
      MenuItem.Hint := ExtractFileNameOnly(SearchRec.Name);
      MenuItem.AutoCheck := true;
      MenuItem.RadioItem := true;
      MainForm.LangMenuItem.Add(MenuItem);
      if MenuItem.Hint = Currentlang then MenuItem.Checked := true;

    Until FindNextUTF8(SearchRec) <> 0;
  end;

  FindCloseUTF8(SearchRec);
end;

procedure Translate(XMLfile: TXMLDocument);
var
   PODirectory: String;
   Node: TDOMNode;
begin

  PODirectory:= GetCurrentDir + '/lang/';
  CurrentLang:='';

  if XMLfile <> nil then
  begin

      Node := XMLfile.DocumentElement.FindNode('locale');

      if (Node <> nil) then
      if (Node.HasAttributes) then
      begin

        if  Node.Attributes.GetNamedItem('lang') <> nil then
          CurrentLang := UTF16ToUTF8(Node.Attributes.GetNamedItem('lang').NodeValue);

      end;
  end;

  if CurrentLang = '' then
  begin
    CurrentLang := 'ru';
    Exit;
  end;

  if FileExistsUTF8(PODirectory + CurrentLang + '.po') then
  begin
    LRSTranslator:= TPOTranslator.Create(PODirectory + CurrentLang + '.po');
    Translations.TranslateResourceStrings(PODirectory + CurrentLang + '.po');
  end;

end;               

procedure LogPrint(text: string; AColor: TColor = clDefault);
var
    fp: TFontParams;
    SelStart, SelLength: Integer;
begin
  SelLength := UTF8Length(text);
  SelStart := UTF8Length(MainForm.Log.Text);

  MainForm.Log.Lines.Add(text);

  MainForm.Log.GetTextAttributes(SelStart, fp);
  fp.Color := AColor;
  MainForm.Log.SetTextAttributes(SelStart, SelLength, fp);

end;

//Получаем хедл usbasp
function OpenDevice: boolean;
var
  err, i: integer;
begin

  if Current_HW = CH341 then
  begin

    for i:=0 to mCH341_MAX_NUMBER-1 do
    begin
      err := CH341OpenDevice(i);
      if not err < 0 then Break;
    end;

    if err < 0 then
    begin
      LogPrint(STR_CONNECT_ERROR_CH+'('+IntToStr(err)+')', ClRed);
      result := false;
      Exit;
    end else
    begin
       LogPrint(STR_CURR_HW+'CH341');
       result := true;
       Exit;
    end;
  end;

  if Current_HW = AVRISP then
  begin
    err := USBOpenDevice(hUSBDev, avrisp_DeviceDescription);
    if err <> 0 then
    begin
      LogPrint(STR_CONNECT_ERROR_AVR+'('+IntToStr(err)+')', ClRed);
      hUSBDev := nil;
      result := false;
      Exit;
    end;

    usb_set_configuration(hUSBDev, 1);
    usb_claim_interface(hUSBDev, 0);
    //Есть ли в прошивке наши команды
    if not is_firmware_supported then
    begin
        USB_Dev_Close(hUSBDev);
        LogPrint(STR_NO_EEPROM_SUPPORT, clRed);
        result := false
    end
       else
    begin
       result := true;
       LogPrint(STR_CURR_HW+'AVRISP');
    end;

    exit;
  end;

  err := USBOpenDevice(hUSBDev, DeviceDescription);
  if err <> 0 then
  begin
    LogPrint(STR_CONNECTION_ERROR+'('+IntToStr(err)+')', ClRed);
    hUSBDev := nil;
    result := false;
    Exit;
  end;

  err := UsbAspEEPROMSupport;

  if (err<>1) and (err<>2) then
  begin
    result := false;
    LogPrint(STR_NO_EEPROM_SUPPORT, ClRed);
    Exit;
  end;

  if (MainForm.RadioMW.Checked) or (MainForm.RadioI2C.Checked) then
  begin
    if err = 1 then
    begin
      result := false;
      LogPrint(STR_MINI_EEPROM_SUPPORT, ClRed);
      Exit;
    end;
  end;

  LogPrint(STR_CURR_HW+'USBASP');
  result := true
end;

//0=не поддерживается
//1=урезана
//2=полная
function UsbAspEEPROMSupport(): integer;
var
  buff : array[0..3] of byte;
begin
  result := 0;
  USBSendControlMessage(hUSBDev, USB2PC, USBASP_FUNC_GETCAPABILITIES, 1, 0, 4, buff);
  if buff[3] = 11 then result := 1;
  if buff[3] = 1 then result := 2;
end;

function IsLockBitsEnabled: boolean;
var
  sreg: byte;
begin
  result := false;
  sreg := 0;
  if MainForm.ComboSPICMD.ItemIndex = SPI_CMD_25 then
  begin
    UsbAsp25_ReadSR(hUSBDev, sreg);
    if IsBitSet(sreg, 2) or
       IsBitSet(sreg, 3) or
       IsBitSet(sreg, 4) or
       IsBitSet(sreg, 5) or
       IsBitSet(sreg, 6) or
       IsBitSet(sreg, 7)
    then
    begin
      LogPrint(STR_BLOCK_EN, ClRed);
      Result := true;
    end;
  end;

  if MainForm.ComboSPICMD.ItemIndex = SPI_CMD_45 then
  begin
    UsbAsp45_ReadSR(hUSBDev, sreg);
    if (sreg and 2 <> 0) then
    begin
      LogPrint(STR_BLOCK_EN, ClRed);
      Result := true;
    end;
  end;

end;

//Установка скорости spi и Microwire
function SetSPISpeed(OverrideSpeed: byte): boolean;
var
  error: integer;
  Speed: byte;
begin

  if Current_HW = AVRISP then
  begin
    if MainForm.MenuAVRISP8Mhz.Checked then Speed := MainForm.MenuAVRISP8Mhz.Tag;
    if MainForm.MenuAVRISP4Mhz.Checked then Speed := MainForm.MenuAVRISP4Mhz.Tag;
    if MainForm.MenuAVRISP2Mhz.Checked then Speed := MainForm.MenuAVRISP2Mhz.Tag;
    if MainForm.MenuAVRISP1Mhz.Checked then Speed := MainForm.MenuAVRISP1Mhz.Tag;
    if MainForm.MenuAVRISP500Khz.Checked then Speed := MainForm.MenuAVRISP500Khz.Tag;
    if MainForm.MenuAVRISP250Khz.Checked then Speed := MainForm.MenuAVRISP250Khz.Tag;
    if MainForm.MenuAVRISP125Khz.Checked then Speed := MainForm.MenuAVRISP125Khz.Tag;
  end;

  if (MainForm.RadioSPI.Checked) and (Current_HW = USBASP) then
  begin
    if MainForm.Menu3Mhz.Checked then Speed := MainForm.Menu3Mhz.Tag;
    if MainForm.Menu1_5Mhz.Checked then Speed := MainForm.Menu1_5Mhz.Tag;
    if MainForm.Menu750Khz.Checked then Speed := MainForm.Menu750Khz.Tag;
    if MainForm.Menu375Khz.Checked then Speed := MainForm.Menu375Khz.Tag;
    if MainForm.Menu187_5Khz.Checked then Speed := MainForm.Menu187_5Khz.Tag;
    if MainForm.Menu93_75Khz.Checked then Speed := MainForm.Menu93_75Khz.Tag;
    if MainForm.Menu32Khz.Checked then Speed := MainForm.Menu32Khz.Tag;
  end;

  if (MainForm.RadioMw.Checked) and (Current_HW = USBASP) then
  begin
    if MainForm.MenuMW32Khz.Checked then Speed := MainForm.MenuMW32Khz.Tag;
    if MainForm.MenuMW16Khz.Checked then Speed := MainForm.MenuMW16Khz.Tag;
    if MainForm.MenuMW8Khz.Checked then Speed := MainForm.MenuMW8Khz.Tag;
  end;

  if OverrideSpeed <> 0 then Speed := OverrideSpeed;

  error := UsbAsp_SetISPSpeed(hUSBDev, speed);

  if error <> 0 then
  begin
    LogPrint(STR_SET_SPEED_ERROR, ClRed);
    result := false;
    exit;
  end;
  result := true;
end;


function SetI2CDevAddr(): byte;
begin
    result := 0;
    With MainForm do
    begin
      if (CheckBox_I2C_A0.Checked) then result := SetBit(result, 1);
      if (CheckBox_I2C_A1.Checked) then result := SetBit(result, 2);
      if (CheckBox_I2C_A2.Checked) then result := SetBit(result, 3);

      if (CheckBox_I2C_DevA4.Checked) then result := SetBit(result, 4);
      if (CheckBox_I2C_DevA5.Checked) then result := SetBit(result, 5);
      if (CheckBox_I2C_DevA6.Checked) then result := SetBit(result, 6);
      if (CheckBox_I2C_DevA7.Checked) then result := SetBit(result, 7);
    end;
end;

procedure ReadFlashMW(var RomStream: TMemoryStream; AddrBitLen: byte; StartAddress, ChipSize: cardinal);
var
  ChunkSize: Word;
  BytesRead: integer;
  DataChunk: array[0..2047] of byte;
  Address: cardinal;
begin
  if (StartAddress >= ChipSize) or (ChipSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, ClRed);
    exit;
  end;

  ChunkSize := 2;
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  LogPrint(STR_READING_FLASH);
  BytesRead := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := ChipSize div ChunkSize;

  RomStream.Clear;

  while Address < ChipSize div 2 do
  begin
    //if ChunkSize > ((ChipSize div 2) - Address) then ChunkSize := (ChipSize div 2) - Address;

    BytesRead := BytesRead + UsbAspMW_Read(hUSBDev, AddrBitLen, Address, datachunk, ChunkSize);
    RomStream.WriteBuffer(datachunk, ChunkSize);
    Inc(Address, ChunkSize div 2);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 2;
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Break;
    end;
  end;

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, ClRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure WriteFlashMW(var RomStream: TMemoryStream; AddrBitLen: byte; StartAddress, ChipSize: cardinal);
var
  DataChunk: array[0..2047] of byte;
  Address, BytesWrite: cardinal;
  ChunkSize: Word;
begin
  if (StartAddress >= ChipSize) or (ChipSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, ClRed);
    exit;
  end;

  LogPrint(STR_WRITING_FLASH);
  BytesWrite := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := ChipSize;

  ChunkSize := 2;

  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  UsbAspMW_EWEN(hUSBDev, AddrBitLen);

  while Address < ChipSize div 2 do
  begin
    RomStream.ReadBuffer(DataChunk, ChunkSize);

    BytesWrite := BytesWrite + UsbAspMW_Write(hUSBDev, AddrBitLen, Address, datachunk, ChunkSize);
    Inc(Address, ChunkSize div 2);

    if Current_HW = CH341 then
      while ch341mw_busy do
        Application.ProcessMessages;

    if Current_HW = AVRISP then
      while avrisp_mw_busy do
        Application.ProcessMessages;

    if Current_HW = USBASP then
      while UsbAspMW_Busy(hUSBDev) do
        Application.ProcessMessages;

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + ChunkSize;
    Application.ProcessMessages;
  end;

  if BytesWrite <> ChipSize then
    LogPrint(STR_WRONG_BYTES_WRITE, ClRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure WriteFlash25(var RomStream: TMemoryStream; StartAddress, WriteSize: cardinal; PageSize: word; WriteType: integer);
const
  FLASH_SIZE_128MBIT = 16777216;
var
  DataChunk: array[0..2047] of byte;
  DataChunk2: array[0..2047] of byte;
  Address, BytesWrite: cardinal;
  i: integer;
  sreg: byte;
begin
  if (StartAddress >= WriteSize) or (WriteSize = 0) {or (PageSize > WriteSize)} then
  begin
    LogPrint(STR_CHECK_SETTINGS, ClRed);
    exit;
  end;

  if MainForm.MenuAutoCheck.Checked then
    LogPrint(STR_WRITING_FLASH_WCHK) else
      LogPrint(STR_WRITING_FLASH);

  BytesWrite := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := WriteSize div PageSize;

  if WriteSize > FLASH_SIZE_128MBIT then UsbAsp25_EN4B(hUSBDev);

  while Address < WriteSize do
  begin
    //Только вначале aai
    if (((WriteType = WT_SSTB) or (WriteType = WT_SSTW)) and (Address = StartAddress)) or
    //Вначале страницы
    (WriteType = WT_PAGE) then UsbAsp25_WREN(hUSBDev);

    if (WriteSize - Address) < PageSize then PageSize := (WriteSize - Address);
    RomStream.ReadBuffer(DataChunk, PageSize);

    if (WriteType = WT_SSTB) then
      if (Address = StartAddress) then //Пишем первый байт с адресом
        BytesWrite := BytesWrite + UsbAsp25_Write(hUSBDev, $AF, Address, datachunk, PageSize)
        else
        //Пишем остальные(без адреса)
        BytesWrite := BytesWrite + UsbAsp25_WriteSSTB(hUSBDev, $AF, datachunk[0]);

    if (WriteType = WT_SSTW) then
      if (Address = StartAddress) then //Пишем первые два байта с адресом
        BytesWrite := BytesWrite + UsbAsp25_Write(hUSBDev, $AD, Address, datachunk, PageSize)
        else
        //Пишем остальные(без адреса)
        BytesWrite := BytesWrite + UsbAsp25_WriteSSTW(hUSBDev, $AD, datachunk[0], datachunk[1]);

    if WriteType = WT_PAGE then
    begin
      if WriteSize > FLASH_SIZE_128MBIT then //Память больше 128Мбит
      begin
        //4 байтная адресация
        BytesWrite := BytesWrite + UsbAsp25_Write32bitAddr(hUSBDev, $02, Address, datachunk, PageSize)
      end
      else //Память в пределах 128Мбит
        BytesWrite := BytesWrite + UsbAsp25_Write(hUSBDev, $02, Address, datachunk, PageSize);
    end;

    if not MainForm.MenuIgnoreBusyBit.Checked then  //Игнорировать проверку
      while UsbAsp25_Busy(hUSBDev) do
      begin
        Application.ProcessMessages;
        if MainForm.ButtonCancel.Tag <> 0 then
        begin
          LogPrint(STR_USER_CANCEL, clRed);
          Exit;
        end;
      end;

    if (MainForm.MenuAutoCheck.Checked) and (WriteType = WT_PAGE) then
    begin
	  
      if WriteSize > FLASH_SIZE_128MBIT then
        UsbAsp25_Read32bitAddr(hUSBDev, $03, Address, datachunk2, PageSize)
      else
        UsbAsp25_Read(hUSBDev, $03, Address, datachunk2, PageSize);
		  
      for i:=0 to PageSize-1 do
        if DataChunk2[i] <> DataChunk[i] then
        begin
          LogPrint(STR_VERIFY_ERROR+IntToHex(Address+i, 8), clRed);
          MainForm.ProgressBar.Position := 0;
          Exit;
        end;
    end;

    Inc(Address, PageSize);
    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;
  end;

  if WriteSize > FLASH_SIZE_128MBIT then UsbAsp25_EX4B(hUSBDev);
  UsbAsp25_Wrdi(hUSBDev); //Для sst

  if BytesWrite <> WriteSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure WriteFlash95(var RomStream: TMemoryStream; StartAddress, WriteSize: cardinal; PageSize: word; ChipSize: integer);
var
  DataChunk: array[0..2047] of byte;
  DataChunk2: array[0..2047] of byte;
  Address, BytesWrite: cardinal;
  i: integer;
begin
  if (StartAddress >= WriteSize) or (WriteSize = 0) {or (PageSize > WriteSize)} then
  begin
    LogPrint(STR_CHECK_SETTINGS, ClRed);
    exit;
  end;

  if MainForm.MenuAutoCheck.Checked then
    LogPrint(STR_WRITING_FLASH_WCHK) else
      LogPrint(STR_WRITING_FLASH);

  BytesWrite := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := WriteSize div PageSize;

  while Address < WriteSize do
  begin
    UsbAsp95_WREN(hUSBDev);

    if (WriteSize - Address) < PageSize then PageSize := (WriteSize - Address);
    RomStream.ReadBuffer(DataChunk, PageSize);

    BytesWrite := BytesWrite + UsbAsp95_Write(hUSBDev, ChipSize, Address, datachunk, PageSize);

    if not MainForm.MenuIgnoreBusyBit.Checked then  //Игнорировать проверку
      while UsbAsp25_Busy(hUSBDev) do
      begin
        Application.ProcessMessages;
        if MainForm.ButtonCancel.Tag <> 0 then
        begin
          LogPrint(STR_USER_CANCEL, clRed);
          Exit;
        end;
      end;

    if MainForm.MenuAutoCheck.Checked then
    begin
      UsbAsp95_Read(hUSBDev, ChipSize, Address, datachunk2, PageSize);
      for i:=0 to PageSize-1 do
        if DataChunk2[i] <> DataChunk[i] then
        begin
          LogPrint(STR_VERIFY_ERROR+IntToHex(Address+i, 8), clRed);
          MainForm.ProgressBar.Position := 0;
          Exit;
        end;
    end;

    Inc(Address, PageSize);
    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;
  end;

  if BytesWrite <> WriteSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure EraseEEPROM25(StartAddress, WriteSize: cardinal; PageSize: word; ChipSize: integer);
var
  DataChunk: array[0..2047] of byte;
  DataChunk2: array[0..2047] of byte;
  Address, BytesWrite: cardinal;
  i: integer;
begin
  if (StartAddress >= WriteSize) or (WriteSize = 0) {or (PageSize > WriteSize)} then
  begin
    LogPrint(STR_CHECK_SETTINGS, ClRed);
    exit;
  end;

  BytesWrite := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := WriteSize div PageSize;

  while Address < WriteSize do
  begin
    UsbAsp95_WREN(hUSBDev);

    if (WriteSize - Address) < PageSize then PageSize := (WriteSize - Address);

    FillByte(DataChunk, PageSize, $FF);

    BytesWrite := BytesWrite + UsbAsp95_Write(hUSBDev, ChipSize, Address, datachunk, PageSize);

    if not MainForm.MenuIgnoreBusyBit.Checked then  //Игнорировать проверку
      while UsbAsp25_Busy(hUSBDev) do
      begin
        Application.ProcessMessages;
        if MainForm.ButtonCancel.Tag <> 0 then
        begin
          LogPrint(STR_USER_CANCEL, clRed);
          Exit;
        end;
      end;

    if MainForm.MenuAutoCheck.Checked then
    begin
      UsbAsp95_Read(hUSBDev, ChipSize, Address, datachunk2, PageSize);
      for i:=0 to PageSize-1 do
        if DataChunk2[i] <> DataChunk[i] then
        begin
          LogPrint(STR_VERIFY_ERROR+IntToHex(Address+i, 8), clRed);
          MainForm.ProgressBar.Position := 0;
          Exit;
        end;
    end;

    Inc(Address, PageSize);
    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;
  end;

  if BytesWrite <> WriteSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

//write size in pages
procedure WriteFlashKB(var RomStream: TMemoryStream; StartAddress, WriteSize: cardinal; PageSize: word);
var
  DataChunk: array[0..2047] of byte;
  DataChunk2: array[0..2047] of byte;
  Address, BytesWrite: cardinal;
  i: integer;
begin
  if (StartAddress >= WriteSize) or (WriteSize = 0) {or (PageSize > WriteSize)} then
  begin
    LogPrint(STR_CHECK_SETTINGS, ClRed);
    exit;
  end;

  if MainForm.MenuAutoCheck.Checked then
    LogPrint(STR_WRITING_FLASH_WCHK) else
      LogPrint(STR_WRITING_FLASH);

  BytesWrite := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := WriteSize;

  UsbAspMulti_EnableEDI(hUSBdev);
  UsbAspMulti_WriteReg(hUSBdev, $FEAD, $08); //en flash
  UsbAspMulti_WriteReg(hUSBdev, $FEA7, $A4); //en write

  while Address < WriteSize do
  begin


    //if (WriteSize - Address) < PageSize then PageSize := (WriteSize - Address);
    RomStream.ReadBuffer(DataChunk, PageSize);

    UsbAspMulti_WritePage(hUSBDev, Address, datachunk);
    BytesWrite := BytesWrite + 1;

     { if (MainForm.MenuAutoCheck.Checked) then
      begin
        UsbAsp25_Read(hUSBDev, $03, Address, datachunk2, PageSize);
        for i:=0 to PageSize-1 do
          if DataChunk2[i] <> DataChunk[i] then
          begin
            LogPrint(STR_VERIFY_ERROR+IntToHex(Address+i, 8), clRed);
            MainForm.ProgressBar.Position := 0;
            Exit;
          end;
      end; }

    Inc(Address, 1);
    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      LogPrint(STR_USER_CANCEL , clRed);
      Exit;
    end;
    Application.ProcessMessages;
  end;

  if BytesWrite <> WriteSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure WriteFlash45(var RomStream: TMemoryStream; StartAddress, ChipSize: cardinal; PageSize: word; WriteType: integer);
var
  DataChunk: array[0..2047] of byte;
  DataChunk2: array[0..2047] of byte;
  PageAddress, BytesWrite: cardinal;
  i: integer;
begin
  if (StartAddress >= ChipSize) or (ChipSize = 0) or (PageSize > ChipSize) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  if MainForm.MenuAutoCheck.Checked then
    LogPrint(STR_WRITING_FLASH_WCHK) else
      LogPrint(STR_WRITING_FLASH);

  BytesWrite := 0;
  PageAddress := StartAddress;
  MainForm.ProgressBar.Max := ChipSize div PageSize;

  while PageAddress < ChipSize div PageSize do
  begin
    //UsbAsp45_WREN(hUSBDev);
    RomStream.ReadBuffer(DataChunk, PageSize);

    if WriteType = WT_PAGE then
      BytesWrite := BytesWrite + UsbAsp45_Write(hUSBDev, PageAddress, datachunk, PageSize);

    while UsbAsp45_Busy(hUSBDev) do
    begin
      Application.ProcessMessages;
      if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Exit;
      end;
    end;

    if MainForm.MenuAutoCheck.Checked then
    begin
      UsbAsp45_Read(hUSBDev, PageAddress, datachunk2, PageSize);
      for i:=0 to PageSize-1 do
        if DataChunk2[i] <> DataChunk[i] then
        begin
          LogPrint(STR_VERIFY_ERROR+IntToHex((PageAddress*PageSize )+i, 8), clRed);
          Exit;
        end;
    end;

    Inc(PageAddress, 1);
    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;
  end;

  if BytesWrite <> ChipSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure ReadFlash25(var RomStream: TMemoryStream; StartAddress, ChipSize: cardinal);
const
  FLASH_SIZE_128MBIT = 16777216;
var
  ChunkSize: Word;
  BytesRead: integer;
  DataChunk: array[0..2047] of byte;
  Address: cardinal;
begin
  if (StartAddress >= ChipSize) or (ChipSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := SizeOf(DataChunk);
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  LogPrint(STR_READING_FLASH);
  BytesRead := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := ChipSize div ChunkSize;

  RomStream.Clear;

  if ChipSize > FLASH_SIZE_128MBIT then UsbAsp25_EN4B(hUSBDev);

  while Address < ChipSize do
  begin
    if ChunkSize > (ChipSize - Address) then ChunkSize := ChipSize - Address;

    if ChipSize > FLASH_SIZE_128MBIT then
      BytesRead := BytesRead + UsbAsp25_Read32bitAddr(hUSBDev, $03, Address, datachunk, ChunkSize)
    else
      BytesRead := BytesRead + UsbAsp25_Read(hUSBDev, $03, Address, datachunk, ChunkSize);

    RomStream.WriteBuffer(datachunk, chunksize);
    Inc(Address, ChunkSize);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Break;
    end;
  end;

  if ChipSize > FLASH_SIZE_128MBIT then UsbAsp25_EX4B(hUSBDev);

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure ReadFlash95(var RomStream: TMemoryStream; StartAddress, ChipSize: cardinal);
var
  ChunkSize: Word;
  BytesRead: integer;
  DataChunk: array[0..2047] of byte;
  Address: cardinal;
begin
  if (StartAddress >= ChipSize) or (ChipSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := SizeOf(DataChunk);
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  LogPrint(STR_READING_FLASH);
  BytesRead := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := ChipSize div ChunkSize;

  RomStream.Clear;

  while Address < ChipSize do
  begin
    if ChunkSize > (ChipSize - Address) then ChunkSize := ChipSize - Address;

    BytesRead := BytesRead + UsbAsp95_Read(hUSBDev, ChipSize, Address, datachunk, ChunkSize);
    RomStream.WriteBuffer(datachunk, chunksize);
    Inc(Address, ChunkSize);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Break;
    end;
  end;

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure ReadFlash45(var RomStream: TMemoryStream; StartAddress, PageSize, ChipSize: cardinal);
var
  ChunkSize: Word;
  BytesRead: integer;
  DataChunk: array[0..2047] of byte;
  Address: cardinal;
begin
  if (StartAddress >= ChipSize) or (ChipSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := PageSize;
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  LogPrint(STR_READING_FLASH);
  BytesRead := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := ChipSize div ChunkSize;

  RomStream.Clear;

  while Address < ChipSize div ChunkSize do
  begin
    //if ChunkSize > (ChipSize - Address) then ChunkSize := ChipSize - Address;

    BytesRead := BytesRead + UsbAsp45_Read(hUSBDev, Address, datachunk, ChunkSize);
    RomStream.WriteBuffer(datachunk, chunksize);
    Inc(Address, 1);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Break;
    end;
  end;

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure ReadFlashKB(var RomStream: TMemoryStream; StartAddress, ChipSize: cardinal);
var
  ChunkSize: byte;
  BytesRead: integer;
  DataChunk: byte;
  Address: cardinal;
begin
  if (StartAddress >= ChipSize) or (ChipSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := SizeOf(DataChunk);
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  LogPrint(STR_READING_FLASH);
  BytesRead := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := ChipSize div ChunkSize;

  UsbAspMulti_EnableEDI(hUSBdev);
  UsbAspMulti_WriteReg(hUSBdev, $FEAD, $08); //en flash

  RomStream.Clear;

  while Address < ChipSize do
  begin
    if ChunkSize > (ChipSize - Address) then ChunkSize := ChipSize - Address;

    BytesRead := BytesRead + UsbAspMulti_Read(hUSBDev, Address, datachunk);
    RomStream.WriteBuffer(datachunk, chunksize);
    Inc(Address, ChunkSize);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Break;
    end;
  end;

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;


procedure VerifyFlash25(var RomStream: TMemoryStream; StartAddress, DataSize: cardinal);
const
  FLASH_SIZE_128MBIT = 16777216;
var
  ChunkSize: Word;
  BytesRead, i: integer;
  DataChunk: array[0..2047] of byte;
  DataChunkFile: array[0..2047] of byte;
  Address: cardinal;
begin
  if (StartAddress >= DataSize) or (DataSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := SizeOf(DataChunk);
  if ChunkSize > DataSize then ChunkSize := DataSize;

  LogPrint(STR_VERIFY);
  BytesRead := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := DataSize div ChunkSize;

  if DataSize > FLASH_SIZE_128MBIT then UsbAsp25_EN4B(hUSBDev);

  while Address < DataSize do
  begin
    if ChunkSize > (DataSize - Address) then ChunkSize := DataSize - Address;

    if DataSize > FLASH_SIZE_128MBIT then
        BytesRead := BytesRead + UsbAsp25_Read32bitAddr(hUSBDev, $03, Address, datachunk, ChunkSize)
      else
        BytesRead := BytesRead + UsbAsp25_Read(hUSBDev, $03, Address, datachunk, ChunkSize);

    RomStream.ReadBuffer(DataChunkFile, ChunkSize);

    for i := 0 to ChunkSize -1 do
    if DataChunk[i] <> DataChunkFile[i] then
    begin
      LogPrint(STR_VERIFY_ERROR+IntToHex(Address+i, 8), clRed);
      MainForm.ProgressBar.Position := 0;
      Exit;
    end;

    Inc(Address, ChunkSize);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Break;
    end;
  end;

  if DataSize > FLASH_SIZE_128MBIT then UsbAsp25_EX4B(hUSBDev);

  if (BytesRead <> DataSize) then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure VerifyFlash95(var RomStream: TMemoryStream; StartAddress, DataSize, ChipSize: cardinal);
var
  ChunkSize: Word;
  BytesRead, i: integer;
  DataChunk: array[0..2047] of byte;
  DataChunkFile: array[0..2047] of byte;
  Address: cardinal;
begin
  if (StartAddress >= DataSize) or (DataSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := SizeOf(DataChunk);
  if ChunkSize > DataSize then ChunkSize := DataSize;

  LogPrint(STR_VERIFY);
  BytesRead := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := DataSize div ChunkSize;

  while Address < DataSize do
  begin
    if ChunkSize > (DataSize - Address) then ChunkSize := DataSize - Address;

    BytesRead := BytesRead + UsbAsp95_Read(hUSBDev, ChipSize, Address, datachunk, ChunkSize);
    RomStream.ReadBuffer(DataChunkFile, ChunkSize);

    for i := 0 to ChunkSize -1 do
    if DataChunk[i] <> DataChunkFile[i] then
    begin
      LogPrint(STR_VERIFY_ERROR+IntToHex(Address+i, 8), clRed);
      MainForm.ProgressBar.Position := 0;
      Exit;
    end;

    Inc(Address, ChunkSize);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Break;
    end;
  end;

  if (BytesRead <> DataSize) then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure VerifyFlash45(var RomStream: TMemoryStream; StartAddress, PageSize, ChipSize: cardinal);
var
  ChunkSize: Word;
  BytesRead, i: integer;
  DataChunk: array[0..2047] of byte;
  DataChunkFile: array[0..2047] of byte;
  PageAddress: cardinal;
begin
  if (StartAddress >= ChipSize) or (ChipSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := PageSize;
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  LogPrint(STR_VERIFY);
  BytesRead := 0;
  PageAddress := StartAddress;
  MainForm.ProgressBar.Max := ChipSize div ChunkSize;

  while PageAddress < ChipSize div ChunkSize do
  begin
    //if ChunkSize > (ChipSize - Address) then ChunkSize := ChipSize - Address;

    BytesRead := BytesRead + UsbAsp45_Read(hUSBDev, PageAddress, datachunk, ChunkSize);
    RomStream.ReadBuffer(DataChunkFile, ChunkSize);

    for i := 0 to ChunkSize -1 do
    if DataChunk[i] <> DataChunkFile[i] then
    begin
      LogPrint(STR_VERIFY_ERROR+IntToHex((PageAddress*ChunkSize)+i, 8), clRed);
      MainForm.ProgressBar.Position := 0;
      Exit;
    end;

    Inc(PageAddress, 1);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Break;
    end;
  end;

  if (BytesRead <> ChipSize) then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure VerifyFlashMW(var RomStream: TMemoryStream; AddrBitLen: byte; StartAddress, ChipSize: cardinal);
var
  ChunkSize: Word;
  BytesRead, i: integer;
  DataChunk: array[0..2047] of byte;
  DataChunkFile: array[0..2047] of byte;
  Address: cardinal;
begin
  if (StartAddress >= ChipSize) or (ChipSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := 2;
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  LogPrint(STR_VERIFY);
  BytesRead := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := ChipSize div ChunkSize;

  while Address < ChipSize div 2 do
  begin
    BytesRead := BytesRead + UsbAspMW_Read(hUSBDev, AddrBitLen, Address, datachunk, ChunkSize);
    RomStream.ReadBuffer(DataChunkFile, ChunkSize);

    for i := 0 to ChunkSize -1 do
    if DataChunk[i] <> DataChunkFile[i] then
    begin
      LogPrint(STR_VERIFY_ERROR+IntToHex(Address+i, 8), clRed);
      MainForm.ProgressBar.Position := 0;
      Exit;
    end;

    Inc(Address, ChunkSize div 2);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 2;
    Application.ProcessMessages;
  end;

  if (BytesRead <> ChipSize) then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure VerifyFlashKB(var RomStream: TMemoryStream; StartAddress, ChipSize: cardinal);
var
  ChunkSize: byte;
  BytesRead: integer;
  DataChunk: byte;
  DataChunkFile: byte;
  Address: cardinal;
begin
  if (StartAddress >= ChipSize) or (ChipSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := SizeOf(DataChunk);
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  LogPrint(STR_VERIFY);
  BytesRead := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := ChipSize div ChunkSize;

  UsbAspMulti_EnableEDI(hUSBdev);
  UsbAspMulti_WriteReg(hUSBdev, $FEAD, $08); //en flash

  RomStream.Clear;

  while Address < ChipSize do
  begin
    if ChunkSize > (ChipSize - Address) then ChunkSize := ChipSize - Address;

    BytesRead := BytesRead + UsbAspMulti_Read(hUSBDev, Address, datachunk);
    RomStream.ReadBuffer(DataChunkFile, ChunkSize);

    if DataChunk <> DataChunkFile then
    begin
      LogPrint(STR_VERIFY_ERROR+IntToHex(Address, 8), clRed);
      MainForm.ProgressBar.Position := 0;
      Exit;
    end;

    Inc(Address, ChunkSize);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Break;
    end;
  end;

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure ReadFlashI2C(var RomStream: TMemoryStream; ChipSize: cardinal; ChunkSize: Word; DevAddr: byte);
var
  BytesRead: integer;
  DataChunk: array[0..2047] of byte;
  Address: cardinal;
begin
  if ChipSize = 0 then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  if ChunkSize > SizeOf(DataChunk) then ChunkSize := SizeOf(DataChunk);
  if ChunkSize < 1 then ChunkSize := 1;
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  LogPrint(STR_READING_FLASH);
  BytesRead := 0;
  Address := 0;
  MainForm.ProgressBar.Max := ChipSize div ChunkSize;

  RomStream.Clear;

  while Address < ChipSize do
  begin
    if ChunkSize > (ChipSize - Address) then ChunkSize := ChipSize - Address;

    BytesRead := BytesRead + UsbAspI2C_Read(hUSBDev, DevAddr, MainForm.ComboAddrType.ItemIndex, Address, datachunk, ChunkSize);
    RomStream.WriteBuffer(DataChunk, ChunkSize);
    Inc(Address, ChunkSize);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;
  end;

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure WriteFlashI2C(var RomStream: TMemoryStream; StartAddress, WriteSize: cardinal; PageSize: word; DevAddr: byte);
var
  DataChunk: array[0..2047] of byte;
  Address, BytesWrite: cardinal;
begin
  if (StartAddress >= WriteSize) or (WriteSize = 0) {or (PageSize > WriteSize)} then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  LogPrint(STR_WRITING_FLASH);
  BytesWrite := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := WriteSize div PageSize;

  while Address < WriteSize do
  begin
    if (WriteSize - Address) < PageSize then PageSize := (WriteSize - Address);
    RomStream.ReadBuffer(DataChunk, PageSize);
    BytesWrite := BytesWrite + UsbAspI2C_Write(hUSBDev, DevAddr, MainForm.ComboAddrType.ItemIndex, Address, datachunk, PageSize);
    Inc(Address, PageSize);

    while UsbAspI2C_BUSY(hUSBdev, DevAddr) do
      Application.ProcessMessages;

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;
  end;

  if BytesWrite <> WriteSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure EraseFlashI2C(StartAddress, WriteSize: cardinal; PageSize: word; DevAddr: byte);
var
  DataChunk: array[0..2047] of byte;
  Address, BytesWrite: cardinal;
begin
  if (StartAddress >= WriteSize) or (WriteSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  LogPrint(STR_ERASING_FLASH);
  BytesWrite := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := WriteSize div PageSize;

  while Address < WriteSize do
  begin
    if (WriteSize - Address) < PageSize then PageSize := (WriteSize - Address);
    FillByte(DataChunk, PageSize, $FF);
    BytesWrite := BytesWrite + UsbAspI2C_Write(hUSBDev, DevAddr, MainForm.ComboAddrType.ItemIndex, Address, datachunk, PageSize);
    Inc(Address, PageSize);

    while UsbAspI2C_BUSY(hUSBdev, DevAddr) do
      Application.ProcessMessages;

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;
  end;

  if BytesWrite <> WriteSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure VerifyFlashI2C(var RomStream: TMemoryStream; DataSize: cardinal; ChunkSize: Word; DevAddr: byte);
var
  BytesRead, i: integer;
  DataChunk: array[0..2047] of byte;
  DataChunkFile: array[0..2047] of byte;
  Address: cardinal;
begin
  if (DataSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  if ChunkSize > SizeOf(DataChunk) then ChunkSize := SizeOf(DataChunk);
  if ChunkSize < 1 then ChunkSize := 1;
  if ChunkSize > DataSize then ChunkSize := DataSize;

  LogPrint(STR_VERIFY);
  BytesRead := 0;
  Address := 0;
  MainForm.ProgressBar.Max := DataSize div ChunkSize;

  while Address < DataSize do
  begin
    if ChunkSize > (DataSize - Address) then ChunkSize := DataSize - Address;

    BytesRead := BytesRead + UsbAspI2C_Read(hUSBDev, DevAddr, MainForm.ComboAddrType.ItemIndex, Address, datachunk, ChunkSize);
    RomStream.ReadBuffer(DataChunkFile, ChunkSize);

    for i := 0 to ChunkSize -1 do
    if DataChunk[i] <> DataChunkFile[i] then
    begin
      LogPrint(STR_VERIFY_ERROR+IntToHex(Address+i, 8), clRed);
      MainForm.ProgressBar.Position := 0;
      Exit;
    end;

    Inc(Address, ChunkSize);

    MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
    Application.ProcessMessages;
  end;

  if (BytesRead <> DataSize) then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);

  MainForm.ProgressBar.Position := 0;
end;

procedure SelectHW(programmer: integer);
begin
  if programmer = HW_USBASP then
  begin
    MainForm.MenuSPIClock.Visible:= true;
    MainForm.MenuAVRISPSPIClock.Visible:= false;
    MainForm.MenuMicrowire.Enabled:= true;
    Current_HW := USBASP;
  end;

  if programmer = HW_CH341A then
  begin
    MainForm.MenuSPIClock.Visible:= false;
    MainForm.MenuAVRISPSPIClock.Visible:= false;
    MainForm.MenuMicrowire.Enabled:= false;
    Current_HW := CH341;
  end;

  if programmer = HW_AVRISPMK2 then
  begin
    MainForm.MenuSPIClock.Visible:= false;
    MainForm.MenuAVRISPSPIClock.Visible:= true;
    MainForm.MenuMicrowire.Enabled:= false;
    Current_HW := AVRISP;
  end;

end;

procedure LockControl;
begin
  MainForm.ButtonRead.Enabled := False;
  MainForm.ButtonWrite.Enabled := False;
  MainForm.ButtonVerify.Enabled := False;
  MainForm.ButtonReadID.Enabled := False;
  MainForm.ButtonBlock.Enabled := False;
  MainForm.ButtonErase.Enabled := False;
  MainForm.ButtonOpenHex.Enabled := False;
  MainForm.ButtonSaveHex.Enabled := False;

  MainForm.GroupChipSettings.Enabled := false;
end;

procedure UnlockControl;
begin
  MainForm.GroupChipSettings.Enabled := true;
  MainForm.ButtonRead.Enabled := True;
  MainForm.ButtonWrite.Enabled := True;
  MainForm.ButtonVerify.Enabled := True;
  MainForm.ButtonOpenHex.Enabled := True;
  MainForm.ButtonSaveHex.Enabled := True;
  MainForm.ButtonErase.Enabled := True;

  if MainForm.RadioSPI.Checked then
  begin
    if (MainForm.ComboSPICMD.ItemIndex <> SPI_CMD_KB) then
    begin
      MainForm.ButtonReadID.Enabled := True;
      MainForm.ButtonBlock.Enabled := True;
    end
    else
    begin
      MainForm.ButtonErase.Enabled := False;
      MainForm.ButtonBlock.Enabled := True;
    end;

  end;
end;

procedure TMainForm.ChipClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    findchip.SelectChip(chiplistfile, TMenuItem(Sender).Caption);
end;

procedure TMainForm.KHexEditorKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //Костыль. Так как событие TKHEXEditor.OnChange вызывается до изменения содержимого =)
  StatusBar.Panels.Items[0].Text := STR_SIZE+IntToStr(KHexEditor.Data.Size);
end;

procedure TMainForm.KHexEditorChange(Sender: TObject);
begin
  StatusBar.Panels.Items[0].Text := STR_SIZE+IntToStr(KHexEditor.Data.Size);
  if KHexEditor.Modified then
    StatusBar.Panels.Items[1].Text := STR_CHANGED
  else
    StatusBar.Panels.Items[1].Text := '';
end;

procedure TMainForm.ComboItem1Click(Sender: TObject);
var
  CheckTemp: Boolean;
begin
  if MessageDlg('AsProgrammer', STR_COMBO_WARN, mtConfirmation, [mbYes, mbNo], 0)
    <> mrYes then Exit;

  if ButtonBlock.Enabled then
    ButtonBlockClick(Sender);
  if ButtonErase.Enabled then
    if ComboSPICMD.ItemIndex <> SPI_CMD_45 then  //Сами стирают страницу
      ButtonEraseClick(Sender);

  CheckTemp := MenuAutoCheck.Checked;
  MenuAutoCheck.Checked := True;

  ButtonWriteClick(Sender);

  MenuAutoCheck.Checked := CheckTemp;
end;


procedure TMainForm.MenuCopyToClipClick(Sender: TObject);
begin
  MainForm.KHexEditor.ExecuteCommand(ecCopy);
end;

procedure TMainForm.MenuFindChipClick(Sender: TObject);
begin
  ChipSearchForm.EditSearch.Text:= '';
  ChipSearchForm.ListBoxChips.Items.Clear;
  ChipSearchForm.Show;
end;

procedure TMainForm.MenuFindClick(Sender: TObject);
begin
  Search.SearchForm.Show;
end;

procedure TMainForm.MenuGotoOffsetClick(Sender: TObject);
var
  s : string;
  ss: TKHexEditorSelection;
begin
  s := InputBox(STR_GOTO_ADDR,'','');
  s := Trim(s);
  if IsNumber('$'+s)  then
  begin
    s := '$' + s;
    ss.Digit:= 0;
    ss.index:= StrToInt(s)+1;
    MainForm.KHexEditor.SelStart := ss;
    ss.index:= ss.index-1;
    MainForm.KHexEditor.SelEnd := ss ;

    MainForm.KHexEditor.ExecuteCommand(ecScrollCenter);
  end;
end;

procedure TMainForm.MenuHWCH341AClick(Sender: TObject);
begin
  SelectHW(HW_CH341A);
end;

procedure TMainForm.MenuHWUSBASPClick(Sender: TObject);
begin
  SelectHW(HW_USBASP);
end;

procedure TMainForm.MenuHWAVRISPClick(Sender: TObject);
begin
  SelectHW(HW_AVRISPMK2);
end;

procedure TMainForm.MenuItemBenchmarkClick(Sender: TObject);
var
  buffer: array[0..2047] of byte;
  i, cycles: integer;
  t: TDateTime;
  timeval: integer;
  ms, sec, d: word;
begin
  if not OpenDevice() then exit;
  if not SetSPISpeed(0) then exit;
  EnterProgMode25(hUSBdev);
  LockControl();

  if (Current_HW = CH341) or (Current_HW = AVRISP) then
    cycles := 256
  else
    cycles := 32;

  LogPrint('Benchmark read '+ IntToStr(SizeOf(buffer))+' bytes * '+ IntToStr(cycles) +' cycles');
  Application.ProcessMessages();
  TimeCounter := Time();

  for i:=1 to cycles do
  begin
    UsbAsp25_Read(hUSBdev, 0, 0, buffer, sizeof(buffer));
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Break;
      end;
  end;

  t :=  Time() - TimeCounter;
  DecodeDateTime(t, d, d, d, d, d, sec, ms);

  timeval := (sec * 1000) + ms;
  if timeval = 0 then timeval := 1;

  LogPrint(STR_TIME + TimeToStr(t)+' '+
    IntToStr( Trunc(((cycles*sizeof(buffer)) / timeval) * 1000)) +' bytes/s');

  LogPrint('Benchmark write '+ IntToStr(SizeOf(buffer))+' bytes * '+ IntToStr(cycles) +' cycles');
  Application.ProcessMessages();
  TimeCounter := Time();

  for i:=1 to cycles do
  begin
    UsbAsp25_Write(hUSBdev, 0, 0, buffer, sizeof(buffer));
    Application.ProcessMessages;

    if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Break;
      end;
  end;

  t :=  Time() - TimeCounter;
  DecodeDateTime(t, d, d, d, d, d, sec, ms);

  timeval := (sec * 1000) + ms;
  if timeval = 0 then timeval := 1;

  LogPrint(STR_TIME + TimeToStr(t)+' '+
    IntToStr( Trunc(((cycles*sizeof(buffer)) / timeval) * 1000)) +' bytes/s');

  ExitProgMode25(hUSBdev);
  USB_Dev_Close(hUSBdev);
  UnlockControl();
end;

procedure TMainForm.MenuItemEditSregClick(Sender: TObject);
begin
  if MainForm.ComboSPICMD.ItemIndex = SPI_CMD_25 then
    sregedit.sregeditForm.Show;
end;

procedure TMainForm.MenuItemLockFlashClick(Sender: TObject);
var
  sreg: byte;
begin
  try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  sreg:= 0;
  LockControl();
  if not SetSPISpeed(0) then exit;
  EnterProgMode25(hUSBdev);

  if ComboSPICMD.ItemIndex = SPI_CMD_25 then
  begin
    UsbAsp25_ReadSR(hUSBDev, sreg); //Читаем регистр
    LogPrint(STR_OLD_SREG+IntToBin(sreg, 8));

    sreg := %10011100; //
    UsbAsp25_WREN(hUSBDev); //Включаем разрешение записи
    UsbAsp25_WriteSR(hUSBDev, sreg); //Устанавливаем регистр

    //Пока отлипнет ромка
    while UsbAsp25_Busy(hUSBDev) do
    begin
      Application.ProcessMessages;
      if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Exit;
      end;
    end;

    LogPrint(STR_NEW_SREG+IntToBin(sreg, 8));
  end;

  if ComboSPICMD.ItemIndex = SPI_CMD_95 then
  begin
    UsbAsp95_ReadSR(hUSBDev, sreg); //Читаем регистр
    LogPrint(STR_OLD_SREG+IntToBin(sreg, 8));

    sreg := %10011100; //
    UsbAsp95_WREN(hUSBDev); //Включаем разрешение записи
    UsbAsp95_WriteSR(hUSBDev, sreg); //Устанавливаем регистр

    //Пока отлипнет ромка
    while UsbAsp25_Busy(hUSBDev) do
    begin
      Application.ProcessMessages;
      if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Exit;
      end;
    end;

    LogPrint(STR_NEW_SREG+IntToBin(sreg, 8));
  end;


finally
  ExitProgMode25(hUSBdev);
  USB_Dev_Close(hUSBdev);
  UnlockControl();
end;

end;

procedure TMainForm.MenuItemReadSregClick(Sender: TObject);
var
  sreg, sreg2, sreg3: byte;
begin
  try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  sreg:= 0;
  LockControl();
  if not SetSPISpeed(0) then exit;
  EnterProgMode25(hUSBdev);

  if ComboSPICMD.ItemIndex = SPI_CMD_25 then
  begin
    UsbAsp25_ReadSR(hUSBDev, sreg); //Читаем регистр
    UsbAsp25_ReadSR(hUSBDev, sreg2, $35); //Второй байт
    UsbAsp25_ReadSR(hUSBDev, sreg3, $15); //Третий байт
    LogPrint('Sreg: '+IntToBin(sreg, 8)+'(0x'+(IntToHex(sreg, 2)+'), ')
                                         +IntToBin(sreg2, 8)+'(0x'+(IntToHex(sreg2, 2)+'), ')
                                         +IntToBin(sreg3, 8)+'(0x'+(IntToHex(sreg3, 2)+')'));
  end;

  if ComboSPICMD.ItemIndex = SPI_CMD_95 then
  begin
    UsbAsp95_ReadSR(hUSBDev, sreg); //Читаем регистр
    LogPrint('Sreg: '+IntToBin(sreg, 8));
  end;

  if ComboSPICMD.ItemIndex = SPI_CMD_45 then
  begin
    UsbAsp45_ReadSR(hUSBDev, sreg); //Читаем регистр
    LogPrint('Sreg: '+IntToBin(sreg, 8));
  end;

finally
  ExitProgMode25(hUSBdev);
  USB_Dev_Close(hUSBdev);
  UnlockControl();
end;

end;



procedure TMainForm.RadioI2CChange(Sender: TObject);
begin
  Label1.Visible              := True;
  Label4.Visible              := True;
  ComboAddrType.Visible       := True;
  ComboPageSize.Visible       := True;
  Label5.Visible              := False;
  LabelSPICMD.Visible         := False;
  ButtonReadID.Enabled        := False;
  ButtonBlock.Enabled         := False;
  ButtonErase.Enabled         := True;
  ComboMWBitLen.Visible       := False;
  ComboSPICMD.Visible         := False;
  Panel_I2C_DevAddr.Visible   := True;

  ComboMWBitLen.Text:= 'MW addr len';
  ComboAddrType.Text:= '';
  ComboPageSize.Text:= 'Page size';
  ComboChipSize.Text:= 'Chip size';
end;

procedure TMainForm.RadioMwChange(Sender: TObject);
begin
  Label1.Visible              := False;
  ComboPageSize.Visible       := False;
  ComboAddrType.Visible       := False;
  ComboSPICMD.Visible         := False;
  ButtonReadID.Enabled        := False;
  ButtonBlock.Enabled         := False;
  Label4.Visible              := False;
  LabelSPICMD.Visible         := False;
  Panel_I2C_DevAddr.Visible   := False;
  Label5.Visible              := True;
  ButtonErase.Enabled         := True;
  ComboMWBitLen.Visible       := True;


  ComboMWBitLen.Text:= 'MW addr len';
  ComboAddrType.Text:= '';
  ComboPageSize.Text:= 'Page size';
  ComboChipSize.Text:= 'Chip size';
end;

procedure TMainForm.RadioSPIChange(Sender: TObject);
begin
  Label1.Visible              := True;
  LabelSPICMD.Visible         := True;
  ComboPageSize.Visible       := True;
  ComboSPICMD.Visible         := True;

  ButtonErase.Enabled         := True;

  if (ComboSPICMD.ItemIndex <> SPI_CMD_KB) then
  begin
    ButtonReadID.Enabled        := True;
    ButtonBlock.Enabled         := True;
  end else
  begin
    ButtonReadID.Enabled        := False;
    ButtonErase.Enabled         := False;
  end;

  ComboMWBitLen.Visible       := False;
  Label4.Visible              := False;
  Label5.Visible              := False;
  ComboAddrType.Visible       := False;

  Panel_I2C_DevAddr.Visible  := False;

  ComboMWBitLen.Text:= 'MW addr len';
  ComboAddrType.Text:= '';
  ComboPageSize.Text:= 'Page size';
  ComboChipSize.Text:= 'Chip size';
end;

procedure TMainForm.ButtonWriteClick(Sender: TObject);
var
  PageSize: word;
  WriteType: byte;
  I2C_DevAddr: byte;
  I2C_ChunkSize: Word = 65535;
begin
try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  if Sender <> ComboItem1 then
    if MessageDlg('AsProgrammer', STR_START_WRITE, mtConfirmation, [mbYes, mbNo], 0)
      <> mrYes then Exit;
  LockControl();

  if RunScriptFromFile(CurrentICParam.Script, 'write') then Exit;

  LogPrint(TimeToStr(Time()));

  if (not IsNumber(ComboChipSize.Text)) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    Exit;
  end;

  if KHexEditor.Data.Size > StrToInt(ComboChipSize.Text) then
  begin
    LogPrint(STR_WRONG_FILE_SIZE, clRed);
    Exit;
  end;

  //SPI
  if RadioSPI.Checked then
  begin
    if not SetSPISpeed(0) then exit;
    EnterProgMode25(hUSBdev);
    if ComboSPICMD.ItemIndex <> SPI_CMD_KB then
      IsLockBitsEnabled;
    if (not IsNumber(ComboPageSize.Text)) and (UpperCase(ComboPageSize.Text)<>'SSTB') and (UpperCase(ComboPageSize.Text)<>'SSTW') then
    begin
      LogPrint(STR_CHECK_SETTINGS, clRed);
      Exit;
    end;
    TimeCounter := Time();

    RomF.Position := 0;
    KHexEditor.SaveToStream(RomF);
    RomF.Position := 0;

    if UpperCase(ComboPageSize.Text)='SSTB' then
    begin
      PageSize := 1;
      WriteType := WT_SSTB;
    end;

    if UpperCase(ComboPageSize.Text)='SSTW' then
    begin
      PageSize := 2;
      WriteType := WT_SSTW;
    end;

    if IsNumber(ComboPageSize.Text) then
    begin
      PageSize := StrToInt(ComboPageSize.Text);
      if PageSize < 1 then
      begin
        PageSize := 1;
        ComboPageSize.Text := '1';
      end;
      WriteType := WT_PAGE;
    end;

    if ComboSPICMD.ItemIndex = SPI_CMD_25 then
      WriteFlash25(RomF, 0, KHexEditor.Data.Size, PageSize, WriteType);
    if ComboSPICMD.ItemIndex = SPI_CMD_95 then
      WriteFlash95(RomF, 0, KHexEditor.Data.Size, PageSize, StrToInt(ComboChipSize.Text));
    if ComboSPICMD.ItemIndex = SPI_CMD_45 then
      WriteFlash45(RomF, 0, KHexEditor.Data.Size, PageSize, WriteType);
    if ComboSPICMD.ItemIndex = SPI_CMD_KB then
      WriteFlashKB(RomF, 0, (KHexEditor.Data.Size div PageSize), PageSize);

    if (MenuAutoCheck.Checked) and (WriteType <> WT_PAGE) then
    begin
      LogPrint(STR_TIME + TimeToStr(Time() - TimeCounter));
      TimeCounter := Time();
      RomF.Position :=0;
      KHexEditor.SaveToStream(RomF);
      RomF.Position :=0;
      if ComboSPICMD.ItemIndex <> SPI_CMD_KB then
        VerifyFlash25(RomF, 0, KHexEditor.Data.Size)
      else
        VerifyFlashKB(RomF, 0, KHexEditor.Data.Size);
    end;

  end;
  //I2C
  if RadioI2C.Checked then
  begin
    if ( (ComboAddrType.ItemIndex < 0) or (not IsNumber(ComboPageSize.Text)) ) then
    begin
      LogPrint(STR_CHECK_SETTINGS, clRed);
      Exit;
    end;

    EnterProgModeI2C(hUSBdev);

    //Адрес микросхемы по чекбоксам
    I2C_DevAddr := SetI2CDevAddr();

    if CheckBox_I2C_ByteRead.Checked then I2C_ChunkSize := 1;

    if UsbAspI2C_BUSY(hUSBdev, I2C_DevAddr) then
    begin
      LogPrint(STR_I2C_NO_ANSWER, clRed);
      exit;
    end;
    TimeCounter := Time();

    RomF.Position := 0;
    KHexEditor.SaveToStream(RomF);
    RomF.Position := 0;

    if StrToInt(ComboPageSize.Text) < 1 then ComboPageSize.Text := '1';

    WriteFlashI2C(RomF, 0, KHexEditor.Data.Size, StrToInt(ComboPageSize.Text), I2C_DevAddr);

    if MenuAutoCheck.Checked then
    begin
      if UsbAspI2C_BUSY(hUSBdev, I2C_DevAddr) then
      begin
        LogPrint(STR_I2C_NO_ANSWER, clRed);
        exit;
      end;
      LogPrint(STR_TIME + TimeToStr(Time() - TimeCounter));

      TimeCounter := Time();

      RomF.Position :=0;
      KHexEditor.SaveToStream(RomF);
      RomF.Position :=0;
      VerifyFlashI2C(RomF, KHexEditor.Data.Size, I2C_ChunkSize, I2C_DevAddr);
    end;

  end;
  //Microwire
  if RadioMW.Checked then
  begin
    if (not IsNumber(ComboMWBitLen.Text)) then
    begin
      LogPrint(STR_CHECK_SETTINGS, clRed);
      Exit;
    end;

    if not SetSPISpeed(0) then exit;
    EnterProgMode25(hUSBdev);
    TimeCounter := Time();

    RomF.Position := 0;
    KHexEditor.SaveToStream(RomF);
    RomF.Position := 0;

    WriteFlashMW(RomF, StrToInt(ComboMWBitLen.Text), 0, KHexEditor.Data.Size);

    if MenuAutoCheck.Checked then
    begin
      TimeCounter := Time();
      RomF.Position :=0;
      KHexEditor.SaveToStream(RomF);
      RomF.Position :=0;
      VerifyFlashMW(RomF, StrToInt(ComboMWBitLen.Text), 0, StrToInt(ComboChipSize.Text));
    end;

  end;

  LogPrint(STR_TIME + TimeToStr(Time() - TimeCounter));

finally
  ExitProgMode25(hUSBdev);
  USB_Dev_Close(hUSBdev);
  UnlockControl();
end;
end;

procedure TMainForm.ButtonVerifyClick(Sender: TObject);
begin
  VerifyFlash(false);
end;

procedure TMainForm.VerifyFlash(BlankCheck: boolean = false);
var
  I2C_DevAddr: byte;
  I2C_ChunkSize: Word = 65535;
  i: Longword;
begin
try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  LockControl();

  if RunScriptFromFile(CurrentICParam.Script, 'verify') then Exit;

  LogPrint(TimeToStr(Time()));
  if not IsNumber(ComboChipSize.Text) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    Exit;
  end;
  if (KHexEditor.Data.Size > StrToInt(ComboChipSize.Text)) and (not BlankCheck) then
  begin
    LogPrint(STR_WRONG_FILE_SIZE, clRed);
    Exit;
  end;

  //SPI
  if RadioSPI.Checked then
  begin
    if not SetSPISpeed(0) then exit;
    EnterProgMode25(hUSBdev);
    TimeCounter := Time();

    RomF.Clear;
    if BlankCheck then
    begin
      for i:=1 to StrToInt(ComboChipSize.Text) do
        RomF.WriteByte($FF);
    end
    else
      KHexEditor.SaveToStream(RomF);
    RomF.Position :=0;

    if  ComboSPICMD.ItemIndex = SPI_CMD_KB then
      VerifyFlashKB(RomF, 0, RomF.Size);

    if ComboSPICMD.ItemIndex = SPI_CMD_25 then
      VerifyFlash25(RomF, 0, RomF.Size);

    if ComboSPICMD.ItemIndex = SPI_CMD_95 then
      VerifyFlash95(RomF, 0, RomF.Size, StrToInt(ComboChipSize.Text));

    if ComboSPICMD.ItemIndex = SPI_CMD_45 then
     begin
      if (not IsNumber(ComboPageSize.Text)) then
      begin
        LogPrint(STR_CHECK_SETTINGS, clRed);
        Exit;
      end;
      VerifyFlash45(RomF, 0, StrToInt(ComboPageSize.Text), RomF.Size);
    end;


  end;
  //I2C
  if RadioI2C.Checked then
  begin
    if ComboAddrType.ItemIndex < 0 then
    begin
      LogPrint(STR_CHECK_SETTINGS, clRed);
      Exit;
    end;

    EnterProgModeI2C(hUSBdev);

    //Адрес микросхемы по чекбоксам
    I2C_DevAddr := SetI2CDevAddr();

    if CheckBox_I2C_ByteRead.Checked then I2C_ChunkSize := 1;

    if UsbAspI2C_BUSY(hUSBdev, I2C_DevAddr) then
    begin
      LogPrint(STR_I2C_NO_ANSWER, clRed);
      exit;
    end;
    TimeCounter := Time();

    RomF.Clear;
    if BlankCheck then
    begin
      for i:=1 to StrToInt(ComboChipSize.Text) do
        RomF.WriteByte($FF);
    end
    else
      KHexEditor.SaveToStream(RomF);
    RomF.Position :=0;

    VerifyFlashI2C(RomF, RomF.Size, I2C_ChunkSize, I2C_DevAddr);
  end;

  //Microwire
  if RadioMW.Checked then
  begin
    if (not IsNumber(ComboMWBitLen.Text)) then
    begin
      LogPrint(STR_CHECK_SETTINGS, clRed);
      Exit;
    end;

    if not SetSPISpeed(0) then exit;
    EnterProgMode25(hUSBdev);
    TimeCounter := Time();

    RomF.Clear;
    if BlankCheck then
    begin
      for i:=1 to StrToInt(ComboChipSize.Text) do
        RomF.WriteByte($FF);
    end
    else
      KHexEditor.SaveToStream(RomF);
    RomF.Position :=0;

    VerifyFlashMW(RomF, StrToInt(ComboMWBitLen.Text), 0, StrToInt(ComboChipSize.Text));
  end;

  LogPrint(STR_TIME + TimeToStr(Time() - TimeCounter));

finally
  ExitProgMode25(hUSBdev);
  USB_Dev_Close(hUSBdev);
  UnlockControl();
end;
end;

procedure TMainForm.ButtonBlockClick(Sender: TObject);
var
  sreg, sreg2: byte;
  i: integer;
  s: string;
  SLreg: array[0..31] of byte;
begin
try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  sreg := 0;
  LockControl();

  if RunScriptFromFile(CurrentICParam.Script, 'unlock') then Exit;

  if not SetSPISpeed(0) then exit;
  EnterProgMode25(hUSBdev);

  if ComboSPICMD.ItemIndex = SPI_CMD_25 then
  begin
    UsbAsp25_ReadSR(hUSBDev, sreg); //Читаем регистр
    UsbAsp25_ReadSR(hUSBDev, sreg2, $35);
    LogPrint(STR_OLD_SREG+IntToBin(sreg, 8)+'(0x'+(IntToHex(sreg, 2)+'), ')
                                         +IntToBin(sreg2, 8)+'(0x'+(IntToHex(sreg2, 2)+')'));

    sreg := 0; //
    sreg2 := 0;
    UsbAsp25_WREN(hUSBDev); //Включаем разрешение записи
    UsbAsp25_WriteSR(hUSBDev, sreg); //Сбрасываем регистр

    //Пока отлипнет ромка
    while UsbAsp25_Busy(hUSBDev) do
    begin
      Application.ProcessMessages;
      if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Exit;
      end;
    end;

    UsbAsp25_WREN(hUSBDev);
    UsbAsp25_WriteSR_2byte(hUSBDev, sreg, sreg2);

    //Пока отлипнет ромка
    while UsbAsp25_Busy(hUSBDev) do
    begin
      Application.ProcessMessages;
      if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Exit;
      end;
    end;

    UsbAsp25_ReadSR(hUSBDev, sreg); //Читаем регистр
    UsbAsp25_ReadSR(hUSBDev, sreg2, $35);
    LogPrint(STR_NEW_SREG+IntToBin(sreg, 8)+'(0x'+(IntToHex(sreg, 2)+'), ')
                                         +IntToBin(sreg2, 8)+'(0x'+(IntToHex(sreg2, 2)+')'));
  end;

  if ComboSPICMD.ItemIndex = SPI_CMD_95 then
  begin
    UsbAsp95_ReadSR(hUSBDev, sreg); //Читаем регистр
    LogPrint(STR_OLD_SREG+IntToBin(sreg, 8));

    sreg := 0; //
    UsbAsp95_WREN(hUSBDev); //Включаем разрешение записи
    UsbAsp95_WriteSR(hUSBDev, sreg); //Сбрасываем регистр

    //Пока отлипнет ромка
    while UsbAsp25_Busy(hUSBDev) do
    begin
      Application.ProcessMessages;
      if MainForm.ButtonCancel.Tag <> 0 then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Exit;
      end;
    end;

    UsbAsp95_ReadSR(hUSBDev, sreg); //Читаем регистр
    LogPrint(STR_NEW_SREG+IntToBin(sreg, 8));
  end;

  if ComboSPICMD.ItemIndex = SPI_CMD_45 then
  begin
    UsbAsp45_DisableSP(hUSBDev);
    UsbAsp45_ReadSR(hUSBDev, sreg); //Читаем регистр
    LogPrint('Sreg: '+IntToBin(sreg, 8));

    UsbAsp45_ReadSectorLockdown(hUSBDev, SLreg); //Читаем Lockdown регистр

    s := '';
    for i:=0 to 31 do
    begin
      s := s + IntToHex(SLreg[i], 2);
    end;
    LogPrint('Secktor Lockdown регистр: 0x'+s);
    if UsbAsp45_isPagePowerOfTwo(hUSBDev) then LogPrint(STR_45PAGE_POWEROF2)
      else LogPrint(STR_45PAGE_STD);

  end;


finally
  ExitProgMode25(hUSBdev);
  USB_Dev_Close(hUSBdev);
  UnlockControl();
end;

end;

procedure TMainForm.ButtonReadIDClick(Sender: TObject);
var
  XMLfile: TXMLDocument;
  ID: MEMORY_ID;
  IDstr9FH: string[6];
  IDstr90H: string[4];
  IDstrABH: string[6];
  IDstr15H: string[4];
begin
  try
    if not OpenDevice() then exit;
    LockControl();
    FillByte(ID.ID9FH, 3, $FF);
    FillByte(ID.ID90H, 2, $FF);
    FillByte(ID.IDABH, 1, $FF);
    FillByte(ID.ID15H, 2, $FF);
    if not SetSPISpeed(0) then exit;

    EnterProgMode25(hUSBdev);
    UsbAsp25_ReadID(hUSBDev, ID);
    ExitProgMode25(hUSBdev);

    USB_Dev_Close(hUSBdev);

    IDstr9FH := Upcase(IntToHex(ID.ID9FH[0], 2)+IntToHex(ID.ID9FH[1], 2)+IntToHex(ID.ID9FH[2], 2));
    IDstr90H := Upcase(IntToHex(ID.ID90H[0], 2)+IntToHex(ID.ID90H[1], 2));
    IDstrABH := Upcase(IntToHex(ID.IDABH, 2));
    IDstr15H := Upcase(IntToHex(ID.ID15H[0], 2)+IntToHex(ID.ID15H[1], 2));

    if FileExists('chiplist.xml') then
    begin

      try
        ReadXMLFile(XMLfile, 'chiplist.xml');
      except
        on E: EXMLReadError do
        begin
          ShowMessage(E.Message);
        end;
      end;

      ChipSearchForm.ListBoxChips.Clear;
      ChipSearchForm.EditSearch.Text:= '';

      FindChip.FindChip(XMLfile, '', IDstr9FH);
      if ChipSearchForm.ListBoxChips.Items.Capacity = 0 then FindChip.FindChip(XMLfile, '', IDstr90H);
      if ChipSearchForm.ListBoxChips.Items.Capacity = 0 then FindChip.FindChip(XMLfile, '', IDstrABH);
      if ChipSearchForm.ListBoxChips.Items.Capacity = 0 then FindChip.FindChip(XMLfile, '', IDstr15H);

      if ChipSearchForm.ListBoxChips.Items.Capacity > 0 then
      begin
        ChipSearchForm.Show;
        LogPrint('ID(9F): '+ IDstr9FH);
        LogPrint('ID(90): '+ IDstr90H);
        LogPrint('ID(AB): '+ IDstrABH);
        LogPrint('ID(15): '+ IDstr15H);
      end
      else
      begin
        LogPrint('ID(9F): '+ IDstr9FH +STR_ID_UNKNOWN);
        LogPrint('ID(90): '+ IDstr90H +STR_ID_UNKNOWN);
        LogPrint('ID(AB): '+ IDstrABH +STR_ID_UNKNOWN);
        LogPrint('ID(15): '+ IDstr15H +STR_ID_UNKNOWN);
      end;

      XMLfile.Free;
    end;

  finally
    UnlockControl();
  end;

end;

procedure TMainForm.ButtonOpenHexClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
   KHexEditor.LoadFromFile(OpenDialog.FileName);
   StatusBar.Panels.Items[2].Text := OpenDialog.FileName;
  end;
end;

procedure TMainForm.ButtonSaveHexClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    KHexEditor.SaveToFile(SaveDialog.FileName);
    StatusBar.Panels.Items[2].Text := SaveDialog.FileName;
  end;
end;

procedure TMainForm.ButtonCancelClick(Sender: TObject);
begin
  ButtonCancel.Tag:= 1;
  ScriptEngine.Stop:= true;
end;

procedure TMainForm.I2C_DevAddrChange(Sender: TObject);
begin
  if TToggleBox(Sender).State = cbUnchecked then
  TToggleBox(Sender).Caption:= '0';
  if TToggleBox(Sender).State = cbChecked then
  TToggleBox(Sender).Caption:= '1';
end;

procedure TMainForm.ScriptsMenuItemClick(Sender: TObject);
begin
  ScriptEditForm.Show;
end;

procedure LoadChipList(XMLfile: TXMLDocument);
var
  Node: TDOMNode;
  j, i: integer;
begin
  if XMLfile <> nil then
  begin

    Node := XMLfile.DocumentElement.FirstChild;

    while Assigned(Node) do
    begin

     if (LowerCase(Node.NodeName) = 'options') or (LowerCase(Node.NodeName) = 'locale') then
     begin
       Node := Node.NextSibling;
       continue;
     end;

     MainForm.MenuChip.Add(NewItem(UTF16ToUTF8(Node.NodeName), 0, False, True, nil, 0, '')); //Раздел(SPI, I2C...)

     // Используем свойство ChildNodes
     with Node.ChildNodes do
     try
       for j := 0 to (Count - 1) do
       begin
         MainForm.MenuChip.Find(UTF16ToUTF8(Node.NodeName)).Add(NewItem(UTF16ToUTF8(Item[j].NodeName) ,0, False, True, nil, 0, '')); //Раздел Фирма

         for i := 0 to (Item[j].ChildNodes.Count - 1) do
           MainForm.MenuChip.Find(UTF16ToUTF8(Node.NodeName)).
             Find(UTF16ToUTF8(Item[j].NodeName)).
               Add(NewItem(UTF16ToUTF8(Item[j].ChildNodes.Item[i].NodeName), 0, False, True, @MainForm.ChipClick, 0, '' )); //Чип
       end;
     finally
       Free;
     end;
     Node := Node.NextSibling;
    end;
  end;

end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //VID&PID UsBAsp'а
  DeviceDescription.idVENDOR:= $16C0;
  DeviceDescription.idPRODUCT:= $05DC;

  avrisp_DeviceDescription.idVENDOR:= $03EB;
  avrisp_DeviceDescription.idPRODUCT:= $2104;

  LoadChipList(ChipListFile);
  RomF := TMemoryStream.Create;
  ScriptEngine := TPasCalc.Create;
  ScriptsFunc.SetScriptFunctions(ScriptEngine);

  KHexEditor.ExecuteCommand(ecOverwriteMode);
  LoadOptions(SettingsFile);
  LoadLangList();
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  MainForm.KHexEditor.Free;
  RomF.Free;
  SaveOptions(SettingsFile);
  ChipListFile.Free;
  SettingsFile.Free;
  ScriptEngine.Free;
end;

procedure TMainForm.ButtonReadClick(Sender: TObject);
var
  I2C_DevAddr: byte;
  I2C_ChunkSize: word = 65535;
begin
try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  LockControl();

  if RunScriptFromFile(CurrentICParam.Script, 'read') then Exit;

  LogPrint(TimeToStr(Time()));

  if (not IsNumber(ComboChipSize.Text)) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    Exit;
  end;

  //SPI
  if RadioSPI.Checked then
  begin
    if not SetSPISpeed(0) then exit;
    EnterProgMode25(hUSBdev);
    TimeCounter := Time();

    if  ComboSPICMD.ItemIndex = SPI_CMD_KB then
    begin
      ReadFlashKB(RomF, 0, StrToInt(ComboChipSize.Text));
    end;

    if  ComboSPICMD.ItemIndex = SPI_CMD_25 then
      ReadFlash25(RomF, 0, StrToInt(ComboChipSize.Text));
    if  ComboSPICMD.ItemIndex = SPI_CMD_45 then
    begin
      if (not IsNumber(ComboPageSize.Text)) then
      begin
        LogPrint(STR_CHECK_SETTINGS, clRed);
        Exit;
      end;
      ReadFlash45(RomF, 0, StrToInt(ComboPageSize.Text), StrToInt(ComboChipSize.Text));
    end;

    if  ComboSPICMD.ItemIndex = SPI_CMD_95 then
      ReadFlash95(RomF, 0, StrToInt(ComboChipSize.Text));

    RomF.Position := 0;
    KHexEditor.LoadFromStream(RomF);
    StatusBar.Panels.Items[2].Text := LabelChipName.Caption;
  end;
  //I2C
  if RadioI2C.Checked then
  begin
    if ComboAddrType.ItemIndex < 0 then
    begin
      LogPrint(STR_CHECK_SETTINGS, clRed);
      Exit;
    end;

    EnterProgModeI2c(hUSBdev);

    //Адрес микросхемы по чекбоксам
    I2C_DevAddr := SetI2CDevAddr();

    if CheckBox_I2C_ByteRead.Checked then I2C_ChunkSize := 1;

    if UsbAspI2C_BUSY(hUSBdev, I2C_DevAddr) then
    begin
      LogPrint(STR_I2C_NO_ANSWER, clRed);
      exit;
    end;
    TimeCounter := Time();
    ReadFlashI2C(RomF, StrToInt(ComboChipSize.Text), I2C_ChunkSize, I2C_DevAddr);

    RomF.Position := 0;
    KHexEditor.LoadFromStream(RomF);
    StatusBar.Panels.Items[2].Text := LabelChipName.Caption;
  end;
  //Microwire
  if RadioMw.Checked then
  begin
    if (not IsNumber(ComboMWBitLen.Text)) then
    begin
      LogPrint(STR_CHECK_SETTINGS, clRed);
      Exit;
    end;

    if not SetSPISpeed(0) then exit;
    EnterProgMode25(hUSBdev);
    TimeCounter := Time();
    ReadFlashMW(RomF, StrToInt(ComboMWBitLen.Text), 0, StrToInt(ComboChipSize.Text));

    RomF.Position := 0;
    KHexEditor.LoadFromStream(RomF);
    StatusBar.Panels.Items[2].Text := LabelChipName.Caption;
  end;

  LogPrint(STR_TIME + TimeToStr(Time() - TimeCounter));

finally
  ExitProgMode25(hUSBdev);
  USB_Dev_Close(hUSBdev);
  UnlockControl();
end;
end;

procedure TMainForm.ClearLogMenuItemClick(Sender: TObject);
begin
  Log.Lines.Clear;
end;

procedure TMainForm.ComboSPICMDChange(Sender: TObject);
begin
  RadioSPI.OnChange(Sender);
end;

procedure TMainForm.CopyLogMenuItemClick(Sender: TObject);
begin
  Log.CopyToClipboard;
end;

procedure TMainForm.ButtonEraseClick(Sender: TObject);
var
  I2C_DevAddr: byte;
begin
try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  if Sender <> ComboItem1 then
    if MessageDlg('AsProgrammer', STR_START_ERASE, mtConfirmation, [mbYes, mbNo], 0)
      <> mrYes then Exit;
  LockControl();

  if RunScriptFromFile(CurrentICParam.Script, 'erase') then Exit;

  LogPrint(TimeToStr(Time()));

  //SPI
  if RadioSPI.Checked then
  begin
    if not SetSPISpeed(0) then exit;
    EnterProgMode25(hUSBdev);
    if ComboSPICMD.ItemIndex <> SPI_CMD_KB then
      IsLockBitsEnabled;
    TimeCounter := Time();

    LogPrint(STR_ERASING_FLASH);

    if ComboSPICMD.ItemIndex = SPI_CMD_KB then
    begin

      if (not IsNumber(ComboChipSize.Text)) then
      begin
        LogPrint(STR_CHECK_SETTINGS, clRed);
        Exit;
      end;

      if (not IsNumber(ComboPageSize.Text)) then
      begin
        LogPrint(STR_CHECK_SETTINGS, clRed);
        Exit;
      end;

      UsbAspMulti_EnableEDI(hUSBdev);
      UsbAspMulti_WriteReg(hUSBdev, $FEAD, $08); //en flash
      UsbAspMulti_WriteReg(hUSBdev, $FEA7, $A4); //en write
      UsbAspMulti_Erase(hUSBdev, StrToInt(ComboChipSize.Text), StrToInt(ComboPageSize.Text));
    end;

    if ComboSPICMD.ItemIndex = SPI_CMD_25 then
    begin
      UsbAsp25_WREN(hUSBDev);
      UsbAsp25_ChipErase(hUSBdev);

      while UsbAsp25_Busy(hUSBDev) do
      begin
        Application.ProcessMessages;
        if MainForm.ButtonCancel.Tag <> 0 then
        begin
          LogPrint(STR_USER_CANCEL, clRed);
          Exit;
        end;
      end;
    end;

    if ComboSPICMD.ItemIndex = SPI_CMD_95 then
      begin
        if ( (not IsNumber(ComboChipSize.Text)) or (not IsNumber(ComboPageSize.Text))) then
        begin
          LogPrint(STR_CHECK_SETTINGS, clRed);
          Exit;
        end;

      EraseEEPROM25(0, StrToInt(ComboChipSize.Text), StrToInt(ComboPageSize.Text), StrToInt(ComboChipSize.Text));
    end;

    if ComboSPICMD.ItemIndex = SPI_CMD_45 then
    begin
      UsbAsp45_ChipErase(hUSBdev);

      while UsbAsp45_Busy(hUSBDev) do
      begin
        Application.ProcessMessages;
        if MainForm.ButtonCancel.Tag <> 0 then
        begin
          LogPrint(STR_USER_CANCEL, clRed);
          Exit;
        end;
      end;
    end;

  end;

  //I2C
  if RadioI2C.Checked then
  begin
  if ( (ComboAddrType.ItemIndex < 0) or (not IsNumber(ComboPageSize.Text)) ) then
    begin
      LogPrint(STR_CHECK_SETTINGS, clRed);
      Exit;
    end;

    EnterProgModeI2C(hUSBdev);

    //Адрес микросхемы по чекбоксам
    I2C_DevAddr := SetI2CDevAddr();

    if UsbAspI2C_BUSY(hUSBdev, I2C_DevAddr) then
    begin
      LogPrint(STR_I2C_NO_ANSWER, clRed);
      exit;
    end;

    TimeCounter := Time();

    if StrToInt(ComboPageSize.Text) < 1 then ComboPageSize.Text := '1';

    EraseFlashI2C(0, StrToInt(ComboChipSize.Text), StrToInt(ComboPageSize.Text), I2C_DevAddr);
  end;

  //Microwire
  if RadioMW.Checked then
  begin
    if (not IsNumber(ComboMWBitLen.Text)) then
    begin
      LogPrint(STR_CHECK_SETTINGS, clRed);
      Exit;
    end;

    if not SetSPISpeed(0) then exit;
    EnterProgMode25(hUSBdev);
    TimeCounter := Time();
    LogPrint(STR_ERASING_FLASH);
    UsbAspMW_Ewen(hUSBdev, StrToInt(ComboMWBitLen.Text));
    UsbAspMW_ChipErase(hUSBdev, StrToInt(ComboMWBitLen.Text));

    if Current_HW = CH341 then
      while ch341mw_busy do
         Application.ProcessMessages;

    if Current_HW = AVRISP then
      while avrisp_mw_busy do
         Application.ProcessMessages;

    if Current_HW = USBASP then
      while (UsbAspMW_Busy(hUSBdev)) do
         Application.ProcessMessages;

  end;


  LogPrint(STR_DONE);
  LogPrint(STR_TIME + TimeToStr(Time() - TimeCounter));

finally
  ExitProgMode25(hUSBdev);
  USB_Dev_Close(hUSBdev);
  UnlockControl();
end;
end;

procedure TMainForm.BlankCheckMenuItemClick(Sender: TObject);
begin
  VerifyFlash(true);
end;

procedure SaveOptions(XMLfile: TXMLDocument);
var
  Node, ParentNode: TDOMNode;
begin
  if XMLfile <> nil then
  begin
    //Удаляем старую запись
    Node := XMLfile.DocumentElement.FindNode('locale');
    if (Node <> nil) then XMLfile.DocumentElement.RemoveChild(Node);
    //Создаем новую
    Node:= XMLfile.DocumentElement;
    ParentNode := XMLfile.CreateElement('locale');
    TDOMElement(ParentNode).SetAttribute('lang', CurrentLang);
    Node.Appendchild(parentNode);

    //Удаляем старую запись
    Node := XMLfile.DocumentElement.FindNode('options');
    if (Node <> nil) then XMLfile.DocumentElement.RemoveChild(Node);

    Node:= XMLfile.DocumentElement;
    ParentNode := XMLfile.CreateElement('options');

    if MainForm.MenuAutoCheck.Checked then
      TDOMElement(ParentNode).SetAttribute('verify', '1') else
        TDOMElement(ParentNode).SetAttribute('verify', '0');

    if MainForm.Menu3Mhz.Checked then
      TDOMElement(ParentNode).SetAttribute('spi_speed', '3Mhz');
    if MainForm.Menu1_5Mhz.Checked then
      TDOMElement(ParentNode).SetAttribute('spi_speed', '1_5Mhz');
    if MainForm.Menu750Khz.Checked then
      TDOMElement(ParentNode).SetAttribute('spi_speed', '750Khz');
    if MainForm.Menu375Khz.Checked then
      TDOMElement(ParentNode).SetAttribute('spi_speed', '375Khz');
    if MainForm.Menu187_5Khz.Checked then
      TDOMElement(ParentNode).SetAttribute('spi_speed', '187_5Khz');
    if MainForm.Menu93_75Khz.Checked then
      TDOMElement(ParentNode).SetAttribute('spi_speed', '93_75Khz');
    if MainForm.Menu32Khz.Checked then
      TDOMElement(ParentNode).SetAttribute('spi_speed', '32Khz');

    if MainForm.MenuMW32Khz.Checked then
      TDOMElement(ParentNode).SetAttribute('mw_speed', '32Khz');
    if MainForm.MenuMW16Khz.Checked then
      TDOMElement(ParentNode).SetAttribute('mw_speed', '16Khz');
    if MainForm.MenuMW8Khz.Checked then
      TDOMElement(ParentNode).SetAttribute('mw_speed', '8Khz');

    if MainForm.MenuHWUSBASP.Checked then
      TDOMElement(ParentNode).SetAttribute('hw', 'usbasp');
    if MainForm.MenuHWCH341A.Checked then
      TDOMElement(ParentNode).SetAttribute('hw', 'ch341a');
    if MainForm.MenuHWAVRISP.Checked then
      TDOMElement(ParentNode).SetAttribute('hw', 'avrisp');

    Node.Appendchild(parentNode);

    WriteXMLFile(XMLfile, SettingsFileName);
  end;

end;

procedure LoadOptions(XMLfile: TXMLDocument);
var
    Node: TDOMNode;
    OptVal: string;
begin
  if XMLfile <> nil then
  begin
    Node := XMLfile.DocumentElement.FindNode('options');

    if (Node <> nil) then
    if (Node.HasAttributes) then
    begin

      if  Node.Attributes.GetNamedItem('verify') <> nil then
      begin
        if Node.Attributes.GetNamedItem('verify').NodeValue = '1' then
          MainForm.MenuAutoCheck.Checked := true;
      end;

      if  Node.Attributes.GetNamedItem('spi_speed') <> nil then
      begin
        OptVal := UTF16ToUTF8(Node.Attributes.GetNamedItem('spi_speed').NodeValue);

        if OptVal = '3Mhz' then MainForm.Menu3Mhz.Checked := true;
        if OptVal = '1_5Mhz' then MainForm.Menu1_5Mhz.Checked := true;
        if OptVal = '750Khz' then MainForm.Menu750Khz.Checked := true;
        if OptVal = '375Khz' then MainForm.Menu375Khz.Checked := true;
        if OptVal = '187_5Khz' then MainForm.Menu187_5Khz.Checked := true;
        if OptVal = '93_75Khz' then MainForm.Menu93_75Khz.Checked := true;
        if OptVal = '32Khz' then MainForm.Menu32Khz.Checked := true;

      end;

      if  Node.Attributes.GetNamedItem('mw_speed') <> nil then
      begin
        OptVal := UTF16ToUTF8(Node.Attributes.GetNamedItem('mw_speed').NodeValue);

        if OptVal = '32Khz' then MainForm.MenuMW32Khz.Checked := true;
        if OptVal = '16Khz' then MainForm.MenuMW16Khz.Checked := true;
        if OptVal = '8Khz' then MainForm.MenuMW8Khz.Checked := true;
      end;

      if  Node.Attributes.GetNamedItem('hw') <> nil then
      begin
        OptVal := UTF16ToUTF8(Node.Attributes.GetNamedItem('hw').NodeValue);

        if OptVal = 'usbasp' then
        begin
          MainForm.MenuHWUSBASP.Checked := true;
          SelectHW(HW_USBASP);
        end;

        if OptVal = 'ch341a' then
        begin
          MainForm.MenuHWCH341A.Checked := true;
          SelectHW(HW_CH341A);
        end;

        if OptVal = 'avrisp' then
        begin
          MainForm.MenuHWAVRISP.Checked := true;
          SelectHW(HW_AVRISPMK2);
        end;

      end;

    end;
  end;

end;


end.
