unit main;

//TODO: Толстая i2c   добавить
//TODO: Облагородить лог

//TODO: at45 установка размера странцы
//TODO: at45 Проверка размера страницы перед операциями


//I2C
//24C08
//24C04
//24С512

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Menus, Grids, ActnList, Buttons,
  RichMemo, KHexEditor, KEditCommon, StrUtils, usbasp25, usbasp45, usbaspi2c, usbaspmw, usbaspmulti,
  usbhid, libusb, dos, XMLRead, DOM, KControls;

type

  { TMainForm }

  TMainForm = class(TForm)
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
    LabelSPICMD: TLabel;
    LabelChipName: TLabel;
    MainMenu: TMainMenu;
    Menu32Khz: TMenuItem;
    Menu93_75Khz: TMenuItem;
    MenuChip: TMenuItem;
    MenuAutoCheck: TMenuItem;
    ComboItem1: TMenuItem;
    Menu3Mhz: TMenuItem;
    Menu6Mhz: TMenuItem;
    MenuIgnoreBusyBit: TMenuItem;
    MenuGotoOffset: TMenuItem;
    MenuFind: TMenuItem;
    MenuItem1: TMenuItem;
    MenuCopyToClip: TMenuItem;
    CopyLogMenuItem: TMenuItem;
    ClearLogMenuItem: TMenuItem;
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
    ProgressBar: TProgressBar;
    RadioI2C: TRadioButton;
    RadioMw: TRadioButton;
    RadioSPI: TRadioButton;
    Log: TRichMemo;
    SaveDialog: TSaveDialog;
    StatusBar: TStatusBar;
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
    procedure ButtonEraseClick(Sender: TObject);
    procedure ButtonReadClick(Sender: TObject);
    procedure ClearLogMenuItemClick(Sender: TObject);
    procedure ComboSPICMDChange(Sender: TObject);
    procedure CopyLogMenuItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChipClick(Sender: TObject);
    procedure KHexEditorChange(Sender: TObject);
    procedure ComboItem1Click(Sender: TObject);
    procedure KHexEditorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure MenuAutoCheckClick(Sender: TObject);
    procedure MenuCopyToClipClick(Sender: TObject);
    procedure MenuFindClick(Sender: TObject);
    procedure MenuGotoOffsetClick(Sender: TObject);
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
  private
    { private declarations }
  public
    { public declarations }
  end;

  procedure LogPrint(text: string; AColor: TColor = clDefault);
  function UsbAspEEPROMSupport(): integer;
  procedure FindHEX(FindStr: string);

  const
  STR_CHECK_SETTINGS     = 'Проверьте настройки';
  STR_READING_FLASH      = 'Читаю флэшку...';
  STR_WRITING_FLASH      = 'Записываю флэшку...';
  STR_WRITING_FLASH_WCHK = 'Записываю флэшку с проверкой...';
  STR_CONNECTION_ERROR   = 'Ошибка подключения к USBAsp';
  STR_SET_SPEED_ERROR    = 'Ошибка установки скорости SPI';
  STR_WRONG_BYTES_READ   = 'Количество прочитанных байт не равно размеру флэшки';
  STR_WRONG_BYTES_WRITE  = 'Количество записанных байт не равно размеру флэшки';
  STR_WRONG_FILE_SIZE    = 'Размер файла больше размера чипа';
  STR_ERASING_FLASH      = 'Стираю флэшку...';
  STR_DONE               = 'Готово';
  STR_BLOCK_EN           = 'Возможно включена защита на запись. Нажмите кнопку "Снять защиту" и сверьтесь с даташитом';
  STR_VERIFY_ERROR       = 'Ошибка сравнения по адресу: ';
  STR_VERIFY             = 'Проверяю флэшку...';
  STR_TIME               = 'Время выполнения: ';
  STR_USER_CANCEL        = 'Прервано пользователем';
  STR_NO_EEPROM_SUPPORT  = 'Данная версия прошивки не поддерживается!';
  STR_MINI_EEPROM_SUPPORT= 'Данная версия прошивки не поддерживает I2C и MW!';


  SPI_CMD_25             = 0;
  SPI_CMD_45             = 1;
  SPI_CMD_KB             = 2;


var
  MainForm: TMainForm;

implementation


var
  DeviceDescription: TDeviceDescription;
  hUSBDev: pusb_dev_handle; //Хендл usbasp
  RomF: TMemoryStream;
  TimeCounter: TDateTime;

{$R *.lfm}

function IsNumber(strSource: string): boolean;
begin
  try
    StrToInt(strSource);
    Result:=true;
  except
    on EConvertError do Result:=false;
  end;
end;

