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
  procedure SetI2CPins(scl, sda: cardinal);
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
  procedure I2CStart; override;
  procedure I2CStop; override;
  function I2CReadByte(ack: boolean): byte; override;
  function I2CWriteByte(data: byte): boolean; override; //return ack

  //MICROWIRE
  function MWInit(speed: integer): boolean; override;
  procedure MWDeinit; override;
  function MWRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer; override;
  function MWWrite(CS: byte; BitsWrite: byte; buffer: array of byte): integer; override;
  function MWIsBusy: boolean; override;
end;

implementation
uses main;
procedure TCH341Hardware.SetI2CPins(scl, sda: cardinal);
var pins: cardinal;
begin
  if scl > 0 then scl := $40000;
  if sda > 0 then sda := $80000;

  pins := 0;
  pins := pins or scl or sda;
  CH341SetOutput(FDevHandle, $10, 0, pins);
end;

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
  if FDevHandle >= 0 then
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
  SetI2CPins(1,1);
end;

procedure TCH341Hardware.I2CDeinit;
begin
  if not FDevOpened then Exit;
  CH341Set_D5_D0(FDevHandle, 0, 0);
  SetI2CPins(1,1);
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

procedure TCH341Hardware.I2CStart;
var
  mLength: Cardinal;
  mBuffer: array[0..mCH341_PACKET_LENGTH-1] of Byte;
begin
  if not FDevOpened then Exit;

  mBuffer[0] := mCH341A_CMD_I2C_STREAM;   // код команды
  mBuffer[1] := mCH341A_CMD_I2C_STM_STA;  // код старт-бита
  mBuffer[2] := mCH341A_CMD_I2C_STM_END;  // окончание пакета
  mLength := 3;                           // длина пакета

  CH341WriteData(FDevHandle, @mBuffer, @mLength); // запись блока данных
end;

procedure TCH341Hardware.I2CStop;
var
  mLength: Cardinal;
  mBuffer: array[0..mCH341_PACKET_LENGTH-1] of Byte;
begin
  if not FDevOpened then Exit;

  mBuffer[0] := mCH341A_CMD_I2C_STREAM;   // код команды
  mBuffer[1] := mCH341A_CMD_I2C_STM_STO;  // код стоп-бита
  mBuffer[2] := mCH341A_CMD_I2C_STM_END;  // окончание пакета
  mLength := 3;                           // длина пакета
  CH341WriteData(FDevHandle, @mBuffer, @mLength); // запись блока данных
end;

function TCH341Hardware.I2CReadByte(ack: boolean): byte;
function ReadBit(): byte;
var
  pins: cardinal;
begin
  SetI2CPins(0,1); //scl low
  SetI2CPins(1,1); //scl/sda hi
  CH341GetStatus(FDevHandle, @pins);
  if IsBitSet(pins, 23) then Result := 1
    else
      Result := 0;
end;

var i: integer;
    data: byte;
begin
  if not FDevOpened then Exit;
  data := 0;

  for i:=7 downto 0 do
  begin
    if (ReadBit = 1) then data := SetBit(data, i);
  end;

  //generate pulse for ack
  if not ack then
  begin
    SetI2CPins(0,1); //scl low
    SetI2CPins(0,1); //1
    SetI2CPins(1,1); //scl hi
  end
  else
  begin
    SetI2CPins(0,1); //scl low
    SetI2CPins(0,0); //0
    SetI2CPins(1,0);
  end;

  result := data;
end;

function TCH341Hardware.I2CWriteByte(data: byte): boolean;
procedure SendBit(bit: byte);
begin
  if boolean(bit) then
  begin
    SetI2CPins(0,0); //scl low
    SetI2CPins(0,1);
    SetI2CPins(1,1);
  end
  else
  begin
    SetI2CPins(0,0);
    SetI2CPins(0,0);
    SetI2CPins(1,0);
  end;
end;
var
  pins, i: cardinal;
begin
  if not FDevOpened then Exit;

  for i:=7 downto 0 do
  begin
    if IsBitSet(data, i) then SendBit(1) else SendBit(0);
  end;

  //generate pulse for ack
  SetI2CPins(0,0); //scl low
  SetI2CPins(0,1);
  SetI2CPins(1,1); //scl hi

  //read ack
  CH341GetStatus(FDevHandle, @pins);
  SetI2CPins(0,0);

  Result := not IsBitSet(pins, 23);

end;

//MICROWIRE_____________________________________________________________________

function TCH341Hardware.MWInit(speed: integer): boolean;
begin
    if not FDevOpened then Exit(false);
    Result := CH341SetStream(FDevHandle, %10000001);
end;

procedure TCH341Hardware.MWDeInit;
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

