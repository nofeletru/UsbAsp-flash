{PASCALC v 3.00 source}

unit pascalc;

{$B-,R-}
{$mode delphi}

interface

uses
  LCLType, SysUtils, Classes, Math, Variants, forms;

const _pascalc : string = #10#10+
  '*************************************************'#10+
  '*      PASCALC interpreter v3.00 for Delphi     *'#10+
  '*    (c)2000 Alex Boiko  alexboiko@mtu-net.ru   *'#10+
  '*            http://alexboiko.da.ru             *'#10+
  '*************************************************'#10#10;
  //tifa: добавлена работа с hex константами($FF $FA)
  //tifa: кроссплатформенные правки

type TToken =
  (tEMPTY,    tVR,       tCON,      tTRUE,     tFALSE,
   tEQU,      tOR,       tAND,      tNOT,      tXOR,
   tCOMMA,    tLBL,      tNEQ,      tGT,       tLS,
   tGTE,      tLSE,      tADD,      tSUB,      tMUL,
   tDIV,      tPWR,      tLBR,      tRBR,      tLARR,
   tRARR,     tSEMI,     tREM,      tREMB,     tREME,
   tASSIGN,   tBEGIN,    tEND,      tIF,       tTHEN,
   tELSE,     tFOR,      tTO,       tDOWNTO,   tDO,
   tWHILE,    tREPEAT,   tUNTIL,    tBREAK,    tCONTINUE,
   tEXIT,     tGOTO,     tSHL,      tSHR,      tPROC,
   tFUNCT,    tUSES,     tINCLUDE,  tCASE,     tOF,
   tCOMMA2);

type TTokenSet = set of TToken;

const
  ResWords : array[TToken] of string[10] =
   ('',         '',         '',         'TRUE',     'FALSE',
    '=',        'OR',       'AND',      'NOT',      'XOR',
    ',',        ':',        '<>',       '>',        '<',
    '>=',       '<=',       '+',        '-',        '*',
    '/',        '^',        '(',        ')',        '[',
    ']',        ';',        '//',       '{',        '}',
    ':=',       'BEGIN',    'END',      'IF',       'THEN',
    'ELSE',     'FOR',      'TO',       'DOWNTO',   'DO',
    'WHILE',    'REPEAT',   'UNTIL',    'BREAK',    'CONTINUE',
    'EXIT',     'GOTO',     'SHL',      'SHR',      'PROCEDURE',
    'FUNCTION', 'USES',     'INCLUDE',  'CASE',     'OF',
    '..');