procedure LogPrint(text: string; AColor: TColor = clDefault);
var
    fp: TFontParams;
    AFont: TFont;
    selstart, SelLength: Integer;
begin

  SelLength := Length(MainForm.Log.Text);
  SelStart := Length(MainForm.Log.Text);

  MainForm.Log.GetTextAttributes(SelStart, fp);
  fp.Color := AColor;
  MainForm.Log.SetTextAttributes(SelStart, SelLength, fp);

  MainForm.Log.Lines.Add(Text);

end;

//Получаем хедл usbasp
function OpenDevice: boolean;
var
  err: integer;
begin
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
    if (sreg and 4 <> 0) or
       (sreg and 8 <> 0) or
       (sreg and 16 <> 0) or
       (sreg and 32 <> 0) or
       (sreg and 64 <> 0) or
       (sreg and 128 <> 0)
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
  if MainForm.RadioSPI.Checked then
  begin
    if MainForm.Menu6Mhz.Checked then Speed := MainForm.Menu6Mhz.Tag;
    if MainForm.Menu3Mhz.Checked then Speed := MainForm.Menu3Mhz.Tag;
    if MainForm.Menu1_5Mhz.Checked then Speed := MainForm.Menu1_5Mhz.Tag;
    if MainForm.Menu750Khz.Checked then Speed := MainForm.Menu750Khz.Tag;
    if MainForm.Menu375Khz.Checked then Speed := MainForm.Menu375Khz.Tag;
    if MainForm.Menu187_5Khz.Checked then Speed := MainForm.Menu187_5Khz.Tag;
    if MainForm.Menu93_75Khz.Checked then Speed := MainForm.Menu93_75Khz.Tag;
    if MainForm.Menu32Khz.Checked then Speed := MainForm.Menu32Khz.Tag;
  end;

  if MainForm.RadioMw.Checked then
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


procedure ReadFlashMW(var RomStream: TMemoryStream; AddrBitLen: byte; StartAddress, ChipSize: cardinal);
var
  ChunkSize: Word;
  BytesRead: integer;
  DataChunk: array[0..4095] of byte;
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

  try
    RomStream.Clear;

    while Address < ChipSize div 2 do
    begin

      //if ChunkSize > ((ChipSize div 2) - Address) then ChunkSize := (ChipSize div 2) - Address;

      BytesRead := BytesRead + UsbAspMW_Read(hUSBDev, AddrBitLen, Address, datachunk, ChunkSize);
      RomStream.WriteBuffer(datachunk, ChunkSize);
      Inc(Address, ChunkSize div 2);

      MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 2;
      Application.ProcessMessages;
    end;

  finally

  end;

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, ClRed)
  else
    LogPrint(STR_DONE);
  MainForm.ProgressBar.Position := 0;
end;

procedure WriteFlashMW(var RomStream: TMemoryStream; AddrBitLen: byte; StartAddress, ChipSize: cardinal);
var
  DataChunk: array[0..4095] of byte;
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

  ChunkSize := 64;
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  try
    UsbAspMW_EWEN(hUSBDev, AddrBitLen);

    while Address < ChipSize div 2 do
    begin
      RomStream.ReadBuffer(DataChunk, ChunkSize);

      BytesWrite := BytesWrite + UsbAspMW_Write(hUSBDev, AddrBitLen, Address, datachunk, ChunkSize);
      Inc(Address, ChunkSize div 2);

      MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + ChunkSize;
      Application.ProcessMessages;
    end;

  finally

  end;

  if BytesWrite <> ChipSize then
    LogPrint(STR_WRONG_BYTES_WRITE, ClRed)
  else
    LogPrint(STR_DONE);
  MainForm.ProgressBar.Position := 0;
end;

procedure WriteFlash25(var RomStream: TMemoryStream; StartAddress, WriteSize: cardinal; PageSize: word; WriteType: integer);
var
  DataChunk: array[0..4095] of byte;
  DataChunk2: array[0..4095] of byte;
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

  try

    while Address < WriteSize do
    begin
      //Только вначале aai
      if (((WriteType = WT_SSTB) or (WriteType = WT_SSTW)) and (Address = StartAddress))
        or
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
        BytesWrite := BytesWrite + UsbAsp25_Write(hUSBDev, $02, Address, datachunk, PageSize);


      if not MainForm.MenuIgnoreBusyBit.Checked then  //Игнорировать проверку
      if UsbAsp25_Busy(hUSBDev) then
      begin
        LogPrint(STR_USER_CANCEL , clRed);
        Break;
      end;

      if (MainForm.MenuAutoCheck.Checked) and (WriteType = WT_PAGE) then
      begin
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

    UsbAsp25_Wrdi(hUSBDev); //Для sst

  finally
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
  DataChunk: array[0..4095] of byte;
  DataChunk2: array[0..4095] of byte;
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

  try

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
        Exit;
      end;
      Application.ProcessMessages;
    end;

  finally
  end;

  if BytesWrite <> WriteSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);
  MainForm.ProgressBar.Position := 0;
