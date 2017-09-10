program AsProgrammer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, richmemopackage, kcontrolslaz, main, usbaspi2c, usbaspmw, usbaspmulti,
  usbasp95, search, sregedit, ch341mw, findchip, avrispmk2, ScriptEdit;

{$R *.res}

begin
  LoadXML;
  Translate(SettingsFile);
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSearchForm, SearchForm);
  Application.CreateForm(TsregeditForm, sregeditForm);
  Application.CreateForm(TChipSearchForm, ChipSearchForm);
  Application.CreateForm(TScriptEditForm, ScriptEditForm);
  Application.Run;
end.