const
  Alpha          : set of char = ['_','0'..'9','a'..'z','A'..'Z','а'..'я','ё','А'..'Я','Ё'];
  StrDelimiter   : char = '''';
  DecimalPoint   : char = '.';
  TokenDelimiter : char = #127;


type TVar = record
  Name  : string;
  Value : variant;
end;

type TPVar = ^TVar;

type TVarList = class (TList)
  destructor Destroy; override;
  procedure  ClearAll;
  function   AddVar(V:TVar) : boolean;
  function   AddValue(N:string; V:variant) : boolean;
  function   VarExist(N:string):boolean;
  function   VarIndex(N:string):integer;
  function   VarByName(N:string;var V:TVar) : boolean;
  function   SetVar(V:TVar) : boolean;
  function   SetValue(N:string; V:variant) : boolean;
  procedure  CopyTo(VL:TVarList);
end;

type TPVarList = ^TVarList;

type PProcessProc = procedure;

type PFunction = function(Sender:TObject; var A:TVarList; var R:TVar) : boolean;

type TFunc = record
  Name : string;
  Func : Pointer;
end;

type TPFunc = ^TFunc;

type TFuncList = class (TList)
  destructor Destroy; override;
  procedure  ClearAll;
  function   AddFunction(N:string; F:Pointer) : boolean;
end;

type TProcedure = record
  Name   : string;
  Body   : string;
  Params : string;
  Result : boolean;
end;

type TPProcedure = ^TProcedure;

type TProcList = class(TList)
  destructor Destroy; override;
  procedure  ClearAll;
  function   AddProc(Proc:TProcedure):boolean;
  function   ProcIndex(Name:string):integer;
  function   ProcByName(Name:string; var Proc:TProcedure):boolean;
end;


type TPasCalc = class
  constructor Create;
  destructor  Destroy; override;
  procedure   ClearVars;
  function    VarCount : integer;
  function    VarIndex(N:string) : integer;
  function    VarByName(N:string; var V:TVar) : boolean;
  function    VarByIndex(I:integer; var V:TVar) : boolean;
  function    SetVar(V:TVar) : boolean;
  function    SetValue(N:string; V:variant):boolean;
  procedure   ClearFuncs;
  function    SetFunction(N:string; F:Pointer) : boolean;
  procedure   SetProcessProc(P:Pointer);
  function    Parse(S:string) : string;
  function    Calculate(S:string; var R:TVar) : boolean;
  function    Execute(S:string):boolean;
  private
    Expr        : string;
    ExprIndex   : integer;
    Token       : string;
    TokenCode   : TToken;

    BlockLevel  : integer;
    BlockCmd    : TToken;
    GotoLabel   : string;

    VarList     : TVarList;
    FuncList    : TFuncList;
    ProcList    : TProcList;

    ProcessProc : PProcessProc;

    LastString  : string;
    LastParsed  : string;

    procedure Clear;
    procedure Process;
    procedure Error(Msg,Line:string; Code:integer);
    procedure Level1(var R:TVar);
    procedure Level2(var R:TVar);
    procedure Level3(var R:TVar);
    procedure Level4(var R:TVar);
    procedure Level5(var R:TVar);
    procedure Level6(var R:TVar);
    procedure Level7(var R:TVar);
    procedure Level8(var R:TVar);
    procedure Arith(o : TToken; var R,H:TVar);
    procedure Unary(o : TToken; var R:TVar);
    function  GetIndex(S:string; var Index:integer; var T:TToken) : string;
    function  GetFuncParams(S:string; var Index:integer) : string;
    function  FindFunc(N:string) : integer;
    function  FindArray(N:string) : boolean;
    procedure SetVarDirect(var R:TVar);
    function  CallFunc(N:string; A:string; var V:TVar) : boolean;
    function  CallProc(N:string; A:string; var V:TVar) : boolean;
    function  GetTextToken(S: string; var Index : integer; var Code : TToken) : string;
    function  TokenStr(T:TToken;S:string) : string;
    function  GetToken(S:string; var Index : integer; var Code : TToken) : string;
    function  GetTokenCode(S: string; var Index:integer; var Code:TToken) : integer;
    function  GetTokenLine(S:string; var Index:integer; var Code:TToken;
                           StopToken:TTokenSet) : string;
    function  NextToken(S:string; Index:integer) : TToken;
    function  GetOperator(Txt:string; var Index : integer; EndToken:TTokenSet) : string;
    function  ParseOperator(Txt:string; var Cmd,Line,Lbl : string) : TToken;
    function  DelRemarks(S:string) : string;
    function  UnParse(S:string; Show:boolean) : string;
    function  PreProcess(Txt:string):string;
    function  Calc(S:string; var R:TVar) : boolean;
    procedure Exec(Txt:string);
    procedure DoSet(CmdLine,Cmd,Line:string);
    procedure DoIf(CmdLine,Line:string);
    procedure DoBegin(CmdLine,Line:string);
    procedure DoFor(CmdLine,Line:string);
    procedure DoBreak(CmdLine,Line:string);
    procedure DoContinue(CmdLine,Line:string);
    procedure DoExit(CmdLine,Line:string);
    procedure DoWhile(CmdLine,Line:string);
    procedure DoRepeat(CmdLine,Line:string);
    procedure DoGoto(CmdLine,Line:string);
    procedure DoCase(CmdLine,Line:string);
  public
    Stop     : boolean;
    ErrCode  : integer;
    ErrMsg   : string;
    ErrLine  : string;
  end;

implementation

const
  SpaceSet : set of char = [' ',#9,#10,#13];

const
  errOK            = 0;  // O.K.
  errExprSyntax    = 1;  // Error in expression/statement
  errParentheses   = 2;  // Unpaired parentheses
  errVarNotFound   = 3;  // Variable not found
  errInvalidName   = 4;  // Invalid variable/function/procedure name
  errTypeCast      = 5;  // Invalid typecast
  errString        = 6;  // Invalid string constant
  errCall          = 7;  // Invalid function call
  errFuncNotFound  = 8;  // Function not found
  errInvalidOp     = 9;  // Invalid operator
  errEndExpected   = 10; // END expected
  errManyEnd       = 11; // Too many END
  errToExpected    = 12; // TO or DOWNTO expected
  errForVar        = 13; // FOR-loop variable expected
  errDoExpected    = 14; // DO expected
  errBreak         = 15; // BREAK/CONTINUE outside a loop
  errUntilExpected = 16; // UNTIL expected
  errManyUntil     = 17; // Too many UNTIL
  errLabelNotFound = 18; // Label not found
  errIndexRange    = 19; // Index out of range
  errValueRange    = 20; // Value out of range
  errRbrExpected   = 21; // ']' expected
  errManyRbr       = 22; // Too many '['
  errZeroDivide    = 23; // Division by zero
  errNameDup       = 24; // Variable or array name duplicated
  errFileOpen      = 25; // File оpen error
  errFuncResult    = 26; // Function must return result
  errOfExpected    = 27; // CASE without OF
  errManyElse      = 28; // Too many ELSE in CASE statement
  errCaseRange     = 29; // Case range expected

// Fast upcase function for Russian Win-1251 charset.
// For other charsets, уоu can modify it or replace
// function StUpCaseR with AnsiUpperCase

function UpCaseR(C : Char): Char; assembler;
asm
     // Checking ANSI characters 'a'..'z'
     MOV    AL,C
     CMP    AL,'a'
     JB     @@3
     CMP    AL,'z'
     JBE    @@2

     // Checking Russian characters
     CMP    AL,'ё'
     JZ     @@1
     CMP    AL,'а'
     JB     @@3
     CMP    AL,'я'
     JBE    @@2
     JMP    @@3
@@1: MOV    AL,'Ё'
     JMP    @@3
     // End of Russian charset checking

@@2: SUB    AL,$20
@@3:
end;


function StUpCaseR(S : String): String;
var i : integer;
begin
  Result := S;
  for i := 1 to Length(Result) do Result[i] := UpCaseR(Result[i]);
end;


function DelChrs(s:string; c:char) : string;
var i : integer;
begin
  Result := '';
  for i:= 1 to Length(s) do
  if s[i]<>c then Result := Result + s[i];
end;


function ReplaceChrs(s:string; cFrom,cTo:char) : string;
var i : integer;
begin
  Result := s;
  for i:= 1 to Length(s) do
  if s[i]=cFrom then Result[i] := cTo;
end;


function StrToNum(S:string;var X:extended):boolean;
var
  c : char;
  st : string;
  i,nt,nz : integer;
begin
  Result := false;
  nz:=0; nt:=0;
  st := Trim(s);
  c:=' ';

  if st[1] = '$' then
  begin
    Val(st,nt,i);
    x := nt;
    Result := i=0;
    Exit;
  end;

  for i:=1 to length(st) do
  begin
    if not (st[i] in ['0'..'9','+','-',',','.']) then Exit;
    if st[i]='.' then begin inc(nt); c:='.'; end;
    if st[i]=',' then begin inc(nz); c:=','; end;
  end;

  if (c='.') and (nt=1) then st:=DelChrs(st,',');
  if (c=',') and (nz=1) then
  begin
    st:=DelChrs(st,'.');
    st := ReplaceChrs(st,',','.');
  end;

  Val(st,x,i);
  Result := i=0;
end;


function ExtToInt(X:extended):integer;
var m : boolean;
begin
  m := x<0;
  if m then x := -x;
  Result := Trunc(x+0.000000001);
  if m then Result := -Result;
end;


function CmpStr(s1,s2:string;p,l:integer) : boolean;
var i,n : integer;
begin
  Result := false;
  n := Length(s2);
  if p+l-1>n then Exit;
  for i := 1 to l do if s1[i]<>s2[p+i-1] then Exit;
  Result := true;
end;


function IsAlpha(s:string) : boolean;
var i : integer;
begin
  Result := false;
  for i:= 1 to Length(s) do
  if not (s[i] in Alpha) then Exit;
  Result := true;
end;


function ValidName(S : String): boolean;
var
  i,n : integer;
  Arr : boolean;
begin
  Result := false;
  if S='' then Exit;
  if not (S[1] in Alpha) then Exit;
  if S[1] in ['0'..'9'] then Exit;
  Arr := false;
  n := length(S);
  for i := 2 to n do
  begin
    if not Arr then
    begin
      if not (S[i] in Alpha) then
      begin
        if S[i]<>ResWords[tLARR][1] then Exit;
        Arr := true;
      end;
    end else
    begin
      if not (S[i] in ['0'..'9'])
      and (S[i]<>ResWords[tSUB][1])
      and (S[i]<>ResWords[tCOMMA][1])
      and (S[i]<>ResWords[tRARR][1]) then Exit;
      if (S[i]=ResWords[tRARR][1]) and (i<>n)then Exit;
    end;
  end;
  Result := true;
end;

function VarIsString(V : TVar) : boolean;
var t: integer;
begin
  t := VarType(V.Value);
  Result := (t=varString) or (t=varOleStr);
end;

function VarTypeName(V : variant) : string;
var i : integer;
begin
  i := VarType(v);
  case i of
    varEmpty    : Result := 'Empty';
    varNull     : Result := 'Null';
    varSmallint : Result := 'SmallInt';
    varInteger  : Result := 'Integer';
    varSingle   : Result := 'Single';
    varDouble   : Result := 'Double';
    varCurrency : Result := 'Currency ';
    varDate     : Result := 'Date';
    varOleStr   : Result := 'OleStr';
    varDispatch : Result := 'Dispatch';
    varError    : Result := 'Error';
    varBoolean  : Result := 'Boolean';
    varVariant  : Result := 'Variant';
    varUnknown  : Result := 'Unknown';
    varByte     : Result := 'Byte';
    varString   : Result := 'String';
    varTypeMask : Result := 'TypeMask';
    varArray    : Result := 'Array';
    else Result := '';
  end;
end;


procedure TVarList.ClearAll;
var i : integer;
begin
  for i := 0 to Count-1 do Dispose(TPVar(Items[i]));
  Clear;
end;


destructor TVarList.Destroy;
begin
  ClearAll;
  inherited Destroy;
end;


function TVarList.VarExist(N:string):boolean;
var
  i : integer;
begin
  Result := true;
  for i := 0 to Count-1 do
    if TPVar(Items[i])^.Name=N then Exit;
  Result := false;
end;


function TVarList.VarIndex(N:string):integer;
var
  i : integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
  if TPVar(Items[i])^.Name=N then
  begin
    Result := i;
    Exit;
  end;
end;


function TVarList.AddVar(V : TVar) : boolean;
var
  P : TPVar;
begin
  Result := true;
  if VarExist(V.Name) then Exit;
  if not ValidName(V.Name) then
  begin
    Result := false;
    Exit;
  end;
  New(P);
  P^ := V;
  Add(P);
end;


function TVarList.AddValue(N:string; V:variant) : boolean;
var
  X : TVar;
begin
  X.Name  := N;
  X.Value := V;
  Result  := AddVar(X);
end;


function TVarList.SetVar(V:TVar) : boolean;
var i : integer;
begin
  i := VarIndex(V.Name);
  if i<0 then Result := AddVar(V) else
  begin
    Result := true;
    TPVar(Items[i])^ := V;
  end;
end;


function TVarList.SetValue(N:string; V:variant) : boolean;
var
  i : integer;
begin
  Result := true;
  for i := 0 to Count-1 do
  begin
    if TPVar(Items[i])^.Name=N then
    begin
      TPVar(Items[i])^.Value := V;
      Exit;
    end;
  end;
  Result := AddValue(N,V);
end;


function TVarList.VarByName(N:string;var V:TVar):boolean;
var
  i : integer;
begin
  Result := true;
  for i := 0 to Count-1 do
  begin
    if TPVar(Items[i])^.Name=N then
    begin
      V := TPVar(Items[i])^;
      Exit;
    end;
  end;
  Result := false;
end;


procedure TVarList.CopyTo(VL:TVarList);
var i:integer;
begin
  for i:=0 to Count-1 do VL.AddVar(TPVar(Items[i])^);
end;



procedure TFuncList.ClearAll;
var i : integer;
begin
  for i := 0 to Count-1 do Dispose(TPFunc(Items[i]));
  Clear;
end;


destructor TFuncList.Destroy;
begin
  ClearAll;
  inherited Destroy;
end;


function TFuncList.AddFunction(N:string; F:Pointer) : boolean;
var
  P : TPFunc;
begin
  Result := false;
  if not ValidName(N) then Exit;
  Result := true;
  New(P);
  P^.Name := StUpCaseR(N);
  P^.Func := F;
  Add(P);
end;


destructor TProcList.Destroy;
begin
  ClearAll;
  inherited Destroy;
end;


procedure TProcList.ClearAll;
var i : integer;
begin
  for i := 0 to Count-1 do Dispose(TPProcedure(Items[i]));
  Clear;
end;


function TProcList.ProcIndex(Name:string):integer;
var i : integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
  begin
    if TPProcedure(Items[i])^.Name=Name then
    begin
      Result := i;
      Exit;
    end;
  end;
end;


function TProcList.ProcByName(Name:string; var Proc:TProcedure):boolean;
var i : integer;
begin
  i := ProcIndex(Name);
  Result := i>=0;
  if Result then Proc := TPProcedure(Items[i])^;
end;


function TProcList.AddProc(Proc:TProcedure):boolean;
var
  P  : TProcedure;
  PP : TPProcedure;
begin
  Result := false;
  if ProcByName(Proc.Name,P) then Exit;
  Result := true;
  New(PP);
  PP^ := Proc;
  Add(PP);
end;


constructor TPasCalc.Create;
begin
  inherited Create;
  ErrCode     := errOK;
  ProcessProc := nil;
  VarList     := TVarList.Create;
  FuncList    := TFuncList.Create;
  ProcList    := TProcList.Create;
  LastString  := '';
  LastParsed  := '';
end;


destructor TPasCalc.Destroy;
begin
  VarList.Free;
  FuncList.Free;
  ProcList.Free;
end;


procedure TPasCalc.SetProcessProc(P:Pointer);
begin
  ProcessProc := P;
end;


procedure TPasCalc.Process;
begin
  if Stop then BlockCmd := tEXIT;

  if Assigned(ProcessProc) then
  begin
    ProcessProc;
    Exit;
  end;

  Application.ProcessMessages;

end;

procedure TPasCalc.Clear;
begin
  BlockLevel := -1;
  BlockCmd   := tEMPTY;
  Stop       := false;
  ErrCode    := errOK;
  ErrLine    := '';
  ErrMsg     := '';
end;


procedure TPasCalc.ClearVars;
begin
  VarList.ClearAll;
end;


procedure TPasCalc.ClearFuncs;
begin
  FuncList.ClearAll;
end;


procedure TPasCalc.Error(Msg,Line:string; Code:integer);
begin
  if ErrCode<>errOK then Exit;
  ErrCode := Code;
  ErrMsg  := Msg;
  ErrLine := UnParse(Line,true);
end;


function TPasCalc.VarCount:integer;
begin
  Result := VarList.Count;
end;


function TPasCalc.VarIndex(N:string):integer;
begin
  Result := VarList.VarIndex(N);
end;


function TPasCalc.VarByName(N:string;var V:TVar):boolean;
begin
  Result := VarList.VarByName(StUpCaseR(Trim(N)),V);
end;


function TPasCalc.VarByIndex(I:integer; var V:TVar):boolean;
begin
  Result := false;
  if (I<0) or (I>=VarList.Count) then Exit;
  Result := true;
  V := TVar(VarList.Items[I]^);
end;


function TPasCalc.SetVar(V:TVar):boolean;
begin
  Result := VarList.SetVar(V);
end;


function TPasCalc.SetValue(N:string; V:variant):boolean;
begin
  Result := VarList.SetValue(StUpCaseR(Trim(N)),V);
end;


function TPasCalc.SetFunction(N:string; F:Pointer) : boolean;
var i : integer;
begin
  Result := true;
  i := FindFunc(StUpCaseR(Trim(N)));
  if i>=0 then
  begin
    if F=nil then
    begin
      Dispose(TPFunc(FuncList.Items[i]));
      FuncList.Delete(i);
    end else TPFunc(FuncList.Items[i])^.Func := F;
    Exit;
  end;
  Result := FuncList.AddFunction(Trim(N),F);
end;


function TPasCalc.Calculate(S:string; var R:TVar) : boolean;
begin
  if Pos(TokenDelimiter,S)=0 then
  begin
    if LastString<>S then LastParsed := Parse(S);
    LastString := S;
    Result := Calc(LastParsed,R);
  end else Result := Calc(S,R);
end;


function TPasCalc.Calc(S:string; var R:TVar) : boolean;
var
  ITmp : integer;
  TTmp : TToken;
  ETmp : string;
begin
  Result := false;
  VarClear(R.Value);
  ITmp  := ExprIndex;
  ETmp  := Expr;
  TTmp  := TokenCode;

  Expr := S;
  ExprIndex := 1;

  Token := GetToken(Expr,ExprIndex,TokenCode);
  if TokenCode=tEmpty then
  begin
    Error('Empty string - not expression',Expr,errExprSyntax);
    Exit;
  end;

  Level1(R);

  Token := GetToken(Expr,ExprIndex,TokenCode);

  Result := (ErrCode=errOK) and (TokenCode=tEMPTY);
  TokenCode := TTmp;
  ExprIndex:=ITmp;
  Expr:=ETmp;
end;


procedure TPasCalc.Level1(var R:TVar);    (* логическое ИЛИ *)
var
  op   : TToken;
  hold : TVar;
begin
  Level2(R);
  if ErrCode<>errOK then Exit;
  while (TokenCode=tOR) or (Tokencode=tXOR) do
  begin
    op:=TokenCode;
    Token := GetToken(Expr,ExprIndex,TokenCode);
    Level2(hold);
    if ErrCode<>errOK then exit;
    Arith(op,R,hold);
  end;
end;


procedure TPasCalc.Level2(var R:TVar);    (* логическое И *)
var
  op   : TToken;
  hold : TVar;
begin
  Level3(R);
  if ErrCode<>errOK then Exit;
  while TokenCode=tAND do
  begin
    op:=TokenCode;
    Token := GetToken(Expr,ExprIndex,TokenCode);
    Level3(hold);
    if ErrCode<>errOK then exit;
    Arith(op,R,hold);
  end;
end;


procedure TPasCalc.Level3(var R:TVar);    (* сравнение     *)
var
  op   : TToken;
  hold : TVar;
begin
  Level4(R);
  if ErrCode<>errOK then Exit;
  while (TokenCode=tLS) or (TokenCode=tGT)
     or (TokenCode=tLSE) or (TokenCode=tGTE)
     or (TokenCode=tEQU) or (TokenCode=tNEQ) do
  begin
    op:=TokenCode;
    Token := GetToken(Expr,ExprIndex,TokenCode);
    level4(hold);
    if ErrCode<>errOK then Exit;
    Arith(op,R,hold);
  end;
end;


procedure TPasCalc.Level4(var R:TVar);    (* сложение,вычитание *)
var
  op   : TToken;
  hold : TVar;
begin
  Level5(R);
  if ErrCode<>errOK then Exit;
  while (TokenCode=tADD) or (TokenCode=tSUB) do
  begin
    op:=TokenCode;
    Token := GetToken(Expr,ExprIndex,TokenCode);
    Level5(hold);
    if ErrCode<>errOK then Exit;
    arith(op,R,hold);
  end;
end;


procedure TPasCalc.Level5(var R:TVar);    (* умножение,деление *)
var
  op   : TToken;
  hold : TVar;
begin
  Level6(R);
  if ErrCode<>errOK then Exit;
  while (TokenCode=tMUL) or (TokenCode=tDIV) do
  begin
    op:=TokenCode;
    Token := GetToken(Expr,ExprIndex,TokenCode);
    Level6(hold);
    if ErrCode>0 then Exit;
    Arith(op,R,hold);
  end;
end;


procedure TPasCalc.Level6(var R:TVar);    (* возв. в степень *)
var
  op   : TToken;
  hold : TVar;
begin
  Level7(R);
  if ErrCode<>errOK then Exit;
  while (TokenCode=tPWR) or (TokenCode=tSHL) or (TokenCode=tSHR) do
  begin
    op:=TokenCode;
    Token := GetToken(Expr,ExprIndex,TokenCode);
    Level7(hold);
    if ErrCode<>errOK then Exit;
    Arith(op,R,hold);
  end;
end;


procedure TPasCalc.Level7(var R:TVar);    (* унарные операции *)
var op : TToken;
begin
  op := tEMPTY;
  if (TokenCode=tADD) or (TokenCode=tSUB) or (TokenCode=tNOT) then
  begin
    op:=TokenCode;
    Token := GetToken(Expr,ExprIndex,TokenCode);
  end;
  Level8(R);
  if ErrCode<>errOK then Exit;
  if op>tEMPTY then Unary(op,R);
end;


procedure TPasCalc.Level8 (var R:TVar);    (* круглые скобки *)
var
  T : TToken;
  i : integer;
  E : Extended;
  arr1,arr2 : boolean;
  S,Nm,ind1,ind2 : string;
begin
  arr1 := false;
  arr2 := false;

  if TokenCode=tLBR then
  begin
    Token := GetToken(Expr,ExprIndex,TokenCode);
    Level1(R);
    if ErrCode<>errOK then Exit;
    if TokenCode<>tRBR then
    begin
      Error(''''+ResWords[tRBR]+''' expected',Expr,errParentheses);
      Exit;
    end;
    Token := GetToken(Expr,ExprIndex,TokenCode);
  end else
  begin
    case TokenCode of

      tTRUE : begin
                R.Name  := ResWords[tTRUE];
                R.Value := true;
              end;

      tFALSE : begin
                R.Name  := ResWords[tFALSE];
                R.Value := false;
              end;

      tVR : begin
              Nm := Token;
              T  := NextToken(Expr,ExprIndex);
              if (T=tLBR)
              or (FindFunc(Nm)>=0) or (ProcList.ProcIndex(Nm)>=0) then
              begin
                s := GetFuncParams(Expr,ExprIndex);

                if ProcList.ProcIndex(Nm)>=0 then
                begin
                  if not CallProc(Nm,s,R) then
                  begin
                    Error('Error in procedure: '+Nm,Expr,errCall);
                    Exit;
                  end;
                end else
                if not CallFunc(Nm,s,R) then
                begin
                  Error('Error in function: '+Nm,Expr,errCall);
                  Exit;
                end;

              end else
              begin
                ind1 := ''; ind2 := '';

                if T=tLARR then
                begin
                  ind1 := GetIndex(Expr,ExprIndex,TokenCode);
                  if ErrCode<>errOK then Exit;
                  arr1 := true;
                end;

                T  := NextToken(Expr,ExprIndex);
                if T=tLARR then
                begin
                  ind2 := GetIndex(Expr,ExprIndex,TokenCode);
                  if ErrCode<>errOK then Exit;
                  arr2 := true;
                end;

                if arr1 and (not arr2) and (VarIndex(Nm)>=0) then
                begin
                  arr1 := false;
                  arr2 := true;
                  ind2 := ind1;
                end;

                if arr1 then
                begin
                  if VarIndex(Nm)>=0 then
                  begin
                    Error('Variable with same name exist : '+Nm,CmdLine,errNameDup);
                    Exit;
                  end;
                  Nm := Nm + '[' + ind1 + ']';
                end else
                begin
                  if FindArray(Nm) then
                  begin
                    Error('Array with same name exist : '+Nm,CmdLine,errNameDup);
                    Exit;
                  end;
                end;

                if not VarList.VarByName(Nm,R) then
                begin
                  Error('Variable not found: '+Nm,Expr,errVarNotFound);
                  Exit;
                end;

                if arr2 then
                begin
                  if not VarIsString(R) then
                  begin
                    Error('Invalid variable type: '+Nm,Expr,errTypeCast);
                    Exit;
                  end;

                  if ind2='' then
                  begin
                    Error('Empty string index',Expr,errIndexRange);
                    Exit;
                  end;

                  if Pos(',',ind2)>0 then
                  begin
                    Error('Invalid string index',Expr,errIndexRange);
                    Exit;
                  end;

                  try
                    i := StrToInt(ind2);
                  except
                    Error('Invalid string index : '+ind2,Expr,errIndexRange);
                    Exit;
                  end;

                  if (i<1) or (i>Length(string(R.Value))) then
                  begin
                    Error('String index out of range: '+ind2,Expr,errIndexRange);
                    Exit;
                  end;

                  R.Value := string(R.Value)[i];
                end;
              end;

	      Token := GetToken(Expr,ExprIndex,TokenCode);
	    end;

      tCON: begin
              if (Token[1]<>StrDelimiter) then
              begin
                if not StrToNum(Token,E) then
                begin
                  Error('Invalid number: '+Token,Expr,errExprSyntax);
                  Exit;
                end;

                if (Pos(DecimalPoint,Token)=0)
                and (E<MaxInt) and (E>-MaxInt)
                then R.Value := ExtToInt(E)
                else R.Value := E;

              end else
              begin
                if (Length(Token)<2)
                or (Token[Length(Token)]<>StrDelimiter) then
                begin
                  Error('Unterminated string: '+Token,Expr,errString);
                  Exit;
                end;
                R.Value := copy(Token,2,Length(Token)-2);
              end;
              Token := GetToken(Expr,ExprIndex,TokenCode);
            end;
      else  begin
              Error('Unknown or invalid operator in expression: '+Token,Expr,errExprSyntax);
            end;
    end;
  end;
