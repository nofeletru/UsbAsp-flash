unit ch341hw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, basehw, msgstr, ch341dll, utilfunc;

type

{ TCH341Hardware }

TCH341Hardware = class(TBaseHardware)
private
  FDevOpened: boolean;
  FDevHandle: Longint;
  FStrError: string;
public
  constructor Create;
  destructor Destroy; override;

  function GetLastError: string; override;
  function DevOpen: boolean; override;
  procedure DevClose; override;

  //spi
  function SPIRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer; override;
  function SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer; override;
  function SPIInit(speed: integer): boolean; override;
  procedure SPIDeinit; override;

  //I2C
  procedure I2CInit; override;
  procedure I2CDeinit; override;
  function I2CReadWrite(DevAddr: byte;
                        WBufferLen: integer; WBuffer: array of byte;
                        RBufferLen: integer; var RBuffer: array of byte): integer; override;
  function I2CLineIsBusy(DevAddr: byte): boolean; override;

  //MICROWIRE
  function MWInit(speed: integer): boolean; override;
  procedure MWDeinit; override;
  function MWRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer; override;
  function MWWrite(CS: byte; BitsWrite: byte; buffer: array of byte): integer; override;
  function MWIsBusy: boolean; override;
end;

implementation


constructor TCH341Hardware.Create;
begin
  FDevHandle := -1;
  FHardwareName := 'CH341';
  FHardwareID := CHW_CH341;
end;

destructor TCH341Hardware.Destroy;
begin
  DevClose;
end;

function TCH341Hardware.GetLastError: string;
begin
  result := FStrError;
end;

function TCH341Hardware.DevOpen: boolean;
var
  i, err: integer;
begin
  if FDevOpened then DevClose;

   for i:=0 to mCH341_MAX_NUMBER-1 do
    begin
      err := CH341OpenDevice(i);
      if not err < 0 then
      begin
        FDevHandle := i;
        Break;
      end;
    end;

    if err < 0 then
    begin
      FStrError :=  STR_CONNECTION_ERROR+ FHardwareName +'('+IntToStr(err)+')';
      FDevHandle := -1;
      FDevOpened := false;
      Exit(false);
    end;

  FDevOpened := true;
  Result := true;
end;

procedure TCH341Hardware.DevClose;
begin
  if FDevHandle > 0 then
  begin
    CH341CloseDevice(FDevHandle);
    FDevHandle := -1;
    FDevOpened := false;
  end;
end;


//SPI___________________________________________________________________________

function TCH341Hardware.SPIInit(speed: integer): boolean;
begin
  if not FDevOpened then Exit(false);
  Result := CH341SetStream(FDevHandle, %10000001);
end;

procedure TCH341Hardware.SPIDeinit;
begin
  if not FDevOpened then Exit;
  CH341Set_D5_D0(FDevHandle, 0, 0);
end;

function TCH341Hardware.SPIRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
begin
  if not FDevOpened then Exit(-1);

  CH341Set_D5_D0(FDevHandle, $29, 0); //Вручную дергаем cs
  if not CH341StreamSPI4(FDevHandle, 0, BufferLen, @buffer) then result :=-1 else result := BufferLen;
  if (CS = 1)then CH341Set_D5_D0(FDevHandle, $29, 1); //Отпускаем cs
end;

function TCH341Hardware.SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer;
begin
  if not FDevOpened then Exit(-1);

  CH341Set_D5_D0(FDevHandle, $29, 0); //Вручную дергаем cs
  if not CH341StreamSPI4(FDevHandle, 0, BufferLen, @buffer) then result :=-1 else result := BufferLen;
  if (CS = 1)then CH341Set_D5_D0(FDevHandle, $29, 1); //Отпускаем cs
end;

//i2c___________________________________________________________________________

procedure TCH341Hardware.I2CInit;
begin
  if not FDevOpened then Exit;
  CH341SetStream(FDevHandle, %10000001);
end;

procedure TCH341Hardware.I2CDeinit;
begin
  if not FDevOpened then Exit;
  CH341Set_D5_D0(FDevHandle, 0, 0);
end;

function TCH341Hardware.I2CReadWrite(DevAddr: byte;
                        WBufferLen: integer; WBuffer: array of byte;
                        RBufferLen: integer; var RBuffer: array of byte): integer;
var
  full_buff: array of byte;
begin
  if not FDevOpened then Exit(-1);

  SetLength(full_buff, WBufferLen+1);
  move(WBuffer, full_buff[1], WBufferLen);
  full_buff[0] := DevAddr;

  if not CH341StreamI2C(FDevHandle, WBufferLen+1, @full_buff[0], RBufferLen, @RBuffer) then result := -1 else result := WBufferLen+RBufferLen;
