unit ch347hw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, basehw, msgstr, ch347dll, ch341dll, utilfunc;

type

{ TCH347Hardware }

TCH347Hardware = class(TBaseHardware)
private
  FDevOpened: boolean;
  FDevHandle: Longint;
  FStrError: string;
  FDevSPIConfig: _SPI_CONFIG;
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

  function ReadBit(var data: byte): boolean;
  function WriteBit(data: byte): boolean;
end;

implementation
uses main;

constructor TCH347Hardware.Create;
begin
  FDevHandle := -1;
  FHardwareName := 'CH347';
  FHardwareID := CHW_CH347;
end;

destructor TCH347Hardware.Destroy;
begin
  DevClose;
end;

function TCH347Hardware.GetLastError: string;
begin
  result := FStrError;
end;

function TCH347Hardware.DevOpen: boolean;
var
  i, err: integer;
begin
  if FDevOpened then DevClose;

   for i:=0 to mCH341_MAX_NUMBER-1 do
    begin
      err := CH347OpenDevice(i);
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

procedure TCH347Hardware.DevClose;
begin
  if FDevHandle >= 0 then
  begin
    CH347CloseDevice(FDevHandle);
    FDevHandle := -1;
    FDevOpened := false;
  end;
end;


//SPI___________________________________________________________________________

function TCH347Hardware.SPIInit(speed: integer): boolean;
begin
  if not FDevOpened then Exit(false);
  with FDevSPIConfig do
  begin
    iMode:= 0;
    iClock:= speed;
    iByteOrder:= 1;
    iSpiWriteReadInterval:= 0;
    iSpiOutDefaultData:= 0;
    iChipSelect:= $0;
    CS1Polarity:= 0;
    CS2Polarity:= 0;
    iIsAutoDeativeCS:= 0;
    iActiveDelay:= 0;
    iDelayDeactive:= 0;
  end;

  Result := CH347SPI_Init(FDevHandle, @FDevSPIConfig);
end;

procedure TCH347Hardware.SPIDeinit;
begin
  if not FDevOpened then Exit;
end;

function TCH347Hardware.SPIRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
begin
  if not FDevOpened then Exit(-1);

  if (CS = 1) then if not CH347SPI_Read(FDevHandle, $80, 0, @BufferLen, @buffer) then result :=-1 else result := BufferLen
  else
  begin
    CH347SPI_ChangeCS(FDevHandle, 0); //Вручную дергаем cs
    if not CH347SPI_Read(FDevHandle, 0, 0, @BufferLen, @buffer) then result :=-1 else result := BufferLen;
  end;

end;

function TCH347Hardware.SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer;
begin
  if not FDevOpened then Exit(-1);

  if (CS = 1) then if not CH347SPI_Write(FDevHandle, $80, BufferLen, 500, @buffer) then result :=-1 else result := BufferLen
  else
  begin
    CH347SPI_ChangeCS(FDevHandle, 0); //Вручную дергаем cs
    if not CH347SPI_Write(FDevHandle, 0, BufferLen, 500, @buffer) then result :=-1 else result := BufferLen;
  end;

end;

//i2c___________________________________________________________________________

procedure TCH347Hardware.I2CInit;
begin
  if not FDevOpened then Exit;
  CH347I2C_Set(FDevHandle, 1);
end;

procedure TCH347Hardware.I2CDeinit;
begin
  if not FDevOpened then Exit;
end;

function TCH347Hardware.I2CReadWrite(DevAddr: byte;
                        WBufferLen: integer; WBuffer: array of byte;
                        RBufferLen: integer; var RBuffer: array of byte): integer;
var
  full_buff: array of byte;
begin
  if not FDevOpened then Exit(-1);

  SetLength(full_buff, WBufferLen+1);
  move(WBuffer, full_buff[1], WBufferLen);
  full_buff[0] := DevAddr;

  if not CH347StreamI2C(FDevHandle, WBufferLen+1, @full_buff[0], RBufferLen, @RBuffer) then result := -1 else result := WBufferLen+RBufferLen;
end;

procedure TCH347Hardware.I2CStart;
var
  mLength: Cardinal;
  mBuffer: array[0..mCH347_PACKET_LENGTH-1] of Byte;
begin
  if not FDevOpened then Exit;

  mBuffer[0] := mCH341A_CMD_I2C_STREAM;   // код команды
  mBuffer[1] := mCH341A_CMD_I2C_STM_STA;  // код старт-бита
  mBuffer[2] := mCH341A_CMD_I2C_STM_END;  // окончание пакета
  mLength := 3;                           // длина пакета

  CH347WriteData(FDevHandle, @mBuffer, @mLength); // запись блока данных
end;

procedure TCH347Hardware.I2CStop;
var
  mLength: Cardinal;
  mBuffer: array[0..mCH347_PACKET_LENGTH-1] of Byte;
begin
  if not FDevOpened then Exit;

  mBuffer[0] := mCH341A_CMD_I2C_STREAM;   // код команды
  mBuffer[1] := mCH341A_CMD_I2C_STM_STO;  // код стоп-бита
  mBuffer[2] := mCH341A_CMD_I2C_STM_END;  // окончание пакета
  mLength := 3;                           // длина пакета

  CH347WriteData(FDevHandle, @mBuffer, @mLength); // запись блока данных
end;

function TCH347Hardware.I2CReadByte(ack: boolean): byte;
var
  mLength: Cardinal;
  mBuffer: array[0..mCH347_PACKET_LENGTH-1] of Byte;