end;


procedure TPasCalc.Arith (o : TToken; var R,H:TVar);
begin
  case O of
    tOR  : begin
             try
               R.Value := R.Value or H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tAND : begin
             try
               R.Value := R.Value and H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;


    tXOR : begin
             try
               R.Value := R.Value xor H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tEQU : begin
             try
               R.Value := R.Value = H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tNEQ : begin
             try
               R.Value := R.Value <> H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tGT  : begin
             try
               R.Value := R.Value > H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tLS  : begin
             try
               R.Value := R.Value < H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tGTE : begin
             try
               R.Value := R.Value >= H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tLSE : begin
             try
               R.Value := R.Value <= H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tADD : begin
             try
               R.Value := R.Value + H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tSUB : begin
             try
               R.Value := R.Value - H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tMUL : begin
             try
               R.Value := R.Value * H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tDIV : begin
             try
               R.Value := R.Value / H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tPWR : begin
             try
               R.Value := Power(R.Value,H.Value);
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tSHL : begin
             try
               R.Value := R.Value shl H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

    tSHR : begin
             try
               R.Value := R.Value shr H.Value;
             except
               Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
               Exit;
             end;
           end;

  end;
end;


procedure TPasCalc.Unary(o : TToken; var R:TVar);
begin
  if o=tSUB then
  begin
    try
      R.Value := -R.Value;
      Exit;
    except
      Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
      Exit;
    end;
  end;

  if o=tNOT then
  begin
    try
      R.Value := not R.Value;
      Exit;
    except
      Error('Invalid operand types for "'+ResWords[o]+'"',Expr,errTypeCast);
      Exit;
    end;
  end;