end;

procedure WriteFlash45(var RomStream: TMemoryStream; StartAddress, ChipSize: cardinal; PageSize: word; WriteType: integer);
var
  DataChunk: array[0..4095] of byte;
  DataChunk2: array[0..4095] of byte;
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

  try

    while PageAddress < ChipSize div PageSize do
    begin
      //UsbAsp45_WREN(hUSBDev);
      RomStream.ReadBuffer(DataChunk, PageSize);

      if WriteType = WT_PAGE then
        BytesWrite := BytesWrite + UsbAsp45_Write(hUSBDev, PageAddress, datachunk, PageSize);

      if UsbAsp45_Busy(hUSBDev) then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Break;
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


  finally
  end;

  if BytesWrite <> ChipSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);
  MainForm.ProgressBar.Position := 0;
end;

procedure ReadFlash25(var RomStream: TMemoryStream; StartAddress, ChipSize: cardinal);
var
  ChunkSize: Word;
  BytesRead: integer; //4095
  DataChunk: array[0..4095] of byte;
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

  try
    RomStream.Clear;

    while Address < ChipSize do
    begin
      if ChunkSize > (ChipSize - Address) then ChunkSize := ChipSize - Address;

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

  finally
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

  try
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

  finally
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
  BytesRead: integer; //4095
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

  try
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

  finally
  end;

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);
  MainForm.ProgressBar.Position := 0;
end;


procedure VerifyFlash25(var RomStream: TMemoryStream; StartAddress, DataSize: cardinal);
var
  ChunkSize: Word;
  BytesRead, i: integer;
  DataChunk: array[0..4095] of byte;
  DataChunkFile: array[0..4095] of byte;
  Address: cardinal;
begin
  if (StartAddress >= DataSize) or (DataSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := 4096;
  if ChunkSize > DataSize then ChunkSize := DataSize;

  LogPrint(STR_VERIFY);
  BytesRead := 0;
  Address := StartAddress;
  MainForm.ProgressBar.Max := DataSize div ChunkSize;

  try

  while Address < DataSize do
  begin
    if ChunkSize > (DataSize - Address) then ChunkSize := DataSize - Address;

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

  finally
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

  try

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

  finally
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
  DataChunk: array[0..4095] of byte;
  DataChunkFile: array[0..4095] of byte;
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

  try

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

  finally

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
  BytesRead: integer; //4095
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

  try
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

  finally
  end;

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);
  MainForm.ProgressBar.Position := 0;
end;

procedure ReadFlashI2C(var RomStream: TMemoryStream; ChipSize: cardinal);
var
  ChunkSize: Word;
  BytesRead: integer;
  DataChunk: array[0..4095] of byte;
  Address: cardinal;
begin
  if ChipSize = 0 then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := SizeOf(DataChunk);
  if ChunkSize > ChipSize then ChunkSize := ChipSize;

  LogPrint(STR_READING_FLASH);
  BytesRead := 0;
  Address := 0;
  MainForm.ProgressBar.Max := ChipSize div ChunkSize;

  try
  RomStream.Clear;

    while Address < ChipSize do
    begin
      if ChunkSize > (ChipSize - Address) then ChunkSize := ChipSize - Address;

      BytesRead := BytesRead + UsbAspI2C_Read(hUSBDev, MainForm.ComboAddrType.ItemIndex, Address, datachunk, ChunkSize);
      RomStream.WriteBuffer(DataChunk, ChunkSize);
      Inc(Address, ChunkSize);

      MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
      Application.ProcessMessages;
    end;

  finally
  end;

  if BytesRead <> ChipSize then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);
  MainForm.ProgressBar.Position := 0;
end;

procedure WriteFlashI2C(var RomStream: TMemoryStream; StartAddress, WriteSize: cardinal; PageSize: word);
var
  DataChunk: array[0..4095] of byte;
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
  try

    while Address < WriteSize do
    begin
      if (WriteSize - Address) < PageSize then PageSize := (WriteSize - Address);
      RomStream.ReadBuffer(DataChunk, PageSize);
      BytesWrite := BytesWrite + UsbAspI2C_Write(hUSBDev, MainForm.ComboAddrType.ItemIndex, Address, datachunk, PageSize);
      Inc(Address, PageSize);

      while UsbAspI2C_BUSY(hUSBdev, %10100000) do
      begin
        Application.ProcessMessages;
      end;

      MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
      Application.ProcessMessages;
    end;

  finally
  end;

  if BytesWrite <> WriteSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);
  MainForm.ProgressBar.Position := 0;
