unit arduinohw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, basehw, msgstr, Synaser, utilfunc;

type

{ TArduinoHardware }

TArduinoHardware = class(TBaseHardware)
private
  FDevOpened: boolean;
  FStrError: string;
  FSerial: TBlockSerial;
  FCOMPort: string;
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

const

SrtErr_CmdNoAck   = 'Data not accepted!';
StrErr_CmdErr     = 'Command not accepted!';

TIMEOUT = 2000;

FUNC_SPI_INIT                    = 7;
FUNC_SPI_DEINIT                  = 8;
FUNC_SPI_READ                    = 10;
FUNC_SPI_WRITE                   = 11;

FUNC_I2C_INIT                    = 20;
FUNC_I2C_READ                    = 21;
FUNC_I2C_WRITE                   = 22;
FUNC_I2C_START                   = 23;
FUNC_I2C_STOP                    = 24;
FUNC_I2C_READBYTE                = 25;
FUNC_I2C_WRITEBYTE               = 26;

FUNC_MW_READ                     = 30;
FUNC_MW_WRITE                    = 31;
FUNC_MW_BUSY                     = 32;
FUNC_MW_INIT                     = 33;
FUNC_MW_DEINIT                   = 34;

ACK                              = 81;

ERROR_RECV                       = 99;
ERROR_NO_CMD                     = 100;

constructor TArduinoHardware.Create;
begin
  FHardwareName := 'Arduino';
  FHardwareID := CHW_ARDUINO;

  FSerial := TBlockSerial.Create;
end;

destructor TArduinoHardware.Destroy;
begin
  DevClose;
  FSerial.Free;
end;

function TArduinoHardware.GetLastError: string;
begin

  result := FSerial.LastErrorDesc;
  if FSerial.LastError = 0 then
    result := FStrError;
end;

function TArduinoHardware.DevOpen: boolean;
var buff: byte;
    speed: cardinal;
begin
  if FDevOpened then DevClose;

  FDevOpened := false;

  FCOMPort := main.Arduino_COMPort;
  speed := main.Arduino_BaudRate;

  if FCOMPort = '' then
  begin
    FStrError:= 'No port selected!';
    Exit(false);
  end;

  {if Fserial.InstanceActive then
  begin
    FSerial.Purge;
    FDevOpened := true;
    Exit(true);
  end;}

  FSerial.Connect(FCOMPort);

  if FSerial.LastError <> 0 then
  begin
   FStrError := FSerial.LastErrorDesc;
   Exit(false);
  end;

  FSerial.Config(speed, 8, 'N', SB1, false, false);
  FSerial.Purge;
  sleep(2000); //Задержка пока отработает загрузчик ардуины

  //FSerial.RaiseExcept:= true;
  FDevOpened := true;
  Result := true;
end;

procedure TArduinoHardware.DevClose;
begin
  FDevOpened := false;
  FSerial.CloseSocket();
end;


//SPI___________________________________________________________________________

function TArduinoHardware.SPIInit(speed: integer): boolean;
var buff: byte;
begin
  if not FDevOpened then Exit(false);

  FSerial.SendByte(FUNC_SPI_INIT);
  FSerial.SendByte(speed);
  FSerial.Flush;

  buff := FSerial.RecvByte(TIMEOUT);
  if FSerial.LastError <> 0 then
     LogPrint(FSerial.LastErrorDesc);

  if buff <> FUNC_SPI_INIT then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(buff));
    Exit(false);
  end;

  Result := true;
end;

procedure TArduinoHardware.SPIDeinit;
var buff: byte;
begin
  if not FDevOpened then Exit;
   buff := FUNC_SPI_DEINIT;

  FSerial.SendByte(FUNC_SPI_DEINIT);
  FSerial.Flush;
  buff := FSerial.RecvByte(TIMEOUT);
  if FSerial.LastError <> 0 then
     LogPrint(FSerial.LastErrorDesc);

  if buff <> FUNC_SPI_DEINIT then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(buff));
    Exit;
  end;
end;

function TArduinoHardware.SPIRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
var buff:  byte;
    bytes: integer;
const chunk = 64;
begin
  if not FDevOpened then Exit(-1);
  result := 0;

  FSerial.SendByte(FUNC_SPI_READ);
  FSerial.SendByte(CS);
  FSerial.SendByte(hi(lo(BufferLen)));
  FSerial.SendByte(lo(lo(BufferLen)));
  FSerial.Flush;

  buff := FSerial.RecvByte(TIMEOUT);


  if buff <> FUNC_SPI_READ then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(buff));
    Exit(-1);
  end;

  bytes := 0;
  while bytes < BufferLen do
  begin
    if BufferLen - bytes > chunk-1 then
    begin
      result := result + FSerial.RecvBufferEx(@buffer[bytes], chunk, TIMEOUT);
      Inc(bytes, chunk);
    end
    else
    begin
      result := result + FSerial.RecvBufferEx(@buffer[bytes], BufferLen - bytes, TIMEOUT);
      Inc(bytes, BufferLen - bytes);
    end;

    if FSerial.LastError <> 0 then
     LogPrint(FSerial.LastErrorDesc);

    FSerial.SendByte(ACK);
    FSerial.Flush;
  end;