end;


procedure TPasCalc.SetVarDirect(var R:TVar);
var
  P : TPVar;
  i : integer;
begin
  i := VarList.VarIndex(R.Name);
  if i>=0 then TPVar(VarList[i])^ := R else
  begin
    New(P);
    P^ := R;
    VarList.Add(P);
  end;
end;


function TPasCalc.FindFunc(N:string) : integer;
var
  i  : integer;
begin
  Result := -1;
  for i := 0 to FuncList.Count-1 do
  begin
    if TPFunc(FuncList.Items[i])^.Name=N then
    begin
      Result := i;
      break;
    end;
  end;
end;


function TPasCalc.FindArray(N:string) : boolean;
var
  i,l : integer;
  s : string;
begin
  Result := false;
  l := Length(N)+1;
  s := N+'[';
  for i := 0 to VarList.Count-1 do
  begin
    if CmpStr(TPVar(VarList.Items[i])^.Name,N,1,l) then
    begin
      Result := true;
      break;
    end;
  end;
end;


function TPasCalc.GetIndex(S:string; var Index:integer; var T:TToken) : string;
var
  R  : TVar;
  tt : TToken;
  i,a,b : integer;
  ss,st,ind : string;
begin
  Result := '';

  if Index>Length(S) then
  begin
    Error('Invalid string index',S,errExprSyntax);
    Exit;
  end;

  Token := GetToken(S,Index,T);
  if T<>tLARR then
  begin
    Error(ResWords[tLARR]+' expected',Expr,errManyRbr);
    Exit;
  end;

  ss := '';
  a  := 1;
  repeat
    Token := GetToken(S,Index,T);
    if T=tLARR  then inc(a);
    if T=tRARR  then dec(a);
    if T=tEMPTY then break;
    if a=0 then break;
    ss:=ss+TokenStr(T,Token);
  until false;

  if a>0 then
  begin
    Error(ResWords[tRARR]+' expected',S,errRbrExpected);
    Exit;
  end;

  i := 1;
  a := 0;
  b := 0;
  st:= '';
  ind := '';
  repeat
    st := GetToken(ss,i,tt);
    if tt=tRBR then inc(b);
    if tt=tLBR then dec(b);
    if tt=tLARR  then inc(a);
    if tt=tRARR  then dec(a);

    if (a=0) and (b=0) and ((tt=tCOMMA) or (tt=tEMPTY)) then
    begin
      if not Calc(ind,R) then
      begin
        Error('Error in expression: '+UnParse(ind,true),S,errExprSyntax);
        Exit;
      end;

      try
        i := R.Value;
      except
        Error('Invalid index: '+UnParse(ind,true),S,errTypeCast);;
        Exit;
      end;

      if Result=''
      then Result := IntToStr(i)
      else Result := Result + ','+IntToStr(i);

      ind := '';
    end else ind := ind + TokenStr(tt,st);
    if tt=tEMPTY then break;
  until false;
end;


function TPasCalc.GetFuncParams(S:string; var Index:integer) : string;
var
  t   : TToken;
  i,j : integer;
  st,ss,p : string;
