program AsProgrammer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, richmemopackage, kcontrolslaz, main, usbaspi2c, usbaspmw, usbaspmulti,
  usbasp95, search, sregedit, ch341mw;

{$R *.res}

begin
  LoadXML;
  Translate(ChipListFile);
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSearchForm, SearchForm);
  Application.CreateForm(TsregeditForm, sregeditForm);
  Application.Run;
end.