end;

procedure EraseFlashI2C(StartAddress, WriteSize: cardinal; PageSize: word);
var
  DataChunk: array[0..4095] of byte;
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
  try

    while Address < WriteSize do
    begin
      if (WriteSize - Address) < PageSize then PageSize := (WriteSize - Address);
      FillByte(DataChunk, PageSize, $FF);
      BytesWrite := BytesWrite + UsbAspI2C_Write(hUSBDev, MainForm.ComboAddrType.ItemIndex, Address, datachunk, PageSize);
      Inc(Address, PageSize);

      while UsbAspI2C_BUSY(hUSBdev, %10100000) do
      begin
        Application.ProcessMessages;
      end;

      MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + 1;
      Application.ProcessMessages;
    end;

  finally
  end;

  if BytesWrite <> WriteSize then
    LogPrint(STR_WRONG_BYTES_WRITE, clRed)
  else
    LogPrint(STR_DONE);
  MainForm.ProgressBar.Position := 0;
end;

procedure VerifyFlashI2C(var RomStream: TMemoryStream; DataSize: cardinal);
var
  ChunkSize: Word;
  BytesRead, i: integer;
  DataChunk: array[0..4095] of byte;
  DataChunkFile: array[0..4095] of byte;
  Address: cardinal;
begin
  if (DataSize = 0) then
  begin
    LogPrint(STR_CHECK_SETTINGS, clRed);
    exit;
  end;

  ChunkSize := SizeOf(DataChunk);
  if ChunkSize > DataSize then ChunkSize := DataSize;

  LogPrint(STR_VERIFY);
  BytesRead := 0;
  Address := 0;
  MainForm.ProgressBar.Max := DataSize div ChunkSize;

  try

  while Address < DataSize do
  begin
    if ChunkSize > (DataSize - Address) then ChunkSize := DataSize - Address;

    BytesRead := BytesRead + UsbAspI2C_Read(hUSBDev, MainForm.ComboAddrType.ItemIndex, Address, datachunk, ChunkSize);
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

  finally
  end;

  if (BytesRead <> DataSize) then
    LogPrint(STR_WRONG_BYTES_READ, clRed)
  else
    LogPrint(STR_DONE);
  MainForm.ProgressBar.Position := 0;
end;

procedure LockControl;
begin
  //MainForm.ToolBar.Enabled := false;
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
  //MainForm.ToolBar.Enabled := True;
  MainForm.ButtonRead.Enabled := True;
  MainForm.ButtonWrite.Enabled := True;
  MainForm.ButtonVerify.Enabled := True;
  MainForm.ButtonOpenHex.Enabled := True;
  MainForm.ButtonSaveHex.Enabled := True;
  MainForm.ButtonErase.Enabled := True;

  if MainForm.RadioSPI.Checked then
  begin
    MainForm.ButtonReadID.Enabled := True;
    MainForm.ButtonBlock.Enabled := True;
  end;



end;

procedure TMainForm.ChipClick(Sender: TObject);
var
  XMLfile: TXMLDocument;
  Node: TDOMNode;
begin
  ReadXMLFile(XMLfile, 'chiplist.xml');

  if Sender is TMenuItem then
  begin
    Node := XMLfile.DocumentElement.FindNode(TMenuItem(Sender).Parent.Parent.Caption);

    if UpperCase(Node.NodeName) = 'SPI' then RadioSPI.Checked := True;
    if UpperCase(Node.NodeName) = 'I2C' then RadioI2C.Checked := True;
    if UpperCase(Node.NodeName) = 'MICROWIRE' then RadioMW.Checked := True;

    Node := XMLfile.DocumentElement.
      FindNode(TMenuItem(Sender).Parent.Parent.Caption).
        FindNode(TMenuItem(Sender).Parent.Caption).
          FindNode(TMenuItem(Sender).Caption);

    LabelChipName.Caption := Node.NodeName;

    if (Node.HasAttributes) then
    begin

      if  Node.Attributes.GetNamedItem('spicmd') <> nil then
      begin
        if UpperCase(Node.Attributes.GetNamedItem('spicmd').NodeValue) = 'KB'then
          MainForm.ComboSPICMD.ItemIndex:= 2;
        if Node.Attributes.GetNamedItem('spicmd').NodeValue = '45' then
          MainForm.ComboSPICMD.ItemIndex:= 1 else
        if Node.Attributes.GetNamedItem('spicmd').NodeValue = '25' then
          MainForm.ComboSPICMD.ItemIndex:= 0;
      end
      else
        ComboSPICMD.ItemIndex := 0;

      if RadioSPI.Checked then RadioSPI.OnChange(Sender);

      if  Node.Attributes.GetNamedItem('page') <> nil then
        ComboPageSize.Text := Node.Attributes.GetNamedItem('page').NodeValue
      else
        ComboPageSize.Text := 'Page size';

      if Node.Attributes.GetNamedItem('size') <> nil then
        ComboChipSize.Text := Node.Attributes.GetNamedItem('size').NodeValue
      else
        ComboChipSize.Text := 'Chip size';

      if Node.Attributes.GetNamedItem('addrbitlen') <> nil then
        ComboMWBitLen.Text := Node.Attributes.GetNamedItem('addrbitlen').NodeValue
      else
        ComboMWBitLen.Text := 'MW addr len';

      if Node.Attributes.GetNamedItem('addrtype') <> nil then
        if IsNumber(Node.Attributes.GetNamedItem('addrtype').NodeValue) then
          ComboAddrType.ItemIndex := StrToInt(Node.Attributes.GetNamedItem('addrtype').NodeValue);

    end;

  end;

  XMLfile.Free;