end;

function TArduinoHardware.SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer;
var buff: byte;
    bytes: integer;
const chunk = 256;
begin
  if not FDevOpened then Exit(-1);
  result := 0;

  FSerial.SendByte(FUNC_SPI_WRITE);
  FSerial.SendByte(CS);

  FSerial.SendByte(hi(lo(BufferLen)));
  FSerial.SendByte(lo(lo(BufferLen)));
  FSerial.Flush;

  buff := FSerial.RecvByte(TIMEOUT);

  if buff <> FUNC_SPI_WRITE then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(buff));
    Exit(-1);
  end;

  //Нужна запись пачками чтобы не переполнять буфер ардуинки
  bytes := 0;
  while bytes < BufferLen do
  begin
    if BufferLen - bytes > chunk-1 then
    begin
      result := result + FSerial.SendBuffer(@buffer[bytes], chunk);
      Inc(bytes, chunk);
    end
    else
    begin
      result := result + FSerial.SendBuffer(@buffer[bytes], BufferLen - bytes);
      Inc(bytes, BufferLen - bytes);
    end;

    buff := FSerial.RecvByte(TIMEOUT);

    if buff <> ACK then
    begin
      LogPrint(SrtErr_CmdNoAck + IntToStr(buff));
      Exit(-1);
    end;

  end;
end;

//i2c___________________________________________________________________________

procedure TArduinoHardware.I2CInit;
var
  buff: byte;
begin
  if not FDevOpened then Exit;

  FSerial.SendByte(FUNC_I2C_INIT);
  FSerial.Flush;

  buff := FSerial.RecvByte(TIMEOUT);

  if buff <> FUNC_I2C_INIT then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(buff));
    Exit;
  end;
end;

procedure TArduinoHardware.I2CDeinit;
begin
  if not FDevOpened then Exit;
end;

function TArduinoHardware.I2CReadWrite(DevAddr: byte;
                        WBufferLen: integer; WBuffer: array of byte;
                        RBufferLen: integer; var RBuffer: array of byte): integer;
var
  StopAfterWrite: byte;
  buff: byte;
  bytes: integer;
const rchunk = 64;
      wchunk = 256;
begin
  if not FDevOpened then Exit(-1);
  result := 0;
  StopAfterWrite := 1;

  if WBufferLen > 0 then
  begin
    if RBufferLen > 0 then StopAfterWrite := 0;

    FSerial.SendByte(FUNC_I2C_WRITE);
    FSerial.SendByte(DevAddr);
    FSerial.SendByte(StopAfterWrite);
    FSerial.SendByte(hi(lo(WBufferLen)));
    FSerial.SendByte(lo(lo(WBufferLen)));
    FSerial.Flush;

    buff := FSerial.RecvByte(TIMEOUT);


    if buff <> FUNC_I2C_WRITE then
    begin
      LogPrint(StrErr_CmdErr + IntToStr(buff));
      Exit(-1);
    end;

    bytes := 0;
    while bytes < WBufferLen do
    begin
      if WBufferLen - bytes > wchunk-1 then
      begin
        result := result + FSerial.SendBuffer(@Wbuffer[bytes], wchunk);
        Inc(bytes, wchunk);
      end
      else
      begin
        result := result + FSerial.SendBuffer(@Wbuffer[bytes], WBufferLen - bytes);
        Inc(bytes, WBufferLen - bytes);
      end;

      buff := FSerial.RecvByte(TIMEOUT);

      if buff <> ACK then
      begin
        LogPrint(SrtErr_CmdNoAck + IntToStr(buff));
        Exit(-1);
      end;

    end;

  end;

  if RBufferLen > 0 then
  begin
    FSerial.SendByte(FUNC_I2C_READ);
    FSerial.SendByte(DevAddr);
    FSerial.SendByte(hi(lo(RBufferLen)));
    FSerial.SendByte(lo(lo(RBufferLen)));
    FSerial.Flush;

    buff := FSerial.RecvByte(TIMEOUT);


    if buff <> FUNC_I2C_READ then
    begin
      LogPrint(StrErr_CmdErr + IntToStr(buff));
      Exit(-1);
    end;

    bytes := 0;
    while bytes < RBufferLen do
    begin
      if RBufferLen - bytes > rchunk-1 then
      begin
        result := result + FSerial.RecvBufferEx(@Rbuffer[bytes], rchunk, TIMEOUT);
        Inc(bytes, rchunk);
      end
      else
      begin
        result := result + FSerial.RecvBufferEx(@Rbuffer[bytes], RBufferLen - bytes, TIMEOUT);
        Inc(bytes, RBufferLen - bytes);
      end;

      if FSerial.LastError <> 0 then
        LogPrint(FSerial.LastErrorDesc);

      FSerial.SendByte(ACK);
      FSerial.Flush;
    end;

  end;

end;

procedure TArduinoHardware.I2CStart;
begin
  if not FDevOpened then Exit;

  FSerial.SendByte(FUNC_I2C_START);
  FSerial.Flush;