begin
  if not FDevOpened then Exit;

  mBuffer[0] := mCH341A_CMD_I2C_STREAM;
  mBuffer[1] := mCH341A_CMD_I2C_STM_IN;
  if ack then mBuffer[1] := mBuffer[1] or 1; // ack bit
  mBuffer[2] := mCH341A_CMD_I2C_STM_END;

  mLength := 3;
  CH347WriteData(FDevHandle, @mBuffer, @mLength);

  mLength:= mCH347_PACKET_LENGTH;
  CH347ReadData(FDevHandle, @mBuffer, @mLength);

  result := mBuffer[0];
end;

function TCH347Hardware.I2CWriteByte(data: byte): boolean;
var
  mLength: Cardinal;
  mBuffer: array[0..mCH347_PACKET_LENGTH-1] of Byte;
begin
  if not FDevOpened then Exit;

  mBuffer[0] := mCH341A_CMD_I2C_STREAM;
  mBuffer[1] := mCH341A_CMD_I2C_STM_OUT or 1;
  mBuffer[2] := data;
  mBuffer[3] := mCH341A_CMD_I2C_STM_END;
  mLength := 4;
  CH347WriteData(FDevHandle, @mBuffer, @mLength);

  mLength:= mCH347_PACKET_LENGTH;
  CH347ReadData(FDevHandle, @mBuffer, @mLength);

  result := boolean(mBuffer[0]);
end;


//MICROWIRE_____________________________________________________________________
//00001111
//       ^ CLK
//      ^ MISO
//     ^ CS
//    ^ MOSI
function TCH347Hardware.ReadBit(var data: byte): boolean;
var
  i: byte = 0;
  b: byte;
begin
  result := true;

  if not CH347GPIO_Set(FDevHandle, %00000001, $FF, $FF) then result := false;
  if not CH347GPIO_Get(FDevHandle, @b, @i) then result := false;
  if not CH347GPIO_Set(FDevHandle, %00000001, $FF, 0) then result := false;

  if IsBitSet(i, 1) then data := 1 else data := 0;
end;

function TCH347Hardware.WriteBit(data: byte): boolean;
var sdata: byte = 0;
begin
  result := true;

  if data > 0 then sdata := $FF else sdata := 0;

  if not CH347GPIO_Set(FDevHandle, %00001000, $FF, sdata) then result := false;

  if not CH347GPIO_Set(FDevHandle, %00000001, $FF, $FF) then result := false;
  if not CH347GPIO_Set(FDevHandle, %00000001, $FF, 0) then result := false;
end;

function TCH347Hardware.MWInit(speed: integer): boolean;
begin
    if not FDevOpened then Exit(false);
    Result := CH347GPIO_Set(FDevHandle, %00001111, %00001101, %00001010);
end;

procedure TCH347Hardware.MWDeInit;
begin
  if not FDevOpened then Exit;
  CH347GPIO_Set(FDevHandle, %00001111, 0, 0);
end;

function TCH347Hardware.MWRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
var
  bit_buffer: array of byte;
  i,j: integer;
begin
  if not FDevOpened then Exit(-1);
  CH347GPIO_Set(FDevHandle, %00000100, $FF, $FF); //cs hi

  SetLength(bit_buffer, BufferLen*8);

  for i:=0 to (BufferLen*8)-1 do
   begin
    if ReadBit(bit_buffer[i]) then result := BufferLen else result := -1; //читаем биты
   end;

  for i:=0 to BufferLen-1 do
  begin
    for j:=0 to 7 do
    begin
      if IsBitSet(bit_buffer[(i*8)+j], 0) then //читаем DIN
        BitSet(1, buffer[i], 7-j) //устанавливаем биты от старшего к младшему
      else
        BitSet(0, buffer[i], 7-j);
    end;
  end;

  if Boolean(CS) then CH347GPIO_Set(FDevHandle, %00000100, $FF, 0);
end;

function TCH347Hardware.MWWrite(CS: byte; BitsWrite: byte; buffer: array of byte): integer;
var
  bit_buffer: array of byte;
  i,j: integer;
begin
  if not FDevOpened then Exit(-1);

  if BitsWrite > 0 then
  begin
    CH347GPIO_Set(FDevHandle, %00000100, $FF, $FF); //cs hi

    SetLength(bit_buffer, ByteNum(BitsWrite)*8);

    for i:=0 to ByteNum(BitsWrite)-1 do
    begin
      for j:=0 to 7 do
      begin
        if IsBitSet(buffer[i], 7-j) then //читаем буфер
          BitSet(1, bit_buffer[(i*8)+j], 0) //устанавливаем биты от старшего к младшему
        else
          BitSet(0, bit_buffer[(i*8)+j], 0);
      end;
    end;

    //Отсылаем биты
    for i:=0 to BitsWrite-1 do
      if WriteBit(bit_buffer[i]) then result := BitsWrite else result := -1;

    if Boolean(CS) then CH347GPIO_Set(FDevHandle, %00000100, $FF, 0);
  end;

end;

function TCH347Hardware.MWIsBusy: boolean;
var
  port, b: byte;
begin
  CH347GPIO_Set(FDevHandle, %00000100, $FF, 0);
  CH347GPIO_Set(FDevHandle, %00000100, $FF, $FF); //cs hi

  CH347GPIO_Get(FDevHandle, @b, @port);
  result := not IsBitSet(port, 1);

  CH347GPIO_Set(FDevHandle, %00000100, $FF, 0);
end;

end.

