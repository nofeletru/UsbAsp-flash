
   1. Description
   -------------------

   The module PASCALC.DCU is the Pascal-like language interpreter for Delphi.
   The basic differences from standard Pascal the following:

 - All variables stored as variants.

 - It's no need to declare variables, labels and functions. PASCALC creates
   variables dynamically on first assignment. Variable type depends on the
   last value assigned, type checking is not carried out.

 - Expressions syntax:

   Arithmetic operators: +, -, *, /, ^ (power), SHL, SHL
   Bitwise operators:    BITOR,BITAND,BITXOR,BITNOT
   Logical operators:    >, <, >=, <=, =, <>, AND, OR, NOT,
                         constants TRUE and FALSE.
   Operators precedence standard, you can use parentheses.


 - Statements supported:
    BEGIN... END
    IF... THEN... ELSE
    CASE
    FOR... TO/DOWNTO... DO
    WHILE... DO
    REPEAT... UNTIL
    BREAK
    CONTINUE
    GOTO
    EXIT
    USES
    INCLUDE

 - All reserved words are declared in interface section as string array.
   You can change them to anyone others. All identifiers should be different
   (except assignment and equation, they may be the same).

 - Multi-dimensional arrays supported. Array items are variables whose names
   consist from array name and indexes (in brackets). Array items properties
   same as the simple variables. It's no need to declare arrays. Array index
   continuity is not requred. It's possible to access string as char array.
   You can assign chars or numbers in range 0..255 to string characters.
   Array name should be unique, simple variable MyArr and array item MyArr[1]
   can't exist at the same time. This rule allows to distinguish access to
   1-st character of string variable MyArr (MyArr[1]) from the accees to
   the first item of array MyArr. To access character of string array item,
   character index should be written in brackets after item name, for example
   MyArr[1,2][3].

 - All build-in functions are user-defined. Module pasfunc.pas contain
   example of PASCALC implementations for common Delphi functions. You can use
   this functions and write your own implementations for necessary functions.
   There is no need to declare parameters for user-defined functions, therefore
   it's types and amount are not limited. If necessary you can provide type
   checking inside function code. Interpreter calculates all parameter values
   and creates temporary values list (TVarList). Names of var-parameters in this
   list are 'VAR', otherwise 'VALUE'. After function call interpreter updates
   values for var-parameters. Function result type not checked, one function can
   return number as well as string. Functions can be called as procedures (without
   result usage).

 - Procedures and functions (in sense of the subroutines on interpreter language)
   are supported. The function heading specifies only names of formal parameters,
   without parameters types and pass method (var or value). Also, function's result
   types are not declared. To return function result you should assign value to
   variable "result".

   If actual parameter is variable (not expression), it considered as var-parameter.
   In this case assigning new value to this parameter inside procedure or function
   will affect the actual parameter variable.

   At the same time, all interpreter global variables inside a function or procedures
   looks like local variables, with the same initial values as global ones.
   You can change this values inside procedures (functions), but it's don't affect
   the global variables. All new variables created inside procedures and functions
   are local, and will be destroyed after exiting.
   Therefore, it is possible to use any names for local variables, without conflicts
   with the global variables.

   For libraries implementation, it is possible to use operators USES and INCLUDE.

   Syntax: USES 'filename';
           INCLUDE 'filename';

   INCLIDE and USES are parsed by pre-processor before script execution.
   INCLUDE inserts text from file 'filename' into the script, USES loads
   procedures and functions declarations.


   2. License
   ----------

   This software is provided as it is, without any kind of warranty given.
   The author can not be held responsible for any kind of damage, problems etc,
   arised from using this software. PASCALC interpreter is shareware product.
   Unregistered version has no time or functionality limitations, but can
   show info screen.

   If you want get source code, you should register PASCALC and get registration code.
   Use your registration code as password for source archive (Source\pascsrc.zip).

   Address for online registration (price $20):
   https://www.regnow.com/softsell/nph-softsell.cgi?item=2608-2

   You can modify PASCALC source code as you need, distribute executable files
   compiled with PASCALC source. But you can't distribute original or modified
   PASCALC source code, .DCU units or libraries based on PASCALC source code.


   3. PASCALC inteface
   -------------------


