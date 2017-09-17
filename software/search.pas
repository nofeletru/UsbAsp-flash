unit search;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, utilfunc;

type

  { TSearchForm }

  TSearchForm = class(TForm)
    CaseSenseCheckBox: TCheckBox;
    ReplaceAllCheckBox: TCheckBox;
    ReplaceCheckBox: TCheckBox;
    ReplaceEdit: TEdit;
    FromBeginingCheckBox: TCheckBox;
    FindButton: TButton;
    HexCheckBox: TCheckBox;
    ReplaceLabel: TLabel;
    SearchLabel: TLabel;
    TextToFindEdit: TEdit;
    procedure FindButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SearchForm: TSearchForm;

implementation

uses main, msgstr;

{$R *.lfm}


{ TSearchForm }
procedure TSearchForm.FindButtonClick(Sender: TObject);
var
  s, r: PChar;
  shex, rhex: ansistring;
  FoundPosition, StrLen, RStrLen, SearchStartPos: integer;
  FirstSearch: boolean = true;
begin

 StrLen := Length(TextToFindEdit.Text);
 RStrLen := Length(ReplaceEdit.Text);
 if StrLen = 0 then Exit;

 s := PChar(MainForm.MPHexEditorEx.PrepareFindReplaceData(UTF8ToAnsi(TextToFindEdit.Text), not CaseSenseCheckBox.Checked, true));

 if HexCheckBox.Checked then
 begin
   StrLen := StrLen div 2;
   SetLength(shex, StrLen);
   HexTobin(s, PChar(shex), StrLen);
 end;

 if ((ReplaceCheckBox.Checked) or (ReplaceAllCheckBox.Checked)) then
 begin
   r := Pchar(UTF8ToAnsi(ReplaceEdit.Text));
   if HexCheckBox.Checked then
   begin
     RStrLen := RStrLen div 2;
     SetLength(rhex, RStrLen);
     if HexTobin(r, PChar(rhex), RStrLen) < 1 then Exit;
   end;
 end;

 if FromBeginingCheckBox.Checked then
   SearchStartPos := 0
 else
   SearchStartPos := MainForm.MPHexEditorEx.SelStart+1;

 repeat
   if HexCheckBox.Checked then
     FoundPosition := MainForm.MPHexEditorEx.Find(PChar(shex), StrLen, SearchStartPos, MainForm.MPHexEditorEx.DataSize-1, false)
   else
     FoundPosition := MainForm.MPHexEditorEx.Find(s, StrLen, SearchStartPos, MainForm.MPHexEditorEx.DataSize-1, not CaseSenseCheckBox.Checked);

   if FoundPosition >= 0 then
   begin
     FirstSearch := false;
     if not ReplaceAllCheckBox.Checked then
     begin
       MainForm.MPHexEditorEx.SelStart:= FoundPosition;
       MainForm.MPHexEditorEx.SelEnd:= FoundPosition+StrLen-1;
     end;
     SearchStartPos := FoundPosition+StrLen+1;
   end
   else
   begin
     if FirstSearch then ShowMessage(STR_NOT_FOUND_HEX);
     Exit;
   end;

   if ((ReplaceCheckBox.Checked) or (ReplaceAllCheckBox.Checked)) then
   begin
     if HexCheckBox.Checked then
       MainForm.MPHexEditorEx.Replace(PChar(rhex), FoundPosition, StrLen, RStrLen)
     else
       MainForm.MPHexEditorEx.Replace(r, FoundPosition, StrLen, RStrLen);
   end;
 until (not ReplaceAllCheckBox.Checked);

end;


end.

