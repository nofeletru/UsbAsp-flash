   1. Описание
   -----------

   Модуль pascalc.dcu представляет собой интерпретатор Pascal - подобного
   языка для Delphi. Основные отличия его от стандартного Паскаля следующие:

 -  Для значений переменных используеися тип Variant, что позволяет хранить
    разнообразные типы данных.

 -  Переменные обьявлять не надо, они при небходимости создаются динамически
    при присваивании им значений. Тип определяется по последнему присвоенному
    значению, типовый контроль при присваивании не выполняется. То есть если
    существующей числовой переменной присвоить строку, ее тип изменится.
    Символам строки можно присваивать числовые значения в диапазоне 0..255 или
    символы (строки длиной 1).

 -  В выражениях поддерживаются следующие операции:
    арифметические: +, -, *, /, ^ (возведение в степень), SHL, SHR
    операции с битами: BITOR,BITAND,BITXOR,BITNOT
    логические: >, <, >=, <=, =, <>, AND, OR, NOT, константы TRUE и FALSE.
    Tакже можно использовать скобки. Порядок выполненния операций стандартный.

 -  В интерпретаторе поддерживаются операторы:
    BEGIN ... END
    IF ... THEN ... ELSE
    CASE
    FOR ... TO/DOWNTO ... DO
    WHILE ... DO
    REPEAT ... UNTIL
    CONTINUE
    BREAK
    GOTO
    EXIT
    USES
    INCLUDE

 -  Все зарезервированные слова объявлены в interface как массив строк.
    При желании вы можете изменить их на любые другие, например сделать
    русскими. Допускаются одинаковые операторы присваивания и равенства.
    Интерпретатор может сам различать их в зависимости от контекста. Все
    остальные зарезервированные слова должны отличаться друг от друга.

 -  Поддерживаются многомерные массивы, которые хранятся как набор переменных.
    Имена таких переменных состоят из имени массива и индексов в квадратных
    скобках. Имя массива должно быть уникальным, не допускается одновременное
    существование обычной переменной и переменной массива с тем же именем.
    (например переменная с именем MyArr и элемент массива MyArr[1]).
    Так как элементы массивов хранятся как обычные переменные, на них
    распространяются все правила применимые к обычным переменнм. Массивы не надо
    обьявлять, элементы одного массива могут хранить как строки так и числа.
    Для диапазона индексов массивов нет никаких ограничений. Непрерывность
    элементов массива также не обязательна. Чтобы создать непрерывную
    последовательность элементов массива им надо просто присвоить (например в цикле)
    какие - либо значения. Кроме того, к символам строк можно обращаться как к
    массиву символов. Так например MyArr[1][2] значит обрашение ко 2-му символу
    1-й строки массива MyArr. Запись MyArr[1] может значить либо первый символ
    обычной строковой переменной MyArr, либо первый элемент массива. Но так как
    элемент массива и переменная с таким же именем одновременно существовать не могут,
    неоднозначность не возникает.

 -  Все встроенные функции интерпретатора user-defined. Mодуль pasfunc.pas содержит
    библиотеку в которую включены аналоги многих функций Delphi. Пример ее
    использования есть в demo-программе. Вы можете использовать эту библиотеку,
    дополнив при необходимости любым количеством своих функций снужными вам
    параметрами. Параметры функций заранее не описываются, поэтому их количество
    и типы ничем не ограничены (подобно процедуре write паскаля). Интерпретатор
    вычисляет все параметры конкретного вызова и передает их функции как список
    значений. При необходимости вы можете реализовать типовый контроль внутри
    своей реализации функции. Если в качестве параметра функции передается
    переменная интерпретатора, этот пареметр считается VAR-параметром, и его
    изменение в коде функции вызовет изменение значения соответствующей переменной
    интерпретатора. Тип возвращаемого функцией значения тоже может быть разным при
    разных параметрах вызова. В модуле pasfunc.pas есть пример реализации таких
    функций (ф-ции Max, Min). Функции можно вызывать как процедуры, не используя
    возвращаемое значение.

 -  Поддерживаются процедуры и функции на языке интерпретатора. В списке параметров
    процедур и функций необходимо только перечислить имена формальных параметров.
    Типы параметров и способ передачи указывать не надо, также в объявлении функций
    не надо указывать тип возвращаемого значения. Для возврата значения функции
    используется переменная "result". Если в качестве параметра функции или процедуры
    передается глобальная переменная интерпретатора, этот параметр для данного вызова
    считается VAR-параметром и его изменение внутри функции изменит значение
    глобальной переменной. В то же время все глобальные переменные интерпретатора
    внутри функции или процедуры ведут себя, как локальные переменные, которым
    присвоены начальные значения совпадающие со значениями одноименных глобальных
    переменных. Их значения доступны в процедурах и функциях, их можно изменить,
    но после выхода из процедуры или функции значение глобальной переменной не
    изменится. Все новые переменные, созданные внутри процедур и функций являются
    локальными, и после выхода из процедуры/функции исчезнут. Таким образом, в
    процедурах и функциях можно использовать любые имена для локальных переменных,
    не опасаясь что они совпадут с именами глобальных переменных.

    Для реализации библиотек процедур можно использовать операторы USES и INCLUDE.
    Их синтаксис :  USES 'имя файла';
                    INCLUDE 'имя файла';

    Операторы USES и INCLUDE обрабатываются препроцессором, до начала выполнения
    скрипта. Оператор INCLUDE вставляет в скрипт текст из файла. Оператор USES
    только загружает реализации процедур и функций, чтобы их можно было
    использовать при выполнении скрипта.


   2. Лицензия.
   ------------

   Интерпретатор PASCALC распространяется по принципу "как есть". 
   При этом не предусматривается никаких гарантий, явных или подразумеваемых. 
   Вы используете его на свой собственный риск. Автор не отвечает за потери
   данных, повреждения, потери прибыли или любые другие виды потерь, связанные
   с использованием (правильным или неправильным) этого программного продукта.

   http://alexboiko.da.ru
   http://alexboiko.chat.ru


   3. Интерфейс модуля интерпретатора:
   -----------------------------------

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


   4. Функции (unit PASFUNC.PAS)
   ------------------------------

   // Функции для работы со строками

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

   // Функции для работы с датой и временем

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

   // Математические функции

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

   // Функции PASCALC для работы с переменными.
   // Позволяют обращаться к переменной по вычисляемому имени.

   SetVar
   GetVar


   5. Использование интерпретатора
   -------------------------------

   Пример использования есть в demo-программе. В скриптах интерпретатора вы
   можете использовать готовую библиотеку функций из модуля pasfunc.pas, или
   напиcать собственную реализацию нужных вам функций, которых нет в библиотеке.
   Функция должна записать результат в поле Value переменной R:TVar и вернуть true.
   В случае ошибки (например при вызове с недопустимыми параметрами) функция
   должна вернуть false.

   Потом создайте экземпляр класса TPasCalc. С помошью метода SetProcessProc
   можно задать указатель на процедуру которая будет регулярно вызываться в
   циклах интерпретатора. С ее помощью можно например реализовать таймаут.
   Если вы задали такую процедуру, то в ней стоит предусмотреть вызов обработчика
   сообщений (Application.ProcessMessages например). Если ее не задали, то вместо
   нее будет использоваться метод Process, в котором предусмотрена обработка сообщений.

   Затем вызовами TPasCalc.SetFunction надо зарегистрировать функции которые вы
   хотите использовать и задать им имена. В модуле pasfunc.pas регистрация делается
   вызовом процедуры SetFunctions. Также можно задать предопределенные переменные
   вызовами SetVarNum или SetVarStr.

   Метод Calculate вычисляет значение математического выражения и возвращает
   результат в переменной R:TVar, а метод Execute выполняет текст скрипта и
   заполняет список переменных. С помощью методов VarCount, VarByIndex или
   VarByName вы можете получить их значения. При возникновении ошибок их код
   возврашается в ErrCode. В ErrMsg и ErrLine возвращается сообщение об ошибке
   и строка ее вызвавшая.

   При следуюших вызовах Calculate и Execute список переменных не очищается и
   их значения можно использовать в выражениях. При желании вы можете сами
   очистить список переменных вызвав ClearVars. Очистить список функций можно с
   помощью ClearFuncs. Если возникла необходимость принудительно прервать
   интерпретацию, надо присвоить значение true перменной TPasCalc.Stop.

   Чтобы ускорить выполнение скриптов их можно предварительно подготовить
   с помощью метода Parse, который возвращает разобранную строку.
   Ее можно сохранить и затем выполнять теми же методами Calculate и Execute.


   6. Коды ошибок (ErrCode)
   ------------------------

   0  -  O.K.
   1  -  ошибка в выражении
   2  -  непарные скобки
   3  -  переменная не найдена
   4  -  недопустимое имя переменной или функции
   5  -  неверный тип операнда
   6  -  невернaя строковая константе
   7  -  неверный вызов функции
   8  -  функция не найдена
   9  -  неизвестный оператор
   10 -  нехватает END
   11 -  лишний END
   12 -  нехватает TO или DOWNTO
   13 -  нет переменной цикла
   14 -  нехватает DO
   15 -  BREAK вне цикла
   16 -  нехватает UNTIL
   17 -  лишний UNTIL
   18 -  метка не найдена
   19 -  индекс за границей диапазона
   20 -  значение за границей диапазона
   21 -  нехватает ']'
   22 -  нехватает '['
   23 -  деление на 0
   24 -  Дублируется имя переменной/массива
   25 -  Ошибка открытия файла
   26 -  Функция должна возвращать значение
   27 -  нет OF в операторе CASE
   28 -  несколько ELSE в операторе CASE
   29 -  неверный диапазон значений в операторе CASE


   7. Автор:
   ---------

   Алексей Бойко
   alexboiko@mtu-net.ru
   http://alexboiko.da.ru