end;

procedure TArduinoHardware.I2CStop;
begin
  if not FDevOpened then Exit;

  FSerial.SendByte(FUNC_I2C_STOP);
  FSerial.Flush;
end;

function TArduinoHardware.I2CReadByte(ack: boolean): byte;
var
  Status: byte;
begin
  if not FDevOpened then Exit;

  FSerial.SendByte(FUNC_I2C_READBYTE);
  FSerial.SendByte(Byte(ack));
  FSerial.Flush;

  Status := FSerial.RecvByte(TIMEOUT);

  if Status <> FUNC_I2C_READBYTE then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(Status));
    Exit;
  end;

  Status := FSerial.RecvByte(TIMEOUT);

  Result := Status;

end;

function TArduinoHardware.I2CWriteByte(data: byte): boolean;
var
  Status: byte;
begin
  Status := 1;
  if not FDevOpened then Exit;

  FSerial.SendByte(FUNC_I2C_WRITEBYTE);
  FSerial.SendByte(data);
  FSerial.Flush;

  Status := FSerial.RecvByte(TIMEOUT);

  if Status <> FUNC_I2C_WRITEBYTE then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(Status));
    Exit(false);
  end;

  Status := FSerial.RecvByte(TIMEOUT);

  Result := Boolean(Status);
end;

//MICROWIRE_____________________________________________________________________

function TArduinoHardware.MWInit(speed: integer): boolean;
var buff: byte;
begin
    if not FDevOpened then Exit(false);

    FSerial.SendByte(FUNC_MW_INIT);
    FSerial.Flush;

    buff := FSerial.RecvByte(TIMEOUT);

    if buff <> FUNC_MW_INIT then
    begin
      LogPrint(StrErr_CmdErr + IntToStr(buff));
      Exit(false);
    end;

    Result := true;
end;

procedure TArduinoHardware.MWDeInit;
var buff: byte;
begin
  if not FDevOpened then Exit;

  FSerial.SendByte(FUNC_MW_DEINIT);
  FSerial.Flush;

  buff := FSerial.RecvByte(TIMEOUT);

  if buff <> FUNC_MW_DEINIT then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(buff));
    Exit;
  end;
end;

function TArduinoHardware.MWRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
var buff:  byte;
    bytes: integer;
const chunk = 64;
begin
  if not FDevOpened then Exit(-1);
  result := 0;

  FSerial.SendByte(FUNC_MW_READ);
  FSerial.SendByte(CS);
  FSerial.SendByte(hi(lo(BufferLen)));
  FSerial.SendByte(lo(lo(BufferLen)));
  FSerial.Flush;

  buff := FSerial.RecvByte(TIMEOUT);


  if buff <> FUNC_MW_READ then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(buff));
    Exit(-1);
  end;

  bytes := 0;
  while bytes < BufferLen do
  begin
    if BufferLen - bytes > chunk-1 then
    begin
      result := result + FSerial.RecvBufferEx(@buffer[bytes], chunk, TIMEOUT);
      Inc(bytes, chunk);
    end
    else
    begin
      result := result + FSerial.RecvBufferEx(@buffer[bytes], BufferLen - bytes, TIMEOUT);
      Inc(bytes, BufferLen - bytes);
    end;

    if FSerial.LastError <> 0 then
      LogPrint(FSerial.LastErrorDesc);

    FSerial.SendByte(ACK);
    FSerial.Flush;
  end;
end;

function TArduinoHardware.MWWrite(CS: byte; BitsWrite: byte; buffer: array of byte): integer;
var buff: byte;
    bytes: byte;
const chunk = 32;
begin
  if not FDevOpened then Exit(-1);
  result := 0;

  bytes := ByteNum(BitsWrite);

  FSerial.SendByte(FUNC_MW_WRITE);
  FSerial.SendByte(CS);
  FSerial.SendByte(BitsWrite);
  FSerial.SendByte(0);
  FSerial.SendByte(bytes);
  FSerial.Flush;

  buff := FSerial.RecvByte(TIMEOUT);

  if buff <> FUNC_MW_WRITE then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(buff));
    Exit(-1);
  end;

  //Максимум 32 байта
  result := FSerial.SendBuffer(@buffer[0], bytes);

  buff := FSerial.RecvByte(TIMEOUT);

  if buff <> ACK then
  begin
    LogPrint(SrtErr_CmdNoAck + IntToStr(buff));
    Exit(-1);
  end;

  if result = bytes then result := BitsWrite;
end;

function TArduinoHardware.MWIsBusy: boolean;
var
  buff: byte;
begin
  buff := 0;
  result := False;

  FSerial.SendByte(FUNC_MW_BUSY);
  FSerial.Flush;

  buff := FSerial.RecvByte(TIMEOUT);

  if buff <> FUNC_MW_BUSY then
  begin
    LogPrint(StrErr_CmdErr + IntToStr(buff));
    Exit;
  end;

  buff := FSerial.RecvByte(TIMEOUT);

  Result := Boolean(buff);
end;




end.