end;


procedure TMainForm.KHexEditorKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //Костыль. Так как событие TKHEXEditor.OnChange вызывается до изменения содержимого =)
  StatusBar.Panels.Items[0].Text := 'Размер: '+IntToStr(KHexEditor.Data.Size);
end;

procedure TMainForm.KHexEditorChange(Sender: TObject);
begin
  //StatusBar.Panels.Items[0].Text := 'Размер: '+IntToStr(KHexEditor.Data.Size);
  if KHexEditor.Modified then
    StatusBar.Panels.Items[1].Text := 'Изменен'
  else
    StatusBar.Panels.Items[1].Text := '';
end;

function FindID(XMLDoc: TXMLDocument; ChipID: string): string;
var
  iNode: TDOMNode;

  procedure ProcessNode(Node: TDOMNode; var ChipName: string);
  var
    cNode: TDOMNode;
    s: string;
  begin
    if Node = nil then Exit; // выходим, если достигнут конец документа

    //узел
    if Node.HasAttributes and (Node.Attributes.Length>0) then
    begin
      cNode := Node.Attributes.GetNamedItem('id');
      if CNode <> nil then s:= CNode.NodeValue else s := '';
    end
    else
      s:='';

    if Upcase(s) = Upcase(ChipId) then
    begin
      ChipName := Node.NodeName;
      MainForm.LabelChipName.Caption:= Node.NodeName;
      MainForm.ComboChipSize.Text:= Node.Attributes.GetNamedItem('size').NodeValue;
      MainForm.ComboPageSize.Text:= Node.Attributes.GetNamedItem('page').NodeValue;

      if  Node.Attributes.GetNamedItem('spicmd') <> nil then
      begin
        if UpperCase(Node.Attributes.GetNamedItem('spicmd').NodeValue) = 'KB'then
          MainForm.ComboSPICMD.ItemIndex:= 2;
        if Node.Attributes.GetNamedItem('spicmd').NodeValue = '45' then
          MainForm.ComboSPICMD.ItemIndex:= 1 else
        if Node.Attributes.GetNamedItem('spicmd').NodeValue = '25' then
          MainForm.ComboSPICMD.ItemIndex:= 0;
      end
      else
        MainForm.ComboSPICMD.ItemIndex := 0;

    end;

    // переходим к дочернему узлу
    cNode := Node.FirstChild;

    // проходим по всем дочерним узлам
    while cNode <> nil do
    begin
      ProcessNode(cNode, ChipName);
      cNode := cNode.NextSibling;
    end;
  end;

begin
  iNode := XMLDoc.DocumentElement.FirstChild;
  Result := '';
  while iNode <> nil do
  begin
    ProcessNode(iNode, result); // Рекурсия
    iNode := iNode.NextSibling;
  end;
end;

procedure TMainForm.ComboItem1Click(Sender: TObject);
var
  CheckTemp: Boolean;
begin
  if MessageDlg('AsProgrammer', 'Чип будет стерт и перезаписан. Продолжить?', mtConfirmation, [mbYes, mbNo], 0)
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


procedure TMainForm.MenuAutoCheckClick(Sender: TObject);
begin

end;

procedure TMainForm.MenuCopyToClipClick(Sender: TObject);
begin
  MainForm.KHexEditor.ExecuteCommand(ecCopy);
end;

procedure TMainForm.MenuFindClick(Sender: TObject);
var
  s : string;
begin
   s := InputBox('Поиск HEX значения','','');
   if s <> '' then FindHEX(Utf8ToSys(s));
end;

procedure TMainForm.MenuGotoOffsetClick(Sender: TObject);
var
  s : string;
  ss: TKHexEditorSelection;
