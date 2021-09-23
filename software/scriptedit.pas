unit ScriptEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, Forms, Controls, StdCtrls,
  Graphics, Dialogs, Menus, lazUTF8,
  msgstr, scriptsfunc, usbhid;

type

  { TScriptEditForm }

  TScriptEditForm = class(TForm)
    MainMenu: TMainMenu;
    MenuItemScetionName: TMenuItem;
    MenuItemSaveAs: TMenuItem;
    MenuItemSection: TMenuItem;
    MenuItemRun: TMenuItem;
    MenuItemFile: TMenuItem;
    MenuItemOpen: TMenuItem;
    MenuItemSave: TMenuItem;
    OpenDialog: TOpenDialog;
    ScriptEditLog: TMemo;
    SaveDialog: TSaveDialog;
    SynEdit: TSynEdit;
    SynPasSyn: TSynPasSyn;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure MenuItemOpenClick(Sender: TObject);
    procedure MenuItemRunClick(Sender: TObject);
    procedure MenuItemSaveAsClick(Sender: TObject);
    procedure MenuItemSaveClick(Sender: TObject);
    procedure MenuItemSectionClick(Sender: TObject);
    procedure SectionItemMenuClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  procedure ScriptLogPrint(text: string);

var
  ScriptEditForm: TScriptEditForm;

implementation

uses main;

var
  CurrentSectionName: string;

{$R *.lfm}

{ TScriptEditForm }

procedure ScriptLogPrint(text: string);
begin
  ScriptEditForm.ScriptEditLog.Lines.Add(text);
end;

procedure TScriptEditForm.SectionItemMenuClick(Sender: TObject);
begin
  CurrentSectionName := TMenuItem(Sender).Caption;
  MenuItemScetionName.Caption:= CurrentSectionName;
end;

procedure FillScriptSection(ScriptText: TStrings);
var
  st, SectionName: string;
  i: integer;
  mi: TMenuItem;
begin
  ScriptEditForm.MenuItemSection.Clear;

  for i:= 0 to ScriptText.Count-1 do
  begin
    st := Trim(Upcase(ScriptText.Strings[i]));
    if Copy(st, 1, 2) = '{$' then
    begin
      SectionName := Trim(Copy(st, 3, pos('}', st)-3));
      if SectionName <> '' then
      begin
        mi := NewItem(SectionName, 0, false, true, @ScriptEditForm.SectionItemMenuClick, 0, '');
        mi.RadioItem:= true;
        mi.AutoCheck:= true;
        ScriptEditForm.MenuItemSection.Add(mi);
      end;
    end;
  end;

  mi := NewItem('-', 0, false, true, NIL, 0, '');
  ScriptEditForm.MenuItemSection.Add(mi);
end;

function SaveFile: boolean;
begin
  Result := false;

  with ScriptEditForm do
  begin

    if SaveDialog.FileName <> '' then
    begin
      SynEdit.Lines.SaveToFile(SaveDialog.FileName);
      SynEdit.Modified:= false;
      Result := true;
    end
    else
    begin
      SaveDialog.InitialDir:= GetCurrentDir+DirectorySeparator+ScriptsPath;
      if SaveDialog.Execute then
      begin
        SynEdit.Lines.SaveToFile(SaveDialog.FileName);
        SynEdit.Modified:= false;
        Result := true;
      end;
    end;

  end;

end;

procedure TScriptEditForm.FormShow(Sender: TObject);
var
  ScriptFileName: string;
begin
  ScriptFileName := ScriptsPath + CurrentICParam.Script;
  SaveDialog.FileName:= '';

  if FileExists(ScriptFileName) then
  begin
    SynEdit.Lines.LoadFromFile(ScriptFileName);
    SaveDialog.FileName:= ScriptFileName;
    FillScriptSection(SynEdit.Lines);
  end;
end;

procedure TScriptEditForm.MenuItemOpenClick(Sender: TObject);
begin
  OpenDialog.InitialDir:= GetCurrentDir+DirectorySeparator+ScriptsPath;
  if OpenDialog.Execute then
  begin
    SynEdit.Lines.LoadFromFile(OpenDialog.FileName);
    SaveDialog.FileName:= OpenDialog.FileName;
    FillScriptSection(SynEdit.Lines);
  end;
end;

procedure TScriptEditForm.MenuItemSaveAsClick(Sender: TObject);
begin
  SaveDialog.InitialDir:= GetCurrentDir+DirectorySeparator+ScriptsPath;
  if SaveDialog.Execute then
  begin
    SynEdit.Lines.SaveToFile(SaveDialog.FileName);
    SynEdit.Modified:= false;
  end;
end;

procedure TScriptEditForm.MenuItemSaveClick(Sender: TObject);
begin
  SaveFile();
end;

procedure TScriptEditForm.MenuItemSectionClick(Sender: TObject);
begin
  FillScriptSection(SynEdit.Lines);
end;

procedure TScriptEditForm.FormCloseQuery(Sender: TObject; var CanClose: boolean
  );
begin
  if SynEdit.Modified then
    case QuestionDlg(STR_DLG_FILECHGD, STR_DLG_SAVEFILE, mtConfirmation, [mrYes, mrNo, mrCancel],0) of
      mrYes: if not SaveFile() then CanClose := false;
      mrCancel: CanClose := false;
    end;
end;

procedure TScriptEditForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  SynEdit.Clear;
  SynEdit.Modified:= false;
  ScriptEditForm.MenuItemScetionName.Caption:= '';
end;

procedure TScriptEditForm.MenuItemRunClick(Sender: TObject);
var
  ScriptText: TStrings;
begin
  try
    ScriptText := TStringList.Create;
    if ParseScriptText(SynEdit.Lines, CurrentSectionName, ScriptText) then
    begin
      ScriptLogPrint(STR_SCRIPT_RUN_SECTION+CurrentSectionName);
      if not OpenDevice() then exit;
      RunScript(ScriptText);
      AsProgrammer.Programmer.DevClose;
    end
    else
      if CurrentSectionName = '' then
        ScriptLogPrint(STR_SCRIPT_SEL_SECTION+CurrentSectionName)
          else ScriptLogPrint(STR_SCRIPT_NO_SECTION+CurrentSectionName);
  finally
    ScriptText.Free;
  end;
end;

end.

