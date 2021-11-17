unit BaseHW;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

//List of devices
THardwareList = (CHW_NONE, CHW_CH341, CHW_AVRISP, CHW_USBASP, CHW_ARDUINO, CHW_FT232H);

//Base class for hardware
TBaseHardware = class
protected
  FHardwareName: string;
  FHardwareID: THardwareList;
public
  property HardwareName: string read FHardwareName write FHardwareName;

  function GetLastError: string; virtual; abstract;
  function DevOpen: boolean; virtual; abstract;
  procedure DevClose; virtual; abstract;

  //SPI
  function SPIInit(speed: integer): boolean; virtual; abstract;
  procedure SPIDeinit; virtual; abstract;
  function SPIRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer; virtual; abstract;
  function SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer; virtual; abstract;

  //I2C
  procedure I2CInit; virtual; abstract;
  procedure I2CDeinit; virtual; abstract;
  function I2CReadWrite(DevAddr: byte;
                        WBufferLen: integer; WBuffer: array of byte;
                        RBufferLen: integer; var RBuffer: array of byte): integer; virtual; abstract;
  //
  procedure I2CStart; virtual; abstract;
  procedure I2CStop; virtual; abstract;
  function I2CReadByte(ack: boolean): byte; virtual; abstract;
  function I2CWriteByte(data: byte): boolean; virtual; abstract; //return ack

  //MICROWIRE
  function MWInit(speed: integer): boolean; virtual; abstract;
  procedure MWDeinit; virtual; abstract;
  function MWRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer; virtual; abstract;
  //return number of bits written
  function MWWrite(CS: byte; BitsWrite: byte; buffer: array of byte): integer; virtual; abstract;
  function MWIsBusy: boolean; virtual; abstract;
end;

//Class for manipulating hw
TAsProgrammer = class
private
  FCurrent_HW : THardwareList;
  FCurrent_prog: TBaseHardware;
  FHwList: TList;

  procedure SetProgrammer(HW: THardwareList);
public
  constructor Create;
  destructor Destroy; Override;

  procedure AddHW(HW: pointer);

  property Current_HW : THardwareList read FCurrent_HW write SetProgrammer;
  property Programmer : TBaseHardware read FCurrent_prog;
end;

implementation

constructor TAsProgrammer.Create;
begin
  FCurrent_HW := CHW_NONE;
  FHwList := TList.Create;
end;

destructor TAsProgrammer.Destroy;
var
  i: integer;
begin
  for i := 0 to FHwList.Count-1 do
    TBaseHardware(FHwList.Items[i]).Free;
  FHwList.Free;
end;

procedure TAsProgrammer.AddHW(HW: pointer);
begin
  FHwList.Add(HW);
end;

procedure TAsProgrammer.SetProgrammer(HW: THardwareList);
var
  i: integer;
begin
  FCurrent_HW := CHW_NONE;
  FCurrent_prog := nil;
  for i :=0 to FHwList.Count-1 do
  begin
    if TBaseHardware(FHwList.Items[i]).FHardwareID = HW then
      begin
        FCurrent_prog := TBaseHardware(FHwList.Items[i]);
        FCurrent_HW := HW;
      end;
  end;
end;

end.