begin
  s := InputBox('Перейти по адресу','','');
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
    LogPrint('Было Sreg: '+IntToBin(sreg, 8));

    sreg := %10011100; //
    UsbAsp25_WREN(hUSBDev); //Включаем разрешение записи
    UsbAsp25_WriteSR(hUSBDev, sreg); //Устанавливаем регистр

    //Пока отлипнет ромка
    if UsbAsp25_Busy(hUSBDev) then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Exit;
    end;
    LogPrint('Стало Sreg: '+IntToBin(sreg, 8));
  end;



finally
  ExitProgMode25(hUSBdev);
  USB_Dev_Close(hUSBdev);
  UnlockControl();
end;

end;

procedure TMainForm.MenuItemReadSregClick(Sender: TObject);
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

  if ComboSPICMD.ItemIndex <> 2 then
  begin
    ButtonReadID.Enabled        := True;
    ButtonBlock.Enabled         := True;
  end else
  begin
    ButtonReadID.Enabled        := False;
    ButtonBlock.Enabled         := False;
  end;

  ButtonErase.Enabled         := True;

  ComboMWBitLen.Visible       := False;
  Label4.Visible              := False;
  Label5.Visible              := False;
  ComboAddrType.Visible       := False;

  ComboMWBitLen.Text:= 'MW addr len';
  ComboAddrType.Text:= '';
  ComboPageSize.Text:= 'Page size';
  ComboChipSize.Text:= 'Chip size';
end;

procedure TMainForm.ButtonWriteClick(Sender: TObject);
var
  PageSize: word;
  WriteType: byte;
begin
try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  if Sender <> ComboItem1 then
    if MessageDlg('AsProgrammer', 'Начать запись?', mtConfirmation, [mbYes, mbNo], 0)
      <> mrYes then Exit;
  LockControl();
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
    if UsbAspI2C_BUSY(hUSBdev, %10100000) then
    begin
      LogPrint('Линия занята', clRed);
      exit;
    end;
    TimeCounter := Time();

    RomF.Position := 0;
    KHexEditor.SaveToStream(RomF);
    RomF.Position := 0;

    if StrToInt(ComboPageSize.Text) < 1 then ComboPageSize.Text := '1';

    WriteFlashI2C(RomF, 0, KHexEditor.Data.Size, StrToInt(ComboPageSize.Text));

    if MenuAutoCheck.Checked then
    begin
      if UsbAspI2C_BUSY(hUSBdev, %10100000) then
      begin
        LogPrint('Линия занята', clRed);
        exit;
      end;
      TimeCounter := Time();

      RomF.Position :=0;
      KHexEditor.SaveToStream(RomF);
      RomF.Position :=0;
      VerifyFlashI2C(RomF, KHexEditor.Data.Size);
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

    WriteFlashMW(RomF, StrToInt(ComboMWBitLen.Text), 0, StrToInt(ComboChipSize.Text));

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
try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  LockControl();
  LogPrint(TimeToStr(Time()));
  if not IsNumber(ComboChipSize.Text) then
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
    TimeCounter := Time();

    RomF.Position :=0;
    KHexEditor.SaveToStream(RomF);
    RomF.Position :=0;

    if  ComboSPICMD.ItemIndex = SPI_CMD_KB then
      VerifyFlashKB(RomF, 0, KHexEditor.Data.Size);

    if ComboSPICMD.ItemIndex = SPI_CMD_25 then
      VerifyFlash25(RomF, 0, KHexEditor.Data.Size);

    if ComboSPICMD.ItemIndex = SPI_CMD_45 then
     begin
      if (not IsNumber(ComboPageSize.Text)) then
      begin
        LogPrint(STR_CHECK_SETTINGS, clRed);
        Exit;
      end;
      VerifyFlash45(RomF, 0, StrToInt(ComboPageSize.Text), KHexEditor.Data.Size);
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
    if UsbAspI2C_BUSY(hUSBdev, %10100000) then
    begin
      LogPrint('Линия занята', clRed);
      exit;
    end;
    TimeCounter := Time();

    RomF.Position :=0;
    KHexEditor.SaveToStream(RomF);
    RomF.Position :=0;
    VerifyFlashI2C(RomF, KHexEditor.Data.Size);
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

    RomF.Position :=0;
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
  sreg: byte;
  i: integer;
  s: string;
  SLreg: array[0..31] of byte;
