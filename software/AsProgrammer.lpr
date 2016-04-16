program AsProgrammer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, richmemopackage, kcontrolslaz, main, usbaspi2c, usbaspmw, usbaspmulti,
  usbasp95;

{$R *.res}

begin
  Translate;
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

