unit search;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

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
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SearchForm: TSearchForm;

implementation

uses main, msgstr, KEditCommon;

{$R *.lfm}


{ TSearchForm }

procedure TSearchForm.FormCreate(Sender: TObject);
begin

end;

procedure TSearchForm.FindButtonClick(Sender: TObject);
var
  SearchData: TKEditSearchData;
  S: string;
begin


 Exclude(SearchData.Options, esoBackwards);
 Exclude(SearchData.Options, esoSelectedOnly);

 if ReplaceAllCheckBox.Checked then Include(SearchData.Options, esoAll) else
   Exclude(SearchData.Options, esoAll);

 if CaseSenseCheckBox.Checked then Include(SearchData.Options, esoMatchCase) else
   Exclude(SearchData.Options, esoMatchCase);

 if HexCheckBox.Checked then Include(SearchData.Options, esoTreatAsDigits) else
   Exclude(SearchData.Options, esoTreatAsDigits);

 if FromBeginingCheckBox.Checked then
   begin
     Include(SearchData.Options, esoFirstSearch);
     Include(SearchData.Options, esoEntireScope);
     FromBeginingCheckBox.Checked := false;
   end else
     Exclude(SearchData.Options, esoEntireScope);

 SearchData.TextToFind:= TextToFindEdit.Text;

 if ReplaceCheckBox.Checked then
 begin
   SearchData.TextToReplace:= ReplaceEdit.Text;
   MainForm.KHexEditor.ExecuteCommand(ecReplace, @SearchData);
 end else
   MainForm.KHexEditor.ExecuteCommand(ecSearch, @SearchData);

  case SearchData.ErrorReason of
    eseNoMatch: S := STR_NOT_FOUND_HEX;
    eseNoDigitsFind: S := STR_SPECIFY_HEX;
    eseNoDigitsReplace: S := '';
  else
    S := '';
  end;

  if S <> '' then
    ShowMessage(PChar(S));
end;

end.