begin
try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  sreg := 0;
  LockControl();
  if not SetSPISpeed(0) then exit;
  EnterProgMode25(hUSBdev);

  if ComboSPICMD.ItemIndex = SPI_CMD_25 then
  begin
    UsbAsp25_ReadSR(hUSBDev, sreg); //Читаем регистр
    LogPrint('Было Sreg: '+IntToBin(sreg, 8));

    sreg := 0; //
    UsbAsp25_WREN(hUSBDev); //Включаем разрешение записи
    UsbAsp25_WriteSR(hUSBDev, sreg); //Сбрасываем регистр

    //Пока отлипнет ромка
    if UsbAsp25_Busy(hUSBDev) then
    begin
      LogPrint(STR_USER_CANCEL, clRed);
      Exit;
    end;

    UsbAsp25_ReadSR(hUSBDev, sreg); //Читаем регистр
    LogPrint('Стало Sreg: '+IntToBin(sreg, 8));
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
    if UsbAsp45_isPagePowerOfTwo(hUSBDev) then LogPrint('Установлен размер страницы кратный двум!')
      else LogPrint('Установлен стандартный размер страницы');

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
  ID: array[0..2] of byte;
  ID90H: array[0..1] of byte;
  IDABH: array[0..2] of byte;
  IDstr: string[6];
  IDstr90H: string[4];
  IDstrABH: string[6];
  ChipName: string;
begin
  try
    if not OpenDevice() then exit;
    LockControl();
    FillByte(ID, 3, $FF);
    FillByte(ID90H, 2, $FF);
    FillByte(IDABH, 3, $FF);
    if not SetSPISpeed(0) then exit;

    EnterProgMode25(hUSBdev);
    UsbAsp25_ReadID(hUSBDev, ID);
    UsbAsp25_Read(hUSBDev, $90, 0, ID90H, 2); //SST
    UsbAsp25_Read(hUSBDev, $AB, 0, IDABH, 3); //SST
    ExitProgMode25(hUSBdev);

    USB_Dev_Close(hUSBdev);

    IDstr := Upcase(IntToHex(ID[0], 2)+IntToHex(ID[1], 2)+IntToHex(ID[2], 2));
    IDstr90H := Upcase(IntToHex(ID90H[0], 2)+IntToHex(ID90H[1], 2));
    IDstrABH := Upcase(IntToHex(IDABH[0], 2)+IntToHex(IDABH[1], 2)+IntToHex(IDABH[2], 2));

    if FileExists('chiplist.xml') then
    begin
      ReadXMLFile(XMLfile, 'chiplist.xml');
      ChipName := FindID(XMLfile, IDstr);
      if ChipName = '' then ChipName := FindID(XMLfile, IDstr90H);
      if ChipName = '' then ChipName := FindID(XMLfile, IDstrABH);

      //Если нет записи в cfg или считалась чушь
      if ChipName = '' then
      begin
        LogPrint('ID(9F): '+ IDstr +'(Неизвестно)');
        LogPrint('ID(90): '+ IDstr90H +'(Неизвестно)');
        LogPrint('ID(AB): '+ IDstrABH +'(Неизвестно)');
      end
      //Если есть
      else
      begin
        LogPrint('ID(9F): '+IDstr+'('+ChipName+')');
        LogPrint('ID(90): '+IDstr90H+'('+ChipName+')');
        LogPrint('ID(AB): '+IDstrABH+'('+ChipName+')');
      end;

    end;

    XMLfile.Free;
  finally
    UnlockControl();
  end;

end;

procedure TMainForm.ButtonOpenHexClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
   KHexEditor.LoadFromFile(UTF8ToSys(OpenDialog.FileName));
   StatusBar.Panels.Items[2].Text := OpenDialog.FileName;
  end;
end;

procedure TMainForm.ButtonSaveHexClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    KHexEditor.SaveToFile(UTF8ToSys(SaveDialog.FileName));
    StatusBar.Panels.Items[2].Text := SaveDialog.FileName;
  end;
end;

procedure TMainForm.ButtonCancelClick(Sender: TObject);
begin
  ButtonCancel.Tag:= 1;
end;

procedure LoadChipList;
var
  XMLfile: TXMLDocument;
  Node: TDOMNode;
  j, i: integer;
begin
  XMLfile := nil;
  if FileExists('chiplist.xml') then
  begin
    ReadXMLFile(XMLfile, 'chiplist.xml');
    Node := XMLfile.DocumentElement.FirstChild;

    while Assigned(Node) do
    begin

    MainForm.MenuChip.Add(NewItem(Node.NodeName,0, False, True, nil, 0, '')); //Раздел(SPI, I2C...)

     // Используем свойство ChildNodes
     with Node.ChildNodes do
     try
       for j := 0 to (Count - 1) do
       begin
         MainForm.MenuChip.Find(Node.NodeName).Add(NewItem(Item[j].NodeName,0, False, True, nil, 0, '')); //Раздел Фирма

         for i := 0 to (Item[j].ChildNodes.Count - 1) do
           MainForm.MenuChip.Find(Node.NodeName).
             Find(Item[j].NodeName).
               Add(NewItem(Item[j].ChildNodes.Item[i].NodeName,0, False, True, @MainForm.ChipClick, 0, '' )); //Чип
       end;
     finally
       Free;
     end;
     Node := Node.NextSibling;
    end;
  end;

  XMLfile.Free;
