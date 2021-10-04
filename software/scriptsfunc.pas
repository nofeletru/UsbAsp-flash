unit scriptsfunc;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, Variants, Dialogs, graphics, BaseHW,
  spi25, msgstr, PasCalc, pasfunc;

procedure SetScriptFunctions(PC : TPasCalc);
procedure SetScriptVars();
procedure RunScript(ScriptText: TStrings);
function RunScriptFromFile(ScriptFile: string; Section: string): boolean;
function ParseScriptText(Script: TStrings; SectionName: string; var ScriptText: TStrings ): Boolean;
function GetScriptSectionsFromFile(ScriptFile: string): TStrings;

implementation

uses main, scriptedit;

const _SPI_SPEED_MAX = 255;


function GetScriptSectionsFromFile(ScriptFile: string): TStrings;
var
  st, SectionName: string;
  i: integer;
  ScriptText: TStrings;
begin
  if not FileExists(ScriptsPath+ScriptFile) then Exit;

  Result:= TStringList.Create;
  ScriptText:= TStringList.Create;

  ScriptText.LoadFromFile(ScriptsPath+ScriptFile);

  for i:= 0 to ScriptText.Count-1 do
  begin
    st := Trim(Upcase(ScriptText.Strings[i]));
    if Copy(st, 1, 2) = '{$' then
    begin
      SectionName := Trim(Copy(st, 3, pos('}', st)-3));
      if SectionName <> '' then
      begin
        Result.Add(SectionName);
      end;
    end;
  end;

end;

{Возвращает текст выбранной секции
 Если секция не найдена возвращает false}
function ParseScriptText(Script: TStrings; SectionName: string; var ScriptText: TStrings ): Boolean;
var
  st: string;
  i: integer;
  s: boolean;
begin
  Result := false;
  s:= false;

  for i:=0 to Script.Count-1 do
  begin
    st:= Script.Strings[i];

    if s then
    begin
      if Trim(Copy(st, 1, 2)) = '{$' then break;
      ScriptText.Append(st);
    end
    else
    begin
      st:= StringReplace(st, ' ', '', [rfReplaceAll]);
      if Pos('{$' + Upcase(SectionName) + '}', Upcase(st)) <> 0 then
      //if Upcase(st) = '{$' + Upcase(SectionName) + '}' then
      begin
        s := true;
        Result := true;
      end;
    end;

  end;
end;

//Выполняет скрипт
procedure RunScript(ScriptText: TStrings);
var
  TimeCounter: TDateTime;
begin
  LogPrint(TimeToStr(Time()));
  TimeCounter := Time();
  MainForm.Log.Append(STR_USING_SCRIPT + CurrentICParam.Script);

  RomF.Clear;

  //Предопределяем переменные
  ScriptEngine.ClearVars;
  SyncUI_ICParam();
  SetScriptVars();

  MainForm.StatusBar.Panels.Items[2].Text := CurrentICParam.Name;
  ScriptEngine.Execute(ScriptText.Text);

  if ScriptEngine.ErrCode<>0 then
  begin
    if not ScriptEditForm.Visible then
    begin
      LogPrint(ScriptEngine.ErrMsg);
      LogPrint(ScriptEngine.ErrLine);
    end
    else
    begin
      ScriptLogPrint(ScriptEngine.ErrMsg);
      ScriptLogPrint(ScriptEngine.ErrLine);
    end;
  end;

  LogPrint(STR_TIME + TimeToStr(Time() - TimeCounter));
end;

{Выполняет секцию скрипта из файла
 Если файл или секция отсутствует то возвращает false}
function RunScriptFromFile(ScriptFile: string; Section: string): boolean;
var
  ScriptText, ParsedScriptText: TStrings;
begin
  if not FileExists(ScriptsPath+ScriptFile) then Exit(false);
  try
    ScriptText:= TStringList.Create;
    ParsedScriptText:= TStringList.Create;

    ScriptText.LoadFromFile(ScriptsPath+ScriptFile);
    if not ParseScriptText(ScriptText, Section, ParsedScriptText) then Exit(false);
    RunScript(ParsedScriptText);
    Result := true;
  finally
    ScriptText.Free;
    ParsedScriptText.Free;
  end;
end;

function VarIsString(V : TVar) : boolean;
var t: integer;
begin
  t := VarType(V.Value);
  Result := (t=varString) or (t=varOleStr);
end;

//------------------------------------------------------------------------------