begin
  Result:='';
  if Index>Length(s) then Exit;

  i := Index;
  Token := GetToken(s,Index,TokenCode);

  if TokenCode<>tLBR then
  begin
    Index := i;
    Exit;
  end;

  i:=1;
  st:='';
  repeat
    Token := GetToken(s,Index,TokenCode);
    if TokenCode=tLBR then inc(i);
    if TokenCode=tRBR then dec(i);
    if (TokenCode=tEMPTY) or (i=0)  then break;
    st:=st+TokenStr(TokenCode,Token);
  until false;

  if i<>0 then
  begin
    Error('Invalid function params: '+UnParse(st,true),s,errExprSyntax);
    Exit;
  end;

  p := '';
  i := 1; j := 0;
  repeat
    ss := GetToken(st,i,t);
    if t=tEMPTY then break;
    if t=tRBR then inc(j);
    if t=tLBR then dec(j);
    if (j=0) and (t=tCOMMA)
    then p := p+#13#10
    else p:=p+TokenStr(t,ss);
  until false;
  Result := p;
end;


function TPasCalc.CallFunc(N:string; A:string; var V:TVar) : boolean;
var
  i,j,f : integer;
  SL  : TStringList;
  VL  : TVarList;
  VR  : TVar;
  P   : TPVar;
  s,err: string;
begin
  Result := false;
  f := FindFunc(N);

  if f<0 then
  begin
    Error('Unknown function: '+N,Expr,errFuncNotFound);
    Exit;
  end;

  SL := TStringList.Create;
  SL.Text := A;
  VL := TVarList.Create;

  for i := 0 to SL.Count-1 do
  begin
    if Calc(SL[i],VR) then
    begin
      New(P);
      P^ := VR;
      j  := -1;
      s := UnParse(Trim(SL[i]),false);

      if ValidName(s) then j := VarIndex(s);
      if j>=0 then P^.Name := 'VAR' else P^.Name := 'VALUE';
      SL.Objects[i] := TObject(j);
      VL.Add(P);
    end else
    begin
      Error('Invalid expression in function params: '+SL.Strings[i],Expr,errCall);
      SL.Destroy;
      VL.Destroy;
      Exit;
    end;
  end;
  err := '';
  try
    Result := PFunction(TPFunc(FuncList.Items[f])^.Func)(Self,VL,V);
  except
    on E:Exception do
    begin
      Result := false;
      err := E.Message;
    end;
  end;
  if not Result then
  begin
    s := 'Invalid parameters, function '+N;
    if err<>'' then s := s + ' : '+err;
    Error(s,Expr,7)
  end else
  for i := 0 to SL.Count-1 do
  begin
    j := integer(SL.Objects[i]);
    if (j>=0) and (i<VL.Count) and (j<VarList.Count) then
    begin
      s := TPVar(VarList.Items[j])^.Name;
      TPVar(VarList.Items[j])^ := TPVar(VL.Items[i])^;
      TPVar(VarList.Items[j])^.Name := s;
    end;
  end;

  SL.Destroy;
  VL.Destroy;
end;


function TPasCalc.CallProc(N:string; A:string; var V:TVar) : boolean;
var
  i,j: integer;
  s  : string;
  PR : TProcedure;
  VR : TVar;
  VL : TVarList;
  TL : TVarList;
  SL : TStringList;
  PL : TStringList;
begin
  Result := false;
  if not ProcList.ProcByName(N,PR) then
  begin
    Error('Unknown procedure: '+N,Expr,errFuncNotFound);
    Exit;
  end;
  VL := TVarList.Create;
  VarList.CopyTo(VL);
  SL := TStringList.Create;
  SL.Text := A;
  PL := TStringList.Create;
  PL.Text := PR.Params;

  if PL.Count<>SL.Count then
  begin
    Error('Wrong parameters amount, procedure '+N,Expr,errCall);
    Exit;
  end;

  for i := 0 to SL.Count-1 do
  begin
    if Calc(SL[i],VR) then
    begin
      VR.Name := PL[i];
      if not SetVar(VR) then
      begin
        Error('Duplicate variable name: '+VR.Name,Expr,errNameDup);
        VarList.ClearAll;
        VL.CopyTo(VarList);
        SL.Free;
        VL.Free;
        PL.Free;
        Exit;
      end;
    end else
    begin
      Error('Invalid expression in function params: '+SL.Strings[i],Expr,errCall);
      VarList.ClearAll;
      VL.CopyTo(VarList);
      SL.Free;
      VL.Free;
      PL.Free;
      Exit;
    end;
  end;

  if PR.Result then
  begin
    i := VarIndex('RESULT');
    if i>=0 then
    begin
      Dispose(TPVar(Varlist.Items[i]));
      VarList.Delete(i);
    end;
  end;

  Exec(PR.Body);

  if BlockCmd<>tEMPTY then
  begin
    if BlockCmd=tEXIT then BlockCmd := tEMPTY else
    begin
      if BlockCmd in [tBREAK,tCONTINUE] then
        Error(ResWords[BlockCmd]+' outside loop',PR.Body,errBreak);

      if BlockCmd=tGOTO then
        Error('Label '+GotoLabel+' not exist or unreacheble',PR.Body,errLabelNotFound);

      SL.Free;
      VL.Free;
      PL.Free;
      Exit;
    end;
  end;

  TL :=TVarList.Create;
  VarList.CopyTo(TL);
  VarList.ClearAll;
  VL.CopyTo(VarList);

  for i := 0 to PL.Count-1 do
  begin
    if TL.VarByName(PL[i],VR) then
    begin
      j := -1;
      s := UnParse(Trim(SL[i]),false);
      if ValidName(s) then j := VarIndex(s);
      if j>=0 then
      begin
        VR.Name := s;
        TPVar(VarList.Items[j])^ := VR;
      end;
    end;
  end;

  if PR.Result then
  begin
    if TL.VarByName('RESULT',VR) then
    begin
      V.Value := VR.Value;
    end else
    begin
      Error('Function must return result : '+PR.Name,Expr,errFuncResult);
      VarList.ClearAll;
      VL.CopyTo(VarList);
      SL.Free;
      VL.Free;
      PL.Free;
      TL.Free;
      Exit;
    end;
  end;

  SL.Free;
  VL.Free;
  PL.Free;
  TL.Free;

  Result := true;
end;


function TPasCalc.GetTextToken(S: string; var Index : integer; var Code : TToken) : string;
var
  t : TToken;
  i,j,sl,tl : integer;
begin
  Code:=tEMPTY;
  Result := '';
  sl := Length(s);
  while (Index<=sl) and (s[Index] in SpaceSet) do inc(Index);

  if (Index>sl) then Exit;
  for t:= Low(TToken) to High(TToken) do
  begin
    tl := Length(ResWords[t]);
    if tl=0 then continue;
    if CmpStr(ResWords[t],s,Index,tl)
    and (tl>Length(Result))
    and ((index+tl>sl)
         or not (s[index+tl] in Alpha)
         or not IsAlpha(ResWords[t])) then
    begin
      Result:=ResWords[t];
      Code:=t;
    end;
  end;

  if Code<>tEMPTY then
  begin
    Index:=Index+Length(Result);
    Exit;
  end;

  i:=Index;

  if s[i]<>StrDelimiter then
  begin

    while (Index<=sl) do
    begin
      if (s[Index] in SpaceSet)
      or ((Index>i) and not (s[Index] in Alpha)
          and (s[Index]<>DecimalPoint)) then break;
      inc(Index);
    end;
    Result:= Trim(copy(s,i,Index-i));

    if (Result<>'') and (Result[1] in ['0'..'9']) then
    begin
      j := Pos(ResWords[tCOMMA2],Result);
      if j>0 then
      begin
        Result := Trim(copy(Result,1,j-1));
        Index  := i+Length(Result);
      end;
    end;
    
  end else
  begin
    inc(Index);
    while (Index<=sl) and (s[Index]<>StrDelimiter) do inc(Index);
    Result:=Trim(copy(s,i,Index-i+1));
    inc(Index);
  end;

  if Result='' then Exit;

  if ((Result[1]<'0') or (Result[1] >'9')) and ((Result[1]<>'$'))
  and (Result[1]<>StrDelimiter)
  then Code:=tVR else Code:=tCON;
end;


function TPasCalc.TokenStr(T:TToken;S:string) : string;
begin
  Result := TokenDelimiter + char(byte(T)+$40) + S;
end;


function TPasCalc.DelRemarks(S:string) : string;
var
  st,ss : string;
  i,rr,rb,re: integer;
  InString,InRem : boolean;
