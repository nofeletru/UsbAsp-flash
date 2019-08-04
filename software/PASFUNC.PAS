{$B-}
{$mode delphi}
unit pasfunc;

interface

uses SysUtils, Math, PasCalc, Variants;

procedure SetFunctions(PC : TPasCalc);

implementation


function VarIsString(V : TVar) : boolean;
var t: integer;
begin
  t := VarType(V.Value);
  Result := (t=varString) or (t=varOleStr);
end;


function fFloatToStr(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  s : string;
  x: float;
begin
  Result := false;
  if A.Count<>1 then Exit;
  x := TPVar(A.Items[0])^.Value;
  Str(x:0:15,s);
  while s[Length(s)]='0' do s := copy(s,1,Length(s)-1);
  if s[Length(s)]='.' then s := copy(s,1,Length(s)-1);
  R.Value := s;
  Result := true;
end;


function fIntToStr(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  i : integer;
  s : string;
begin
  Result := fFloatToStr(Sender,A,R);
  if Result then
  begin
    s := string(R.Value);
    i := Pos('.',s);
    if i>0 then R.Value := copy(s,1,i-1);
  end;
end;


function fStrToFloat(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  i : integer;
  x : extended;
begin
  Result := false;
  if A.Count<>1 then Exit;
  Val(Trim(TPVar(A.Items[0])^.Value),x,i);
  if i<>0 then Exit;
  R.value := x;
  Result := true;
end;


function fStrToInt(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var i : integer;
begin
  Result := false;
  if A.Count<>1 then Exit;
  i := StrToInt(TPVar(A.Items[0])^.Value);
  R.value := i;
  Result := true;
end;


function fVal(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  x : extended;
  i : integer;
begin
  Result := false;

  if (A.Count<>3)
  or (TPVar(A.Items[1])^.Name<>'VAR')
  or (TPVar(A.Items[2])^.Name<>'VAR') then Exit;

  Val(TPVar(A.Items[0])^.Value,x,i);

  TPVar(A.Items[1])^.Value := x;
  TPVar(A.Items[2])^.Value := i;
  Result := true;
end;


function fCopy(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>3 then Exit;

  R.Value := copy(TPVar(A.Items[0])^.Value,
                  Trunc(TPVar(A.Items[1])^.Value),
                  Trunc(TPVar(A.Items[2])^.Value));

  Result := true;
end;


function fPos(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>2 then Exit;
  R.Value := Pos(TPVar(A.Items[0])^.Value, TPVar(A.Items[1])^.Value);
  Result := true;
end;


function fLength(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Length(TPVar(A.Items[0])^.Value);
  Result := true;

end;


function fInsert(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var s : widestring;
begin
  Result := false;

  if (A.Count<>3)
  or (TPVar(A.Items[1])^.Name<>'VAR') then Exit;

  s := TPVar(A.Items[1])^.Value;
  Insert(TPVar(A.Items[0])^.Value,s,Trunc(TPVar(A.Items[1])^.Value));
  TPVar(A.Items[1])^.Value := s;
  R.Value := s;
  Result := true;
end;


function fDelete(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var s : string;
begin
  Result := false;

  if (A.Count<>3)
  or (TPVar(A.Items[0])^.Name<>'VAR') then Exit;


  s := TPVar(A.Items[0])^.Value;
  Delete(s,Trunc(TPVar(A.Items[1])^.Value),Trunc(TPVar(A.Items[1])^.Value));
  TPVar(A.Items[0])^.Value := s;

  R.Value := s;
  Result := true;
end;


function fTrim(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Trim(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fTrimLeft(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := TrimLeft(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fTrimRight(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  Result := true;
  R.Value := TrimRight(TPVar(A.Items[0])^.Value);
  
end;


function fUpperCase(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  Result := true;
  R.Value := AnsiUpperCase(TPVar(A.Items[0])^.Value);
  
end;


function fLowerCase(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  Result := true;
  R.Value := AnsiLowerCase(TPVar(A.Items[0])^.Value);
  
end;


function fFormat(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  i,n : integer;
  ff : boolean;
  fs,s,fmt : string;
begin
  Result := false;
  if (A.Count<2)  then Exit;
  Result := true;
  s:=''; fmt:=''; ff:=false; n:=0;
  fs := TPVar(A.Items[0])^.Value;
  for i := 1 to Length(fs) do
  begin
    if fs[i]='%' then ff := true;
    if ff then fmt := fmt + fs[i] else s := s + fs[i];
    if ff and (fs[i] in ['A'..'Z','a'..'z']) then
    begin
      ff := false;
      inc(n);
      if n<A.Count then
      begin
        if not VarIsString(TPVar(A.Items[n])^) then
        begin
          try
            s := s + Format(fmt,[TPVar(A.Items[n])^.Value]);
          except
            s := s + Format(fmt,[Trunc(TPVar(A.Items[n])^.Value)]);
          end;
        end else s := s + Format(fmt,[TPVar(A.Items[n])^.Value]);
      end;
      fmt := '';
    end;
  end;
  R.Value := s+fmt;
  
end;


function fDateToStr(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := DateToStr(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fStrToDate(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1  then Exit;
  R.Value := StrToDate(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fFormatDateTime(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>2 then Exit;
  R.Value := FormatDateTime(TPVar(A.Items[0])^.Value, TPVar(A.Items[1])^.Value);
  Result := true;
end;


function fNow(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>0 then Exit;
  Result := true;
  R.Value  := Now;
  
end;


function fDate(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>0 then Exit;
  Result := true;
  R.Value  := Date;
  
end;


function fTime(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>0 then Exit;
  Result := true;
  R.Value  := Time;
  
end;


function fStrToTime(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := StrToTime(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fTimeToStr(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := TimeToStr(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fDayOfWeek(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  Result := true;
  R.Value := DayOfWeek(TPVar(A.Items[0])^.Value);
  
end;


function fIncMonth(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>2 then Exit;
  R.Value := IncMonth(TPVar(A.Items[0])^.Value,Trunc(TPVar(A.Items[1])^.Value));
  Result := true;
end;


function fDecodeDate(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  i : integer;
  D,M,Y : word;
begin
  Result := false;
  if A.Count<>4 then Exit;
  for i := 1 to 3 do if TPVar(A.Items[i])^.Name<>'VAR' then Exit;
  DecodeDate(TPVar(A.Items[0])^.Value,Y,M,D);
  TPVar(A.Items[1])^.Value := Y;
  TPVar(A.Items[2])^.Value := M;
  TPVar(A.Items[3])^.Value := D;
  R.Value := TPVar(A.Items[0])^.Value;
  Result := true;
end;


function fDecodeTime(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  i : integer;
  H,M,S,MS : word;
begin
  Result := false;
  if A.Count<>5 then Exit;
  for i := 1 to 4 do if TPVar(A.Items[i])^.Name<>'VAR' then Exit;
  DecodeTime(TPVar(A.Items[0])^.Value,H,M,S,MS);
  TPVar(A.Items[1])^.Value := H;
  TPVar(A.Items[2])^.Value := M;
  TPVar(A.Items[3])^.Value := S;
  TPVar(A.Items[4])^.Value := MS;
  R.Value := TPVar(A.Items[0])^.Value;
  Result := true;
end;


function fEncodeDate(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>3 then Exit;
  R.Value := EncodeDate(Trunc(TPVar(A.Items[0])^.Value),
                      Trunc(TPVar(A.Items[1])^.Value),
                      Trunc(TPVar(A.Items[2])^.Value));
  Result := true;
end;


function fEncodeTime(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>4 then Exit;
  R.Value := EncodeTime(Trunc(TPVar(A.Items[0])^.Value),
                      Trunc(TPVar(A.Items[1])^.Value),
                      Trunc(TPVar(A.Items[2])^.Value),
                      Trunc(TPVar(A.Items[3])^.Value));
  Result := true;
end;


function fSin(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Sin(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fCos(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Cos(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fTan(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Tan(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fArcSin(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := ArcSin(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fArcCos(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := ArcCos(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fArcTan(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := ArcTan(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fExp(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Exp(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fLn(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Ln(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fIntPower(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>2 then Exit;
  R.Value := IntPower(TPVar(A.Items[0])^.Value,Trunc(TPVar(A.Items[1])^.Value));
  Result := true;
end;


function fSqr(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Sqr(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fSqrt(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Sqrt(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fAbs(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Abs(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fInt(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Int(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fFrac(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Frac(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fRound(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Integer(Round(TPVar(A.Items[0])^.Value));
  Result := true;
end;


function fTrunc(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Integer(Trunc(TPVar(A.Items[0])^.Value));
  Result := true;
end;


function fCeil(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Ceil(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fFloor(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if A.Count<>1 then Exit;
  R.Value := Floor(TPVar(A.Items[0])^.Value);
  Result := true;
end;


function fMax(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  i : integer;
  N : string;
begin
  Result := false;
  if A.Count=0 then Exit;

  N := R.Name;
  R := TPVar(A.Items[0])^;
  R.Name := N;

  for i:=0 to A.Count-1 do
  begin
    if VarType(R.Value)<>VarType(TPVar(A.Items[i])^.Value) then Exit;
    if TPVar(A.Items[i])^.Value>R.Value then R.Value := TPVar(A.Items[i])^.Value;
  end;
  Result := true;
end;


function fMin(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  i : integer;
  N : string;
begin
  Result := false;
  if A.Count=0 then Exit;

  N := R.Name;
  R := TPVar(A.Items[0])^;
  R.Name := N;

  for i:=0 to A.Count-1 do
  begin
    if VarType(R.Value)<>VarType(TPVar(A.Items[i])^.Value) then Exit;
    if TPVar(A.Items[i])^.Value<R.Value then R.Value := TPVar(A.Items[i])^.Value;
  end;
  Result := true;
end;


function fInc(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if (A.Count<1) or (A.Count>2) then Exit;
  if A.Count=1
  then TPVar(A.Items[0])^.Value:=TPVar(A.Items[0])^.Value+1
  else TPVar(A.Items[0])^.Value:=TPVar(A.Items[0])^.Value+TPVar(A.Items[1])^.Value;
  Result:=true;
end;


function fDec(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  Result := false;
  if (A.Count<1) or (A.Count>2) then Exit;
  if A.Count=1
  then TPVar(A.Items[0])^.Value:=TPVar(A.Items[0])^.Value-1
  else TPVar(A.Items[0])^.Value:=TPVar(A.Items[0])^.Value-TPVar(A.Items[1])^.Value;
  Result:=true;
end;


function fSetVar(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  s : string;
begin
  // Set simple variable (not array) value
  Result := false;
  if A.Count<>2  then Exit;
  s := AnsiUpperCase(TPVar(A.Items[0])^.Value);
  Result := (Sender as TPasCalc).SetValue(s,TPVar(A.Items[1])^.Value);
end;


function fGetVar(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
begin
  // Get variable value
  Result := false;
  if (A.Count<>1) then Exit;
  Result := (Sender as TPasCalc).VarByName(AnsiUpperCase(TPVar(A.Items[0])^.Value),R);
end;


function fDecode(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  i : integer;
  N : string;
  X : TVar;
begin
  Result := false;
  if A.Count<3 then Exit;

  X := TPVar(A.Items[0])^;
  N := R.Name;

  i := 1;
  while i<A.Count-1 do
  begin
    if TPVar(A.Items[i])^.Value=X.Value then
    begin
      R := TPVar(A.Items[i+1])^;
      R.Name := N;
      Result :=true;
      Exit;
    end;
    i := i + 2;
  end;
  if not Odd(A.Count) then
  begin
    R := TPVar(A.Items[A.Count-1])^;
    R.Name := N;
    Result := true;
  end;
end;


function fYearDays(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var y,m,d : word;
begin
  Result := false;
  if A.Count<>1 then Exit;
  DecodeDate(TPVar(A.Items[0])^.Value,y,m,d);
  if IsLeapYear(y) then R.Value := 366 else R.Value := 365;
  Result := true;
end;


function fYearFrac(Sender:TObject; var A:TVarList; var R:TVar) : boolean;
var
  x : extended;
  dt1,dt2,ds,de : TDateTime;
  y1,m1,d1,
  y2,m2,d2,i,n : word;
begin
  Result := false;
  if A.Count<>2 then Exit;

  dt1 := TPVar(A.Items[0])^.Value;
  dt2 := TPVar(A.Items[1])^.Value;

  if dt1>dt2 then
  begin
    dt1 := dt2;
    dt2 := TPVar(A.Items[0])^.Value;
  end;

  DecodeDate(dt1,y1,m1,d1);
  DecodeDate(dt2,y2,m2,d2);

  x := 0;
  for i := y1 to y2 do
  begin
    if i=y1 then ds := dt1 else ds := EncodeDate(i,1,1);
    if i=y2 then de := dt2 else de := EncodeDate(i+1,1,1);
    if IsLeapYear(i) then n := 366 else n := 365;
    x := x + (de-ds)/n;
  end;

  R.Value := x;
  Result := true;
end;


procedure SetFunctions(PC : TPasCalc);
begin
  // String routines
  PC.SetFunction('Val',            @fVal);
  PC.SetFunction('IntToStr',       @fIntToStr);
  PC.SetFunction('StrToInt',       @fStrToInt);
  PC.SetFunction('FloatToStr',     @fFloatToStr);
  PC.SetFunction('StrToFloat',     @fStrToFloat);
  PC.SetFunction('Copy',           @fCopy);
  PC.SetFunction('Pos',            @fPos);
  PC.SetFunction('Length',         @fLength);
  PC.SetFunction('Insert',         @fInsert);
  PC.SetFunction('Delete',         @fDelete);
  PC.SetFunction('Trim',           @fTrim);
  PC.SetFunction('TrimLeft',       @fTrimLeft);
  PC.SetFunction('TrimRight',      @fTrimRight);
  PC.SetFunction('UpperCase',      @fUpperCase);
  PC.SetFunction('LowerCase',      @fLowerCase);
  PC.SetFunction('Format',         @fFormat);

  // Date/time routines
  PC.SetFunction('Now',            @fNow);
  PC.SetFunction('Date',           @fDate);
  PC.SetFunction('Time',           @fTime);
  PC.SetFunction('DateToStr',      @fDateToStr);
  PC.SetFunction('StrToDate',      @fStrToDate);
  PC.SetFunction('TimeToStr',      @fTimeToStr);
  PC.SetFunction('StrToTime',      @fStrToTime);
  PC.SetFunction('FormatDateTime', @fFormatDateTime);
  PC.SetFunction('DayOfWeek',      @fDayOfWeek);
  PC.SetFunction('IncMonth',       @fIncMonth);
  PC.SetFunction('DecodeDate',     @fDecodeDate);
  PC.SetFunction('DecodeTime',     @fDecodeTime);
  PC.SetFunction('EncodeDate',     @fEncodeDate);
  PC.SetFunction('EncodeTime',     @fEncodeTime);

  // Arithmetic routines
  PC.SetFunction('Abs',            @fAbs);
  PC.SetFunction('Int',            @fInt);
  PC.SetFunction('Frac',           @fFrac);
  PC.SetFunction('Round',          @fRound);
  PC.SetFunction('Ceil',           @fCeil);
  PC.SetFunction('Floor',          @fFloor);
  PC.SetFunction('Trunc',          @fTrunc);
  PC.SetFunction('Sin',            @fSin);
  PC.SetFunction('Cos',            @fCos);
  PC.SetFunction('Tan',            @fTan);
  PC.SetFunction('ArcSin',         @fArcSin);
  PC.SetFunction('ArcCos',         @fArcCos);
  PC.SetFunction('ArcTan',         @fArcTan);
  PC.SetFunction('Exp',            @fExp);
  PC.SetFunction('Ln',             @fLn);
  PC.SetFunction('IntPower',       @fIntPower);
  PC.SetFunction('Sqr',            @fSqr);
  PC.SetFunction('Sqrt',           @fSqrt);
  PC.SetFunction('Inc',            @fInc);
  PC.SetFunction('Dec',            @fDec);

  // PASCALC functions
  PC.SetFunction('Min',            @fMin);
  PC.SetFunction('Max',            @fMax);
  PC.SetFunction('GetVar',         @fGetVar);
  PC.SetFunction('SetVar',         @fSetVar);
  PC.SetFunction('Decode',         @fDecode);
  PC.SetFunction('YearDays',       @fYearDays);
  PC.SetFunction('YearFrac',       @fYearFrac);
end;

end.