{Script Delay(ms: WORD);
 Останавливает выполнение скрипта на ms миллисекунд
}
function Script_Delay(Sender:TObject; var A:TVarList): boolean;
begin
  if A.Count < 1 then Exit(false);
  Sleep(TPVar(A.Items[0])^.Value);
  Result := true;
end;

{Script ShowMessage(text);
 Аналог ShowMessage}
function Script_ShowMessage(Sender:TObject; var A:TVarList) : boolean;
var s: string;
begin
  if A.Count < 1 then Exit(false);

  s := TPVar(A.Items[0])^.Value;
  ShowMessage(s);
  Result := true;
end;

{Script InputBox(Captiontext, Prompttext, Defaulttext): value;
 Аналог InputBox}
function Script_InputBox(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  if A.Count < 3 then Exit(false);

  R.Value := InputBox(TPVar(A.Items[0])^.Value, TPVar(A.Items[1])^.Value, TPVar(A.Items[2])^.Value);

  Result := true;
end;

{Script LogPrint(text);
 Выводит сообщение в лог
 Параметры:
   text текст сообщения}
function Script_LogPrint(Sender:TObject; var A:TVarList) : boolean;
var
  s: string;
begin
  if A.Count < 1 then Exit(false);

  s := TPVar(A.Items[0])^.Value;
  LogPrint('Script: ' + s);
  Result := true;
end;

{Script CreateByteArray(size): variant;
 Создает массив с типом элементов varbyte}
function Script_CreateByteArray(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  if A.Count < 1 then Exit(false);
  R.Value := VarArrayCreate([0, TPVar(A.Items[0])^.Value - 1], varByte);
  Result := true;
end;

{Script GetArrayItem(array, index): variant;
 Возвращает значение элемента массива}
function Script_GetArrayItem(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  if (A.Count < 2) or (not VarIsArray(TPVar(A.Items[0])^.Value)) then Exit(false);
  R.Value := TPVar(A.Items[0])^.Value[TPVar(A.Items[1])^.Value];
  Result := true;
end;

{Script SetArrayItem(array, index, value);
 Устанавливает значение элемента массива}
function Script_SetArrayItem(Sender:TObject; var A:TVarList) : boolean;
begin
  if (A.Count < 3) or (not VarIsArray(TPVar(A.Items[0])^.Value)) then Exit(false);
  TPVar(A.Items[0])^.Value[TPVar(A.Items[1])^.Value] := TPVar(A.Items[2])^.Value;
  Result := true;
end;

{Script IntToHex(value, digits): string;
 Аналог IntToHex}
function Script_IntToHex(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  if A.Count < 2 then Exit(false);

  R.Value:= IntToHex(Int64(TPVar(A.Items[0])^.Value), TPVar(A.Items[1])^.Value);
  Result := true;
end;

{Script SPIEnterProgMode(speed): boolean;
 Инициализирует состояние пинов для SPI и устанавливает частоту SPI
 Если частота не установлена возвращает false
 Игнорируется для CH341}
function Script_SPIEnterProgMode(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var speed: byte;
begin
  if A.Count < 1 then Exit(false);

  speed := TPVar(A.Items[0])^.Value;
  if speed = _SPI_SPEED_MAX then speed := 13;
  if EnterProgMode25(SetSPISpeed(speed)) then
    R.Value := True
  else
    R.Value := False;
  Result := true;
end;

{Script SPIExitProgMode();
 Отключает пины SPI}
function Script_SPIExitProgMode(Sender:TObject; var A:TVarList) : boolean;
begin
  ExitProgMode25;
  Result := true;
end;

{Script ProgressBar(inc, max, pos);
 Устанавливает состояние ProgressBar
 Параметры:
   inc насколько увиличить позицию
 Необязательные параметры:
   max максимальная позиция ProgressBar
   pos устанавливает конкретную позицию ProgressBar}
function Script_ProgressBar(Sender:TObject; var A:TVarList) : boolean;
begin

  if A.Count < 1 then Exit(false);

  MainForm.ProgressBar.Position := MainForm.ProgressBar.Position + TPVar(A.Items[0])^.Value;

  if A.Count > 1 then
    MainForm.ProgressBar.Max := TPVar(A.Items[1])^.Value;
  if A.Count > 2 then
    MainForm.ProgressBar.Position := TPVar(A.Items[2])^.Value;

  Result := true;
end;

{Script SPIRead(cs, size, buffer..): integer;
 Читает данные в буфер
 Параметры:
   cs если cs=1 отпускать Chip Select после чтения данных
   size размер данных в байтах
   buffer переменные для хранения данных или массив созданный CreateByteArray
 Возвращает количество прочитанных байт}
function Script_SPIRead(Sender:TObject; var A:TVarList; var R: TVar) : boolean;
var
  i, size, cs: integer;
  DataArr: array of byte;
begin

  if A.Count < 3 then Exit(false);

  cs := TPVar(A.Items[0])^.Value;
  size := TPVar(A.Items[1])^.Value;

  SetLength(DataArr, size);

  R.Value := SPIRead(cs, size, DataArr[0]);

  //Если buffer массив
  if (VarIsArray(TPVar(A.Items[2])^.Value)) then
  for i := 0 to size-1 do
  begin
    TPVar(A.Items[2])^.Value[i] := DataArr[i];
  end
  else
  for i := 0 to size-1 do
  begin
    TPVar(A.Items[i+2])^.Value := DataArr[i];
  end;

  Result := true;
end;

{Script SPIWrite(cs, size, buffer..): integer;
 Записывает данные из буфера
 Параметры:
   cs если cs=1 отпускать Chip Select после записи данных
   size размер данных в байтах
   buffer переменные для хранения данных или массив созданный CreateByteArray
 Возвращает количество записанных байт}
function Script_SPIWrite(Sender:TObject; var A:TVarList; var R: TVar) : boolean;
var
  i, size, cs: integer;
  DataArr: array of byte;
begin

  if A.Count < 3 then Exit(false);

  size := TPVar(A.Items[1])^.Value;
  cs := TPVar(A.Items[0])^.Value;
  SetLength(DataArr, size);

  //Если buffer массив
  if (VarIsArray(TPVar(A.Items[2])^.Value)) then
  for i := 0 to size-1 do
  begin
    DataArr[i] := TPVar(A.Items[2])^.Value[i];
  end
  else
  for i := 0 to size-1 do
  begin
    DataArr[i] := TPVar(A.Items[i+2])^.Value;
  end;

  R.Value := SPIWrite(cs, size, DataArr);
  Result := true;
end;

{Script SPIReadToEditor(cs, size): integer;
 Читает данные в редактор
 Параметры:
   cs если cs=1 отпускать Chip Select после чтения данных
   size размер данных в байтах
 Возвращает количество прочитанных байт}
function Script_SPIReadToEditor(Sender:TObject; var A:TVarList; var R: TVar) : boolean;
var
  DataArr: array of byte;
  BufferLen: integer;
begin

  if A.Count < 2 then Exit(false);

  BufferLen := TPVar(A.Items[1])^.Value;
  SetLength(DataArr, BufferLen);

  R.Value := SPIRead(TPVar(A.Items[0])^.Value, BufferLen, DataArr[0]);

  RomF.WriteBuffer(DataArr[0], BufferLen);
  RomF.Position := 0;
  MainForm.MPHexEditorEx.LoadFromStream(RomF);
  Result := true;
end;

{Script SPIWriteFromEditor(cs, size, position): integer;
 Записывает данные из редактора размером size с позиции position
 Параметры:
   cs если cs=1 отпускать Chip Select после записи данных
   size размер данных в байтах
   position позиция в редакторе
 Возвращает количество записанных байт}
function Script_SPIWriteFromEditor(Sender:TObject; var A:TVarList; var R: TVar) : boolean;
var
  DataArr: array of byte;
  BufferLen: integer;
begin

  if A.Count < 3 then Exit(false);

  BufferLen := TPVar(A.Items[1])^.Value;
  SetLength(DataArr, BufferLen);

  RomF.Clear;
  MainForm.MPHexEditorEx.SaveToStream(RomF);
  RomF.Position := TPVar(A.Items[2])^.Value;
  RomF.ReadBuffer(DataArr[0], BufferLen);

  R.Value := SPIWrite(TPVar(A.Items[0])^.Value, BufferLen, DataArr);

  Result := true;
end;

//I2C---------------------------------------------------------------------------

{Script I2CEnterProgMode;
 Инициализирует состояние пинов}
function Script_I2CEnterProgMode(Sender:TObject; var A:TVarList) : boolean;
begin
  Asprogrammer.Programmer.I2CInit;
  Result := true;
end;

{Script I2cExitProgMode();
 Отключает пины}
function Script_I2CExitProgMode(Sender:TObject; var A:TVarList) : boolean;
begin
  Asprogrammer.Programmer.I2CDeinit;
  Result := true;
end;

{Script I2CReadWrite(DevAddr, wsize, rsize, wbuffer.., rbuffer...): integer;
 Записывает данные из буфера
 Параметры:
   DevAddr адрес устройства
   size размер данных в байтах
   buffer переменные для хранения данных или массив созданный CreateByteArray
 Возвращает количество записанных + прочитанных байт}
function Script_I2CReadWrite(Sender:TObject; var A:TVarList; var R: TVar) : boolean;
var
  i, rsize, wsize: integer;
  WDataArr, RDataArr: array of byte;
  DevAddr: byte;
begin

  if A.Count < 4 then Exit(false);

  DevAddr := TPVar(A.Items[0])^.Value;
  wsize := TPVar(A.Items[1])^.Value;
  if wsize < 1 then Exit(false);
  rsize := TPVar(A.Items[2])^.Value;
  SetLength(WDataArr, wsize);
  SetLength(RDataArr, rsize);

  //Если wbuffer массив
  if (VarIsArray(TPVar(A.Items[3])^.Value)) then
  for i := 0 to wsize-1 do
  begin
    WDataArr[i] := TPVar(A.Items[3])^.Value[i];
  end
  else
  for i := 0 to wsize-1 do
  begin
    WDataArr[i] := TPVar(A.Items[i+3])^.Value;
  end;

  R.Value := AsProgrammer.Programmer.I2CReadWrite(DevAddr, wsize, WDataArr, rsize, RDataArr);

  if rsize < 1 then Exit(true);

  if (VarIsArray(TPVar(A.Items[3])^.Value)) then wsize := 1;
  //Если rbuffer массив
  if (VarIsArray(TPVar(A.Items[wsize+3])^.Value)) then
  for i := 0 to rsize-1 do
  begin
    TPVar(A.Items[wsize+3])^.Value[i] := RDataArr[i];
  end
  else
  for i := 0 to rsize-1 do
  begin
    TPVar(A.Items[i+wsize+3])^.Value := RDataArr[i];
  end;

  Result := true;
end;

{Script I2CStart;
  Используется вместе с I2CWriteByte, I2CReadByte
 }
function Script_I2CStart(Sender:TObject) : boolean;
begin
  AsProgrammer.Programmer.I2CStart;
  result := true;
end;

{Script I2CStop;
  Используется вместе с I2CWriteByte, I2CReadByte
 }
function Script_I2CStop(Sender:TObject) : boolean;
begin
  AsProgrammer.Programmer.I2CStop;
  result := true;
end;

{Script I2CWriteByte(data): boolean;
 Возвращает ack/nack
 Параметры:
   data байт данных для записи
   Возвращает ack/nack}
function Script_I2CWriteByte(Sender:TObject; var A:TVarList; var R: TVar) : boolean;
begin
  if A.Count < 1 then Exit(false);

  R.Value := AsProgrammer.Programmer.I2CWriteByte(TPVar(A.Items[0])^.Value);
  result := true;
end;

{Script I2CReadByte(ack: boolean): data;
 Возвращает байт данных
 Параметры:
   ack ack/nack
   Возвращает байт прочитаных данных}
function Script_I2CReadByte(Sender:TObject; var A:TVarList; var R: TVar) : boolean;
begin
  if A.Count < 1 then Exit(false);

  R.Value := AsProgrammer.Programmer.I2CReadByte(TPVar(A.Items[0])^.Value);
  result := true;
end;

{Script ReadToEditor(size, position, buffer...);
 Записывает данные из буфера в редактор
 Параметры:
   size размер данных в байтах
   position позиция в редакторе
   buffer переменные для хранения данных или массив созданный CreateByteArray}
function Script_ReadToEditor(Sender:TObject; var A:TVarList) : boolean;
var
  DataArr: array of byte;
  size, i: integer;
begin

  if A.Count < 3 then Exit(false);

  size := TPVar(A.Items[0])^.Value;
  if size < 1 then Exit(false);
  if TPVar(A.Items[1])^.Value < 0 then Exit(false);
  SetLength(DataArr, size);

  //Если buffer массив
  if (VarIsArray(TPVar(A.Items[2])^.Value)) then
  for i := 0 to size-1 do
  begin
    DataArr[i] := TPVar(A.Items[2])^.Value[i];
  end
  else
  for i := 0 to size-1 do
  begin
    DataArr[i] := TPVar(A.Items[i+2])^.Value;
  end;

  MainForm.MPHexEditorEx.SaveToStream(RomF);
  RomF.Position := TPVar(A.Items[1])^.Value;

  RomF.WriteBuffer(DataArr[0], size);

  RomF.Position := 0;
  MainForm.MPHexEditorEx.LoadFromStream(RomF);

  Result := true;
end;

{Script WriteFromEditor(size, position, buffer...);
 Записывает данные из редактора размером size с позиции position
 Параметры:
   size размер данных в байтах
   position позиция в редакторе
   buffer переменные для хранения данных или массив созданный CreateByteArray}
function Script_WriteFromEditor(Sender:TObject; var A:TVarList) : boolean;
var
  DataArr: array of byte;
  size, i: integer;
begin

  if A.Count < 3 then Exit(false);

  size := TPVar(A.Items[0])^.Value;
   if size < 1 then Exit(false);
  SetLength(DataArr, size);

  RomF.Clear;
  MainForm.MPHexEditorEx.SaveToStream(RomF);
  RomF.Position := TPVar(A.Items[1])^.Value;
  RomF.ReadBuffer(DataArr[0], size);

  //Если buffer массив
  if (VarIsArray(TPVar(A.Items[2])^.Value)) then
  for i := 0 to size-1 do
  begin
    TPVar(A.Items[2])^.Value[i] := DataArr[i];
  end
  else
  for i := 0 to size-1 do
  begin
    TPVar(A.Items[i+2])^.Value := DataArr[i];
  end;

  Result := true;
end;

{Script GetEditorDataSize: Longword;
 Возвращает размер данных в редакторе
 }
function Script_GetEditorDataSize(Sender:TObject; var A:TVarList; var R: TVar) : boolean;
begin
  R.Value := MainForm.MPHexEditorEx.DataSize;
  result := true;
end;


//------------------------------------------------------------------------------
procedure SetScriptFunctions(PC : TPasCalc);
begin
  PC.SetFunction('Delay', @Script_Delay);
  PC.SetFunction('ShowMessage', @Script_ShowMessage);
  PC.SetFunction('InputBox', @Script_InputBox);
  PC.SetFunction('LogPrint', @Script_LogPrint);
  PC.SetFunction('ProgressBar', @Script_ProgressBar);
  PC.SetFunction('IntToHex', @Script_IntToHex);

  PC.SetFunction('ReadToEditor', @Script_ReadToEditor);
  PC.SetFunction('WriteFromEditor', @Script_WriteFromEditor);
  PC.SetFunction('GetEditorDataSize', @Script_GetEditorDataSize);

  PC.SetFunction('CreateByteArray', @Script_CreateByteArray);
  PC.SetFunction('GetArrayItem', @Script_GetArrayItem);
  PC.SetFunction('SetArrayItem', @Script_SetArrayItem);

  PC.SetFunction('SPIEnterProgMode', @Script_SPIEnterProgMode);
  PC.SetFunction('SPIExitProgMode', @Script_SPIExitProgMode);
  PC.SetFunction('SPIRead', @Script_SPIRead);
  PC.SetFunction('SPIWrite', @Script_SPIWrite);
  PC.SetFunction('SPIReadToEditor', @Script_SPIReadToEditor);
  PC.SetFunction('SPIWriteFromEditor', @Script_SPIWriteFromEditor);

  PC.SetFunction('I2CEnterProgMode', @Script_I2CEnterProgMode);
  PC.SetFunction('I2CExitProgMode', @Script_I2CExitProgMode);
  PC.SetFunction('I2CReadWrite', @Script_I2CReadWrite);
  PC.SetFunction('I2CStart', @Script_I2CStart);
  PC.SetFunction('I2CStop', @Script_I2CStop);
  PC.SetFunction('I2CWriteByte', @Script_I2CWriteByte);
  PC.SetFunction('I2CReadByte', @Script_I2CReadByte);

  SetFunctions(PC);
end;

procedure SetScriptVars();
begin
  ScriptEngine.SetValue('_IC_Name', CurrentICParam.Name);
  ScriptEngine.SetValue('_IC_Size', CurrentICParam.Size);
  ScriptEngine.SetValue('_IC_Page', CurrentICParam.Page);
  ScriptEngine.SetValue('_IC_SpiCmd', CurrentICParam.SpiCmd);
  ScriptEngine.SetValue('_IC_MWAddrLen', CurrentICParam.MWAddLen);
  ScriptEngine.SetValue('_IC_I2CAddrType', CurrentICParam.I2CAddrType);
  ScriptEngine.SetValue('_SPI_SPEED_MAX', _SPI_SPEED_MAX);
end;

end.

