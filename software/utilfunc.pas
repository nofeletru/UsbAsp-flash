unit utilfunc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function SetBit(const value: byte; const BitNum: byte): byte;
function ClearBit(const value: byte; const BitNum: byte): byte;
function IsBitSet(const value: DWORD; const BitNum : byte): boolean;
function BitNum(value: cardinal): integer;

function IsNumber(strSource: string): boolean;

implementation

function SetBit(const value: byte; const BitNum: byte): byte;
begin
  Result := value or (1 shl BitNum);
end;

function ClearBit(const value: byte; const BitNum: byte): byte;
begin
  Result := value and (not (1 shl BitNum));
end;

function IsBitSet(const value: DWORD; const BitNum : byte): boolean;
begin
  result:=((Value shr BitNum) and 1) = 1;
end;

//сколько бит нужно для хранения данного значения
function BitNum(value: cardinal): integer;
var
  i: integer;
  m: cardinal;
begin

  i:= 0;
  m:= 1;

  while m < value do
  begin
    m := m*2;
    Inc(i);
  end;

  result := i;
end;


function IsNumber(strSource: string): boolean;
begin
  try
    StrToInt(strSource);
    Result:=true;
  except
    on EConvertError do Result:=false;
  end;
end;

end.