end;


function TCH341Hardware.I2CLineIsBusy(DevAddr: byte): boolean;
procedure SendBit(bit: byte);
begin
  if boolean(bit) then
  begin
    CH341SetOutput(FDevHandle, $10, 0, $0); //scl low
    CH341SetOutput(FDevHandle, $10, 0, $80000); //1
    CH341SetOutput(FDevHandle, $10, 0, $C0000); //scl hi
  end
  else
  begin
    CH341SetOutput(FDevHandle, $10, 0, $0); //scl low
    CH341SetOutput(FDevHandle, $10, 0, $0); //0
    CH341SetOutput(FDevHandle, $10, 0, $40000); //scl hi
  end;
end;
var
  pins, i: cardinal;
begin
  if not FDevOpened then Exit;

  CH341SetOutput(FDevHandle, $10, 0, $40000); //sda low(start)

  for i:=7 downto 1 do
  begin
    if IsBitSet(DevAddr, i) then SendBit(1) else SendBit(0);
  end;

  //rw
  SendBit(0);
  //ack
  SendBit(1);
  CH341GetStatus(FDevHandle, @pins);
  Result := IsBitSet(pins, 23);
  //stop
  SendBit(0);

  CH341SetOutput(FDevHandle, $10, 0, $C0000); //sda hi
end;

//MICROWIRE_____________________________________________________________________

function TCH341Hardware.MWInit(speed: integer): boolean;
var buff: byte;
begin
    if not FDevOpened then Exit(false);
    Result := CH341SetStream(FDevHandle, %10000001);
end;

procedure TCH341Hardware.MWDeInit;
var buff: byte;
begin
  if not FDevOpened then Exit;
  CH341Set_D5_D0(FDevHandle, 0, 0);
end;

function TCH341Hardware.MWRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
var
  bit_buffer: array of byte;
  i,j: integer;
begin
  if not FDevOpened then Exit(-1);
  CH341Set_D5_D0(FDevHandle, %00101001, 1); //cs hi

  SetLength(bit_buffer, BufferLen*8);
  FillByte(bit_buffer[0], BufferLen*8, 1); //cs hi

  if CH341BitStreamSPI(FDevHandle, BufferLen*8, @bit_buffer[0]) then result := BufferLen else result := -1; //читаем биты

  for i:=0 to BufferLen-1 do
  begin
    for j:=0 to 7 do
    begin
      if IsBitSet(bit_buffer[(i*8)+j], 7) then //читаем DIN
        BitSet(1, buffer[i], 7-j) //устанавливаем биты от старшего к младшему
      else
        BitSet(0, buffer[i], 7-j);
    end;
  end;

  if Boolean(CS) then CH341Set_D5_D0(FDevHandle, %00101001, 0);
end;

function TCH341Hardware.MWWrite(CS: byte; BitsWrite: byte; buffer: array of byte): integer;
var
  bit_buffer: array of byte;
  i,j: integer;
begin
  if not FDevOpened then Exit(-1);

  if BitsWrite > 0 then
  begin
    CH341Set_D5_D0(FDevHandle, %00101001, 1); //cs hi

    SetLength(bit_buffer, ByteNum(BitsWrite)*8);
    FillByte(bit_buffer[0], Length(bit_buffer), 1); //cs hi

    for i:=0 to ByteNum(BitsWrite)-1 do
    begin
      for j:=0 to 7 do
      begin
        if IsBitSet(buffer[i], 7-j) then //читаем буфер
          BitSet(1, bit_buffer[(i*8)+j], 5) //устанавливаем биты от старшего к младшему
        else
          BitSet(0, bit_buffer[(i*8)+j], 5);
      end;
    end;

    //Отсылаем биты
    if CH341BitStreamSPI(FDevHandle, BitsWrite, @bit_buffer[0]) then result := BitsWrite else result := -1;

    if Boolean(CS) then CH341Set_D5_D0(FDevHandle, %00101001, 0);
  end;

end;

function TCH341Hardware.MWIsBusy: boolean;
var
  port: byte;
begin
  CH341Set_D5_D0(FDevHandle, %00101001, 0);
  CH341Set_D5_D0(FDevHandle, %00101001, 1); //cs hi

  CH341GetStatus(FDevHandle, @port);
  result := not IsBitSet(port, 7);

  CH341Set_D5_D0(FDevHandle, %00101001, 0);
end;

end.