begin
  st := StUpCaseR(S);
  InRem := false;
  InString := false;

  rr := Length(ResWords[tREM]);
  rb := Length(ResWords[tREMB]);
  re := Length(ResWords[tREME]);

  i := 1;
  while i<=Length(st) do
  begin
    if not InRem then
    if st[i]=StrDelimiter then InString := not InString;

    if not InString then
    begin
      if CmpStr(ResWords[tREM],st,i,rr)  then InRem := true;
      if CmpStr(ResWords[tREMB],st,i,rb) then InRem := true;
      if CmpStr(ResWords[tREME],st,i,re) then
      begin
        InRem := false;
        i := i + re;
        continue;
      end;
      if (st[i]=#$A) or (st[i]=#$D) then InRem := false;
    end;
    if not InRem then
    if InString then ss := ss + S[i] else ss := ss + UpCaseR(S[i]);
    inc(i);
  end;
  Result := ss;
end;


function TPasCalc.Parse(S:string) : string;
var
  i : integer;
  T : TToken;
  ts,ss : string;
begin
  Result := '';
  i := 1;
  ss := DelRemarks(S);
  repeat
    TS := GetTextToken(ss,i,T);
    if T=tEMPTY then break;
    Result := Result+TokenStr(T,TS);
  until false;
end;


function TPasCalc.UnParse(S:string;Show:boolean) : string;
var
  i : integer;
  T : TToken;
begin
  i := 1;
  Result := '';
  repeat
    Result := Result + GetToken(s,i,T);
    if Show then Result := Result + ' ';
    if t=tEMPTY then break;
  until false;
end;


function TPasCalc.GetToken(S: string; var Index : integer; var Code : TToken) : string;
var
  sl,i : integer;
begin
  Code:=tEMPTY;
  Result := '';
  sl := Length(s);
  if Index+1>sl then Exit;
  if s[Index]<>TokenDelimiter then Exit;
  inc(Index);
  Code := TToken(byte(s[Index])-$40);
  i := Index+1;
  while (Index<=sl) and (s[Index]<>TokenDelimiter) do inc(Index);
  Result := Result+copy(s,i,Index-i);
end;


function TPasCalc.GetTokenCode(S: string; var Index:integer; var Code:TToken) : integer;
var
  sl : integer;
begin
  Result := Index;
  Code := tEMPTY;
  sl := Length(s);
  if Index+1>sl then Exit;
  if s[Index]<>TokenDelimiter then Exit;
  Result := Index;
  inc(Index);
  Code := TToken(byte(s[Index])-$40);
  while (Index<=sl) and (s[Index]<>TokenDelimiter) do inc(Index);
end;


function TPasCalc.GetTokenLine(S:string; var Index:integer; var Code:TToken;
                               StopToken:TTokenSet) : string;
var i,n : integer;
begin
  i := Index;
  repeat
    n := GetTokenCode(S,Index,Code);
    if Code=tEMPTY then break;
  until Code in StopToken;
  Result := copy(s,i,n-i);
end;


function TPasCalc.NextToken(S:string; Index:integer) : TToken;
var
  i : integer;
  t : tToken;
begin
  i := Index;
  GetTokenCode(S,i,t);
  Result := t;
end;


function TPasCalc.GetOperator(Txt:string; var Index : integer; EndToken:TTokenSet) : string;
var
  t : TToken;
  s : string;
  Level,RLevel : integer;
begin
  Level  := 0;
  RLevel := 0;
  Result := '';
  repeat
    s := GetToken(Txt,Index,t);
    if (t=tSEMI) and (Result='') then continue;
    if (t=tEMPTY) or ((t in EndToken) and (Level=0) and (RLevel=0)) then break;
    if (t=tBEGIN) or (t=tCASE) then inc(Level);
    if t=tEND then dec(Level);
    if t=tREPEAT then inc(RLevel);
    if t=tUNTIL then dec(RLevel);
    Result := Result+TokenStr(t,s);
  until false;
  if Level>0 then
    Error(ResWords[tEND]+' expected',Result,errEndExpected);
  if Level<0 then Error('Too many '+ResWords[tEND],Result,errManyEnd);
  if RLevel>0 then
    Error(ResWords[tUNTIL]+' expected',Result,errUntilExpected);
  if Level<0 then
    Error('Too many '+ResWords[tUNTIL],Result,errManyUntil);
end;


function TPasCalc.ParseOperator(Txt:string; var Cmd,Line,Lbl : string) : TToken;
var
  i,n : integer;
  t : TToken;
  s : string;
begin
  s := Txt;
  Lbl := '';
  i := 1;
  Cmd := GetToken(s,i,t);
  Result := t;
  n := i;
  GetToken(s,n,t);
  if t=tLBL then
  begin
    i := n;
    Lbl := Cmd;
    Cmd := GetToken(s,i,t);
    Result := t;
  end;
  Line := copy(s,i,Length(s));
end;


procedure TPasCalc.Exec(Txt:string);
label EXECUTE;
var
  t : TToken;
  Ind : integer;
  c,s,l,CmdLine : string;
begin
  Ind := 1;
  Inc(BlockLevel);
  repeat
    if  ErrCode<>errOK then break;
    CmdLine := GetOperator(Txt,Ind,[tSEMI]);
    if CmdLine='' then break;
    t := ParseOperator(CmdLine,c,s,l);
EXECUTE :
    case t of
      tVR       : DoSet(CmdLine,c,s);
      tIF       : DoIf(CmdLine,s);
      tBEGIN    : DoBegin(CmdLine,s);
      tEND      : Error('Too many '+ResWords[tEND],CmdLine,errManyEnd);
      tELSE     : Error(ResWords[tELSE]+' without '+ResWords[tIF],CmdLine,errInvalidOp);
      tFOR      : DoFor(CmdLine,s);
      tWHILE    : DoWhile(CmdLine,s);
      tREPEAT   : DoRepeat(CmdLine,s);
      tBREAK    : DoBreak(CmdLine,s);
      tCONTINUE : DoContinue(CmdLine,s);
      tEXIT     : DoExit(CmdLine,s);
      tGOTO     : DoGoto(CmdLine,s);
      tCASE     : DoCase(CmdLine,s);
      else Error('Invalid operator: '+c,CmdLine,errInvalidOp);
    end;

    Process;

    if BlockCmd<>tEMPTY then
    begin
      if (BlockLevel=0) and (BlockCmd in [tBREAK,tCONTINUE])
      then Error(ResWords[BlockCmd]+' outside loop',CmdLine,errBreak);

      if BlockCmd=tGOTO then
      begin
        Ind := 1;
        repeat
          CmdLine := GetOperator(Txt,Ind,[tSEMI]);
          if CmdLine='' then break;
          t := ParseOperator(CmdLine,c,s,l);
          if l=GotoLabel then
          begin
            BlockCmd := tEMPTY;
            goto EXECUTE;
          end;
        until false;
      end;
      break;
    end;
  until false;
  Dec(BlockLevel);
  if (BlockLevel<0) and (BlockCmd=tGOTO)
  then Error('Label '+GotoLabel+' not exist or unreacheble',CmdLine,errLabelNotFound);
end;


function TPasCalc.PreProcess(Txt:string):string;
var
  T,TT : TToken;
  P :TProcedure;
  Index,i,j : integer;
  h : THandle;
  Operator,CmdLine,Op,Lbl,s: string;
  V : TVar;
begin
  Index:= 1;
  Result := '';
  repeat
    Operator := GetOperator(Txt,Index,[tSEMI]);
    if Operator='' then break;
    j := 1;
    GetTokenCode(Operator,j,T);
    case T of
        tPROC,tFUNCT : begin
                        ParseOperator(Operator,CmdLine,Op,Lbl);

                        i := 1;
                        P.Name := StUpCaseR(GetToken(Op,i,TT));

                        if TT<>tVR then
                        begin
                          Error('Invalid procedure name',Operator,errInvalidName);
                          Exit;
                        end;

                        if ProcList.ProcByName(P.Name,P) then
                        begin
                          Error('Duplicate procedure name',Operator,errNameDup);
                          Exit;
                        end;

                        GetToken(Op,i,TT);
                        if TT<>tLBR then
                        begin
                          Error(ResWords[tLBR]+' expected',Operator,errParentheses);
                          Exit;
                        end;

                        P.Body := '';
                        P.Params := '';

                        repeat
                          s := GetToken(Op,i,TT);
                          if TT=tRBR then break;
                          if TT<>tVR then
                          begin
                            Error('Invalid function call',Operator,errCall);
                            Exit;
                          end;
                          if P.Params<>'' then P.Params := P.Params + #13#10;
                          P.Params := P.Params + StUpCaseR(s);
                          s := GetToken(Op,i,TT);
                          if TT=tRBR then break;
                          if TT<>tCOMMA then
                          begin
                            Error('Invalid function call',Operator,errCall);
                            Exit;
                          end;
                        until false;

                        P.Body := GetOperator(Txt,Index,[tSEMI]);
                        P.Result := T=tFUNCT;

                        ProcList.AddProc(P);
                      end;

      tUSES,tINCLUDE: begin
                        ParseOperator(Operator,CmdLine,Op,Lbl);
                        if not Calc(Op,V) then
                        begin
                          Error('Invalid filename "'+Op+'" in '+ResWords[T]+' statement',
                                Operator,errExprSyntax);
                          Exit;
                        end;

                        try
                          s := V.Value;
                        except
                          Error('Invalid filename "'+Op+'" in '+ResWords[T]+' statement',
                                Operator,errExprSyntax);
                          Exit;
                        end;

                        h := FileOpen('scripts\'+s, fmOpenRead or fmShareDenyNone);
                        if h=INVALID_HANDLE_VALUE then
                        begin
                          Error('Can''t open file "'+Op+'", error code '+IntToStr(GetLastOSError),
                                Operator,errFileOpen);
                          Exit;
                        end;

                        i := FileSeek(h,0,2);
                        SetLength(s,i+1);
                        FileSeek(h,0,0);
                        FileRead(h,(@s[1])^,i);
                        FileClose(h);
                        s[i+1]:=#0;

                        if t=tUSES
                        then PreProcess(Parse(s))
                        else Result := Result + PreProcess(Parse(s));

                        SetLength(s,0);
                      end;

      else Result := Result + Operator + TokenStr(tSEMI,ResWords[tSEMI]);
    end;
  until false;
end;


function TPasCalc.Execute(S:string):boolean;
begin
  Clear;
  ProcList.ClearAll;
  if Pos(TokenDelimiter,S)=0 then
  begin
    if LastString<>S then LastParsed := Parse(s);
    LastString := S;
    Exec(PreProcess(LastParsed));
  end else Exec(PreProcess(S));
  Result := ErrCode=errOK;
end;


procedure TPasCalc.DoSet(CmdLine,Cmd,Line:string);
var
  R,RR : TVar;
  i,ind : integer;
  t : TToken;
  s,ss,v,ind1,ind2 : string;
  arr1,arr2 : boolean;
begin
  i := 1;
  arr1 := false;
  arr2 := false;
  Ind1 := '';
  Ind2 := '';
  V := Cmd;

  if NextToken(Line,i)=tLARR then
  begin
    ind1 := GetIndex(Line,i,T);
    if ErrCode<>errOK then Exit;
    arr1 := true;
  end;

  if NextToken(Line,i)=tLARR then
  begin
    ind2 := GetIndex(Line,i,T);
    if ErrCode<>errOK then Exit;
    arr2 := true;
  end;

  ss := GetToken(Line,i,t);

  if (t=tEQU) and (ResWords[tEQU]=ResWords[tASSIGN]) then t:=tASSIGN;

  if (t<>tASSIGN) and (t<>tLBR) and (t<>tEMPTY) and (t<>tLARR) then
  begin
    Error('Found '+ss+', expected '+ResWords[tASSIGN]+', '+
           ResWords[tLBR]+', '+ResWords[tLARR]+' or '+
           ResWords[tSEMI],Line,errExprSyntax);
    Exit;
  end;

  if t=tASSIGN then
  begin
    s := Trim(copy(Line,i,Length(Line)));
    v := Cmd;
  end else
  begin
    v := '';
    s := TokenStr(tVR,Cmd)+Line;
  end;

  if not Calc(s,R) then
  begin
    Error('Error in expression',s,errExprSyntax);
    Exit;
  end;

  if v<>'' then
  begin
    if arr1 and (not arr2) and (VarIndex(v)>=0) then
    begin
      arr1 := false;
      arr2 := true;
      ind2 := ind1;
    end;

    if not ValidName(V) then
    begin
      Error('Invalid variable name: '+v,CmdLine,errInvalidName);
      Exit;
    end;

    if arr1 then
    begin
      if VarIndex(v)>=0 then
      begin
        Error('Variable with same name exist : '+v,CmdLine,errNameDup);
        Exit;
      end;
      v := v + '['+ind1+']';
    end else
    begin
      if FindArray(v) then
      begin
        Error('Array with same name exist : '+v,CmdLine,errNameDup);
        Exit;
      end;
    end;

    R.Name := V;

    if not arr2 then SetVarDirect(R) else
    begin
      if not VarByName(v,RR) then
      begin
        Error('Variable not found :'+v,CmdLine,errVarNotFound);
        Exit;
      end;

      if not VarIsString(RR) then
      begin
        Error('Invalid variable type: '+v,CmdLine,errTypeCast);
        Exit;
      end;

      if ind2='' then
      begin
        Error('Empty string index',Expr,errIndexRange);
        Exit;
      end;

      if Pos(',',ind2)>0 then
      begin
        Error('Invalid string index',Expr,errIndexRange);
        Exit;
      end;

      try
        ind := StrToInt(ind2);
      except
        Error('Invalid string index : '+ind2,Expr,errIndexRange);
        Exit;
      end;

      if (ind>Length(string(RR.Value))) or (ind<1) then
      begin
        Error('String index out of range: '+ind2,CmdLine,errIndexRange);
        Exit;
      end;

      if not VarIsString(RR)  then
      begin
        if Length(string(R.Value))<>1 then
        begin
          Error('Character expected: '''+string(R.Value)+'''',CmdLine,errValueRange);
          Exit;
        end;
        s := string(RR.Value);
        s[ind] := string(R.Value)[1];
        RR.Value := s;
      end else
      begin
        try
          i := R.Value;
        except
          Error('Invalid variable type: '+v,CmdLine,errTypeCast);
          Exit;
        end;
        if (i<0) or (i>255) then
        begin
          Error('Character value out of range: '+IntToStr(i),CmdLine,errValueRange);
          Exit;
        end;
        s := string(RR.Value);
        s[ind] := chr(i);
        RR.Value := s;
      end;
      SetVarDirect(RR);
    end;
  end;
end;


procedure TPasCalc.DoIf(CmdLine,Line:string);
var
  R : TVar;
  i : integer;
  t : TToken;
  e : string;
  b : boolean;
begin
  i := 1;
  e := GetTokenLine(Line,i,t,[tTHEN]);

  if not Calc(e,R) then
  begin
    Error('Error in expression',e,errExprSyntax);
    Exit;
  end;

  try
    b := R.Value;
  except
    Error('Invalid condition type',e,errTypeCast);
    Exit;
  end;

  if not b then
  begin
    GetOperator(Line,i,[tSEMI,tELSE]);
    e := copy(Line,i,Length(Line));
  end else e := GetOperator(Line,i,[tSEMI,tELSE]);

  Exec(e);
end;


procedure TPasCalc.DoBegin(CmdLine,Line:string);
var
  s : string;
  i : integer;
begin
  s := Trim(Line);

  if s='' then
  begin
    Error(ResWords[tEND]+' expected',CmdLine,errEndExpected);
    Exit;
  end;

  i := Length(s)-Length(TokenStr(tEND,ResWords[tEND]));

  if not CmpStr(TokenStr(tEND,ResWords[tEND]),s,i-1,
                Length(TokenStr(tEND,ResWords[tEND]))) then
  begin
    s := copy(s,1,i);
    Exec(s);
  end else
  begin
    Error(ResWords[tEND]+' expected',CmdLine,errEndExpected);
    Exit;
  end;
end;


procedure TPasCalc.DoFor(CmdLine,Line:string);
var
  R : TVar;
  i,j : integer;
  t : TToken;
  ForInc : boolean;
  ForFrom, ForTo : integer;
  s,e,v : string;
begin
  i := 1;
  e := GetTokenLine(Line,i,t,[tTO,tDOWNTO]);

  if (t<>tTO) and (t<>tDOWNTO) then
  begin
    Error(ResWords[tTO]+' or '+ResWords[tDOWNTO]+' expected',CmdLine,errToExpected);
    Exit;
  end;

  ForInc := t=tTO;

  j := 1;
  v:=GetToken(e,j,t);
  if t<>tVR then
  begin
    Error(ResWords[tFOR]+' control variable expected',CmdLine,errForVar);
    Exit;
  end;

  s := GetToken(e,j,t);
  if (t=tEQU) and (ResWords[tEQU]=ResWords[tASSIGN]) then t := tASSIGN;

  if t<>tASSIGN then
  begin
    Error('Invalid орerator: '+s+' ('''+ResWords[tFOR]+''' expected ',CmdLine,errInvalidOp);
    Exit;
  end;

  e := Trim(copy(e,j,Length(e)));

  if not Calc(e,R) then
  begin
    Error('Error in expression',e,errExprSyntax);
    Exit;
  end;

  try
    ForFrom := R.Value;
  except
    Error('Invalid loop variable value ',e,errTypeCast);
    Exit;
  end;

  e := GetTokenLine(Line,i,t,[tDO]);

  if t<>tDO then
  begin
    Error(ResWords[tDO]+' expected',CmdLine,errDoExpected);
    Exit;
  end;

  e := Trim(e);

  if not Calc(e,R) then
  begin
    Error('Error in expression',e,errExprSyntax);
    Exit;
  end;

  try
    ForTo := R.Value;
  except
    Error('Invalid loop variable value ',e,errTypeCast);
    Exit;
  end;

  s := copy(Line,i,Length(Line));

  i := ForFrom;
  repeat
    if (ForInc and (i>ForTo))
    or ((not ForInc) and (i<ForTo)) then break;

    if not SetValue(v,i)then
    begin
      Error('Invalid variable name: '+v,CmdLine,errExprSyntax);
    end;

    Exec(s);
    if ErrCode<>errOK then break;

    Process;

    if BlockCmd<>tEMPTY then
    begin
      if (BlockCmd=tEXIT) or (BlockCmd=tGOTO) then break;
      if BlockCmd=tBREAK then
      begin
        BlockCmd := tEMPTY;
        break;
      end;
      if BlockCmd=tCONTINUE then BlockCmd := tEMPTY;
    end;
    if ForInc then inc(i) else dec(i);
  until False;
end;


procedure TPasCalc.DoBreak(CmdLine,Line:string);
var
  i : integer;
  t : TToken;
begin
  i := 1;
  GetToken(Line,i,t);
  if t<>tEMPTY then Error('Invalid '+ResWords[tBREAK]+' operator',CmdLine,errExprSyntax);
  BlockCmd := tBREAK;
end;


procedure TPasCalc.DoExit(CmdLine,Line:string);
var
  i : integer;
  t : TToken;
begin
  i := 1;
  GetToken(Line,i,t);
  if t<>tEMPTY then Error('Invalid '+ResWords[tEXIT]+' operator',CmdLine,errExprSyntax);
  BlockCmd := tEXIT;
end;


procedure TPasCalc.DoContinue(CmdLine,Line:string);
var
  i : integer;
  t : TToken;
begin
  i := 1;
  GetToken(Line,i,t);
  if t<>tEMPTY then Error('Invalid '+ResWords[tEXIT]+' operator',CmdLine,errExprSyntax);
  BlockCmd := tCONTINUE;
end;


procedure TPasCalc.DoWhile(CmdLine,Line:string);
var
  R : TVar;
  i : integer;
  t : TToken;
  s,e : string;
  b : boolean;
begin
  i := 1;
  e := GetTokenLine(Line,i,t,[tDO]);

  if t<>tDO then
  begin
    Error(ResWords[tDO]+' expected',CmdLine,errDoExpected);
    Exit;
  end;

  e := Trim(e);
  s := Trim(copy(Line,i,Length(Line)));

  repeat
    if not Calc(e,R) then
    begin
      Error('Error in expression',e,errExprSyntax);
      Exit;
    end;

    try
      b := R.Value;
    except
      Error('Invalid condition type',e,errTypeCast);
      Exit;
    end;

    if not b then break;

    Exec(s);
    if ErrCode<>errOK then break;

    Process;

    if BlockCmd<>tEMPTY then
    begin
      if (BlockCmd=tEXIT) or (BlockCmd=tGOTO) then break;
      if BlockCmd=tBREAK then
      begin
        BlockCmd := tEMPTY;
        break;
      end;
      if BlockCmd=tCONTINUE then BlockCmd := tEMPTY;
    end;
  until False;
end;


procedure TPasCalc.DoRepeat(CmdLine,Line:string);
var
  R : TVar;
  i : integer;
  t : TToken;
  s,e : string;
  b : boolean;
begin
  i := 1;
  s := GetTokenLine(Line,i,t,[tUNTIL]);

  if t<>tUNTIL then
  begin
    Error(ResWords[tUNTIL]+' expected',CmdLine,errUntilExpected);
    Exit;
  end;

  s := Trim(s);
  e := Trim(copy(Line,i,Length(Line)));

  repeat
    Exec(s);
    if ErrCode<>errOK then break;

    if not Calc(e,R) then
    begin
      Error('Error in expression',e,errExprSyntax);
      Exit;
    end;

    try
      b := R.Value;
    except
      Error('Invalid condition type',e,errTypeCast);
      Exit;
    end;

    if b then break;

    Process;

    if BlockCmd<>tEMPTY then
    begin
      if (BlockCmd=tEXIT) or (BlockCmd=tGOTO) then break;
      if BlockCmd=tBREAK then
      begin
        BlockCmd := tEMPTY;
        break;
      end;
      if BlockCmd=tCONTINUE then BlockCmd := tEMPTY;
    end;
  until False;
end;


procedure TPasCalc.DoGoto(CmdLine,Line:string);
var
  i : integer;
  s : string;
  t : tToken;
begin
  i := 1;
  s := GetToken(Line,i,t);
  if (t<>tVR) and (t<>tCON) or not IsAlpha(s) then
  begin
    Error('Invalid label in '+ResWords[tGOTO],CmdLine,errExprSyntax);
    Exit;
  end;

  GetToken(Line,i,t);
  if t<>tEMPTY then
  begin
    Error('Error in '+ResWords[tGOTO]+' statement',CmdLine,errExprSyntax);
    Exit;
  end;

  GotoLabel := s;
  BlockCmd  := tGOTO;
end;


procedure TPasCalc.DoCase(CmdLine,Line:string);

function CmpVar(const x1,x2:TVar; var Cmp:integer) : boolean;
begin
  Result := false;
  Cmp := 0;
  if VarIsString(x1) xor VarIsString(x2) then Exit;
  try
    if x1.Value>x2.Value then Cmp := 1;
    if x1.Value<x2.Value then Cmp := -1;
  except
    Exit;
  end;
  Result := true;
end;


var
  i,j,k : integer;
  t : tToken;
  R,V,V1,V2 : TVar;
  s,sOper,sCase,sElse,sRange : string;
  SL : TStringList;
begin
  i := 1;
  s := GetTokenLine(Line,i,t,[tOF]);

  if t<>tOF then
  begin
    Error(ResWords[tOF]+' expected',CmdLine,errDoExpected);
    Exit;
  end;

  if not Calc(s,R) then
  begin
    Error('Error in expression',s,errExprSyntax);
    Exit;
  end;

  SL := TStringlist.Create;

  sElse := '';
  repeat
    t := NextToken(Line,i);
    if t=tEND then break;
    if t=tEMPTY then
    begin
      Error('Error in '+ResWords[tCASE]+' statement',CmdLine,errExprSyntax);
      SL.Free;
      Exit;
    end;

    if t=tELSE then
    begin
      if sELSE<>'' then
      begin
        Error('Too many '+ResWords[tELSE]+'in '+ResWords[tCASE]+' statement',CmdLine,errManyElse);
        SL.Free;
        Exit;
      end;
      GetToken(Line,i,t);
      sElse := GetOperator(Line,i,[tSEMI]);
      continue;
    end;

    sRange := GetTokenLine(Line,i,t,[tLBL]);

    if t<>tLBL then
    begin
      Error(ResWords[tLBL]+' expected',CmdLine,errCaseRange);
      SL.Free;
      Exit;
    end;

    if sRange='' then
    begin
      Error('Range defininition expected',CmdLine,errCaseRange);
      SL.Free;
      Exit;
    end;

    sOper := GetOperator(Line,i,[tSEMI]);

    j := 1;
    SL.Text := GetFuncParams(TokenStr(tLBR,ResWords[tLBR])+sRange+
                             TokenStr(tRBR,ResWords[tRBR]),j);

    for k := 0 to SL.Count-1 do
    begin
      sCase := SL[k];

      j := 1;
      s := GetTokenLine(sCase,j,t,[tCOMMA2]);

      if t<>tCOMMA2 then
      begin
        if not Calc(s,V1) then
        begin
          Error('Error in expression',s,errExprSyntax);
          SL.Free;
          Exit;
        end;
        V2 := V1;
      end else
      begin
        if not Calc(s,V1) then
        begin
          Error('Error in expression',s,errExprSyntax);
          SL.Free;
          Exit;
        end;
        s := Trim(copy(sCase,j,Length(sCase)));
        if not Calc(s,V2) then
        begin
          Error('Error in expression',s,errExprSyntax);
          SL.Free;
          Exit;
        end;
      end;

      if not CmpVar(V1,V2,j) then
      begin
        Error('Invalid typecast in '+ResWords[tCASE]+' range',sCase,errExprSyntax);
        SL.Free;
        Exit;
      end;

      if j>0 then
      begin
        V  := V1;
        V1 := V2;
        V2 := V;
      end;

      if not (VarIsString(R) xor VarIsString(V1)) then
      begin
        CmpVar(V1,R,j);
        if j>0 then continue;
        CmpVar(R,V2,j);
        if j>0 then continue;
        Exec(sOper);
        SL.Free;
        Exit;
      end;
    end;

  until false;

  if sElse<>'' then Exec(sElse);
  SL.Free;
end;

end.