end;

{ TMainForm }

//Если хотим видить кириллицу в редакторе
//Еще нужно изменить в KHexEditor.pas строку
//TextOut(R.Left, R.Top + VTextIndent, Char(FCharMapping[FBuffer[Index]]));
//на
//TextOut(R.Left, R.Top + VTextIndent, SysToUTF8(Char(FCharMapping[FBuffer[Index]])));
function EditorCharMapping: TKEditCharMapping;
var
  I: Integer;
begin
  SetLength(Result, cCharMappingSize);
  for I := 0 to cCharMappingSize - 1 do
    if (I < $20) then
      Result[I] := '.'
    else
      Result[I] := AnsiChar(I);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //VID&PID UsBAsp'а
  DeviceDescription.idVENDOR:= $16C0;
  DeviceDescription.idPRODUCT:= $05DC;

  LoadChipList();
  RomF := TMemoryStream.Create;

  KHexEditor.SetCharMapping(EditorCharMapping());
  KHexEditor.ExecuteCommand(ecOverwriteMode);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  MainForm.KHexEditor.Free;
  RomF.Free;
end;

procedure TMainForm.ButtonReadClick(Sender: TObject);
begin
try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  LockControl();
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

    RomF.Position := 0;
    KHexEditor.LoadFromStream(RomF);
    StatusBar.Panels.Items[2].Text := 'EEPROM: '+ LabelChipName.Caption;
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
    if UsbAspI2C_BUSY(hUSBdev, %10100000) then
    begin
      LogPrint('Линия занята', clRed);
      exit;
    end;
    TimeCounter := Time();
    ReadFlashI2C(RomF, StrToInt(ComboChipSize.Text));

    RomF.Position := 0;
    KHexEditor.LoadFromStream(RomF);
    StatusBar.Panels.Items[2].Text := 'EEPROM: '+ LabelChipName.Caption;
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
    StatusBar.Panels.Items[2].Text := 'EEPROM: '+ LabelChipName.Caption;
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
begin
try
  ButtonCancel.Tag := 0;
  if not OpenDevice() then exit;
  if Sender <> ComboItem1 then
    if MessageDlg('AsProgrammer', 'Точно стереть чип?', mtConfirmation, [mbYes, mbNo], 0)
      <> mrYes then Exit;
  LockControl();
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


      if UsbAsp25_Busy(hUSBDev) then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Exit;
      end;
    end;

    if ComboSPICMD.ItemIndex = SPI_CMD_45 then
    begin
      UsbAsp45_ChipErase(hUSBdev);

      if UsbAsp45_Busy(hUSBDev) then
      begin
        LogPrint(STR_USER_CANCEL, clRed);
        Exit;
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
    if UsbAspI2C_BUSY(hUSBdev, %10100000) then
    begin
      LogPrint('Линия занята', clRed);
      exit;
    end;
    TimeCounter := Time();

    if StrToInt(ComboPageSize.Text) < 1 then ComboPageSize.Text := '1';

    EraseFlashI2C(0, StrToInt(ComboChipSize.Text), StrToInt(ComboPageSize.Text));
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

    while (UsbAspMW_Busy(hUSBdev)) do
    begin
       Application.ProcessMessages;
    end;
  end;


  LogPrint(STR_DONE);
  LogPrint(STR_TIME + TimeToStr(Time() - TimeCounter));

finally
  ExitProgMode25(hUSBdev);
  USB_Dev_Close(hUSBdev);
  UnlockControl();
end;
end;


procedure FindHEX(FindStr: string);
var
  SearchData: TKEditSearchData;
  S: string;
begin
 Exclude(SearchData.Options, esoFirstSearch);
 Exclude(SearchData.Options, esoBackwards);
 Exclude(SearchData.Options, esoSelectedOnly);

 Include(SearchData.Options, esoTreatAsDigits);
 Exclude(SearchData.Options, esoEntireScope);

 SearchData.TextToFind:=FindStr;

 MainForm.KHexEditor.ExecuteCommand(ecSearch, @SearchData);

  case SearchData.ErrorReason of
    eseNoMatch: S := 'Значение не найдено';
    eseNoDigitsFind: S := 'Укажите шестнадцатеричные числа';
    eseNoDigitsReplace: S := '';
  else
    S := '';
  end;

  if S <> '' then
    ShowMessage(PChar(S));
end;



end.