unit pascalc;

{$F+,B-,R-}

interface

uses
  Windows, Messages, SysUtils, Classes, Math;

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
  Alpha          : set of char = ['_','0'..'9','a'..'z','A'..'Z','à'..'ÿ','¸','À'..'ß','¨'];
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



   4. Functions (unit PASFUNC.PAS)
   ------------------------------

   // String functions

   Val
   IntToStr
   StrToInt
   FloatToStr
   StrToFloat
   Copy
   Pos
   Length
   Insert
   Delete
   Trim
   TrimLeft
   TrimRight
   UpperCase
   LowerCase
   Format

   // DateTime functions

   Now
   Date
   Time
   DateToStr
   StrToDate
   TimeToStr
   StrToTime
   FormatDateTime
   DayOfWeek
   IncMonth
   DecodeDate
   DecodeTime
   EncodeDate
   EncodeTime
   YearDays
   YearFrac

   // Math functions
   Abs
   Int
   Frac
   Round
   Ceil
   Floor
   Trunc
   Sin
   Cos
   Tan
   ArcSin
   ArcCos
   ArcTan
   Exp
   Ln
   IntPower
   Sqr
   Sqrt
   Min
   Max
   Inc
   Dec

   // Variable handling functions.
   // Allows get or set variable value by calculated variable name.

   SetVar
   GetVar

   // Misc functions

   Decode (simular with the Oracle Decode function)


   5. Interpreter usage
   --------------------

   See usage example in demo program (demo.dpr). At first you should write
   user-defined functions you want to use in scripts and expressions. Function
   should set result value (field Value of variable R:TVar) and return true.
   On errors (wrong  parameters, etc) function should return false. In your
   program you should create an instance of TPasCalc class.
   Then associate functions with names (TPasCalc.SetFunction).
   To register pasfunc.pas function library, call SetFunctions.
   You can set predefined variables (TPasCalc.SetVarNum or TPasCalc.SetVarStr).
   Method TPasCalc.Calculate evaluates expression and returns result in variable
   R:TVar. Method TPasCalc.Execute executes script and fills variable list.
   You can access variables using TPasCalc.VarCount, TPasCalc.VarByIndex or
   TPasCalc.VarByName methods. TPasCalc.ErrCode, TPasCalc.ErrMsg and
   TPasCalc.ErrLine indicates last error code, error message and line that
   raises error. Variable list not cleared in Calculate and Execute methods.
   You can reset all variables using TPasCalc.ClearVars. TPasCalc.ClearFuncs
   resets function list. Method TPasCalc.SetProcessProc sets pointer to
   user-defined callback procedure. Interpreter calls this procedure in internal
   cycles. In this procedure you can check some condition (timeout for example)
   and break execution by assigning TPasCalc.Stop:=TRUE. It is useful to call
   Application.ProcessMessages in this procedure. If callback procedure not
   assigned, interpreter uses Process method instead. Process method performs
   only messages processing.
   To improve perfomance you can prepare script using Parse method, and then
   execute previously prepared script.


   6. Error codes
   --------------

   0  - O.K.
   1  - Error in expression
   2  - Unpaired parentheses
   3  - Variable not found
   4  - Invalid variable/function/procedure name
   5  - Invalid typecast
   6  - Invalid string constant
   7  - Incorrect function call
   8  - Function not found
   9  - Invalid operator
   10 - END expected
   11 - Too many END
   12 - TO or DOWNTO expected
   13 - FOR-loop variable expected
   14 - DO expected
   15 - BREAK outside a loop
   16 - UNTIL expected
   17 - Too many UNTIL
   18 - Label not found
   19 - Index out of range
   20 - Value out of range
   21 - ']' expected
   22 - Too many '['
   23 - Division by zero
   24 - Variable or array name duplicated
   25 - File îpen error
   26 - Function must return result
   27 - CASE without OF
   28 - Too many ELSE in CASE statement
   29 - Case range expected


   7. Author
   ---------

   Alex Boiko
   alexboiko@mtu-net.ru
   http://alexboiko.da.ru
   http://alexboiko.chat.ru
