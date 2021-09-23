unit avrisphw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, basehw, libusb, usbhid, msgstr, utilfunc;

type

{ TUsbAspHardware }

TAvrispHardware = class(TBaseHardware)
private
  FDevOpened: boolean;
  FDevHandle: Pusb_dev_handle;
  FDeviceDescription: TDeviceDescription;
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

   SPI_SPEED_8                 = 0;   // clock 16MHz = 8MHz SPI, clock 8MHz = 4MHz SPI
   SPI_SPEED_4                 = 1;   // 4MHz SPI
   SPI_SPEED_2                 = 2;   // 2MHz SPI
   SPI_SPEED_1                 = 3;   // 1MHz SPI
   SPI_SPEED_500               = 4;   // 500KHz SPI
   SPI_SPEED_250               = 5;   // 250KHz SPI
   SPI_SPEED_125               = 6;   // 125KHz SPI

   STATUS_CMD_UNKNOWN            = $C9;

   CMD_ENTER_PROGMODE_SPI25      = $30;
   CMD_LEAVE_PROGMODE_SPI25      = $31;
   CMD_SPI25_READ		= $32;
   CMD_SPI25_WRITE		= $33;

   CMD_FIRMWARE_VER              = $34;
   //I2C
   CMD_I2C_READ	                = $35;
   CMD_I2C_WRITE	        = $36;
   CMD_I2C_START  		= $37;
   CMD_I2C_STOP  		= $55;
   CMD_I2C_READBYTE	        = $56;
   CMD_I2C_WRITEBYTE	        = $57;
   CMD_I2C_INIT    	        = $58;
   //MW
   CMD_MW_READ		        = $38;
   CMD_MW_WRITE	                = $39;
   CMD_MW_BUSY		        = $40;
   CMD_MW_INIT	                = $41;

   CMD_SET_PARAMETER             = $02;
   CMD_GET_PARAMETER             = $03;

   PARAM_SCK_DURATION            = $98;

   IN_EP                         = $82;
   OUT_EP                        = $02;

   STREAM_TIMEOUT_MS             = 1000;

constructor TAvrispHardware.Create;
begin
  FDevHandle := nil;
  FDeviceDescription.idPRODUCT := $2104;
  FDeviceDescription.idVENDOR := $03EB;
  FHardwareName := 'Avrisp';
  FHardwareID := CHW_AVRISP;
end;

destructor TAvrispHardware.Destroy;
begin
  DevClose;
end;

function TAvrispHardware.GetLastError: string;
begin
  result := usb_strerror;
  if UpCase(result) = 'NO ERROR' then
    result := FStrError;
end;

function TAvrispHardware.DevOpen: boolean;
var
  err: integer;
  buff : array[0..3] of byte;
begin
  if FDevOpened then DevClose;
  FDevHandle := nil;
  FDevOpened := false;

  err := USBOpenDevice(FDevHandle, FDeviceDescription);
  if err <> 0 then
  begin
    case err of
    USBOPEN_ERR_ACCESS: FStrError := STR_CONNECTION_ERROR+ FHardwareName +'(Can''t access)';
    USBOPEN_ERR_IO: FStrError := STR_CONNECTION_ERROR+ FHardwareName +'(I/O error)';
    USBOPEN_ERR_NOTFOUND: FStrError := STR_CONNECTION_ERROR+ FHardwareName +'(Not found)';
    end;
    Exit(false);
  end;

  usb_set_configuration(FDevHandle, 1);
  usb_claim_interface(FDevHandle, 0);


  //Есть ли в прошивке наши команды

  buff[0]:= CMD_FIRMWARE_VER;
  usb_bulk_write(FDevHandle, OUT_EP, buff, 1, STREAM_TIMEOUT_MS);
  usb_bulk_read(FDevHandle, IN_EP, buff, 2, STREAM_TIMEOUT_MS);

  if buff[1] = STATUS_CMD_UNKNOWN then
  begin
      FStrError := STR_NO_EEPROM_SUPPORT;
      Exit(false);
  end;

  FDevOpened := true;
  Result := true;
end;

procedure TAvrispHardware.DevClose;
begin
  if FDevHandle <> nil then
  begin
    usb_release_interface(FDevHandle, 0);
    USB_Close(FDevHandle);
    FDevHandle := nil;
    FDevOpened := false;
  end;
end;


//SPI___________________________________________________________________________

function TAvrispHardware.SPIInit(speed: integer): boolean;
var
  buffer: array[0..2] of byte;
begin
 if not FDevOpened then Exit(false);
 result := true;

 //spi speed
 buffer[0]:= CMD_SET_PARAMETER;
 buffer[1]:= PARAM_SCK_DURATION;
 buffer[2]:= speed;

 if usb_bulk_write(FDevHandle, OUT_EP, buffer, Length(buffer), STREAM_TIMEOUT_MS) <> Length(buffer) then result := false;
 if usb_bulk_read(FDevHandle, IN_EP, buffer, 2, STREAM_TIMEOUT_MS) <> 2 then result := false;
 if buffer[1] <> 0 then
 begin
   FStrError := 'STR_SET_SPEED_ERROR';
   Exit(false);
 end;

 //spi init
 buffer[0]:= CMD_ENTER_PROGMODE_SPI25;
 if usb_bulk_write(FDevHandle, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS) <> 1 then result := false;
 if usb_bulk_read(FDevHandle, IN_EP, buffer, 2, STREAM_TIMEOUT_MS) <> 2 then result := false;
 if buffer[1] <> 0 then result := false;

end;

procedure TAvrispHardware.SPIDeinit;
var
  buffer: array[0..1] of byte;
begin
 if not FDevOpened then Exit;

 buffer[0]:= CMD_LEAVE_PROGMODE_SPI25;
 usb_bulk_write(FDevHandle, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS);
end;

function TAvrispHardware.SPIRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
var
  buff: array[0..3] of byte;
begin
  if not FDevOpened then Exit(-1);

  buff[0] := CMD_SPI25_READ;
  buff[1] := lo(Word(BufferLen));
  buff[2] := hi(Word(BufferLen));
  buff[3] := CS;

  usb_bulk_write(FDevHandle, OUT_EP, buff, Length(buff), STREAM_TIMEOUT_MS);

  result := usb_bulk_read(FDevHandle, IN_EP, buffer, BufferLen, STREAM_TIMEOUT_MS);
end;

function TAvrispHardware.SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer;
const
  HEADER_SIZE = 4;
var
  full_buffer: array of byte;
begin
  if not FDevOpened then Exit(-1);

  SetLength(full_buffer, BufferLen+HEADER_SIZE);

  full_buffer[0] := CMD_SPI25_WRITE;
  full_buffer[1] := lo(Word(BufferLen));
  full_buffer[2] := hi(Word(BufferLen));
  full_buffer[3] := CS;

  Move(buffer, full_buffer[HEADER_SIZE], BufferLen);

  result := usb_bulk_write(FDevHandle, OUT_EP, full_buffer[0], BufferLen+HEADER_SIZE, STREAM_TIMEOUT_MS) - HEADER_SIZE;
end;

//i2c___________________________________________________________________________

procedure TAvrispHardware.I2CInit;
var
  buffer: byte;
begin
  if not FDevOpened then Exit;

  buffer:= CMD_I2C_INIT;
  usb_bulk_write(FDevHandle, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS);
end;

procedure TAvrispHardware.I2CDeinit;
var
  buffer: array[0..1] of byte;
begin
 if not FDevOpened then Exit;

 buffer[0]:= CMD_LEAVE_PROGMODE_SPI25;
 usb_bulk_write(FDevHandle, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS);
end;

function TAvrispHardware.I2CReadWrite(DevAddr: byte;
                        WBufferLen: integer; WBuffer: array of byte;
                        RBufferLen: integer; var RBuffer: array of byte): integer;
const
  HEADER_LEN = 5;
var
  StopAfterWrite: byte;
  buff: array of byte;
begin
  if not FDevOpened then Exit(-1);

  StopAfterWrite := 1;

  if WBufferLen > 0 then
  begin
    if RBufferLen > 0 then StopAfterWrite := 0;

    SetLength(buff, WBufferLen+HEADER_LEN);
    buff[0] := CMD_I2C_WRITE;
    buff[1] := lo(Word(WBufferLen));
    buff[2] := hi(Word(WBufferLen));
    buff[3] := DevAddr;
    buff[4] := StopAfterWrite;
    Move(WBuffer, buff[HEADER_LEN], WBufferLen);

    result := usb_bulk_write(FDevHandle, OUT_EP, buff[0], WBufferLen+HEADER_LEN, STREAM_TIMEOUT_MS) - HEADER_LEN;
  end;

  if RBufferLen > 0 then
  begin
    SetLength(buff, HEADER_LEN);
    buff[0] := CMD_I2C_READ;
    buff[1] := lo(Word(RBufferLen));
    buff[2] := hi(Word(RBufferLen));
    buff[3] := DevAddr;
    buff[4] := 0;
    usb_bulk_write(FDevHandle, OUT_EP, buff[0], HEADER_LEN, STREAM_TIMEOUT_MS);

    Result := Result + usb_bulk_read(FDevHandle, IN_EP, RBuffer, RBufferLen, STREAM_TIMEOUT_MS);
  end;

end;

procedure TAvrispHardware.I2CStart;
var
  buffer: byte;
begin
  if not FDevOpened then Exit;

  buffer:= CMD_I2C_START;
  usb_bulk_write(FDevHandle, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS);
end;

procedure TAvrispHardware.I2CStop;
var
  buffer: byte;
begin
  if not FDevOpened then Exit;

  buffer:= CMD_I2C_STOP;
  usb_bulk_write(FDevHandle, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS);
end;

function TAvrispHardware.I2CReadByte(ack: boolean): byte;
var
  buff: array[0..1] of byte;
  data: byte;
begin
  if not FDevOpened then Exit;

  buff[0] := CMD_I2C_READBYTE;
  if ack then buff[1] := 0 else buff[1] := 1;

  usb_bulk_write(FDevHandle, OUT_EP, buff, SizeOf(buff), STREAM_TIMEOUT_MS);
  usb_bulk_read(FDevHandle, IN_EP, data, 1, STREAM_TIMEOUT_MS);
  Result := data;
end;

function TAvrispHardware.I2CWriteByte(data: byte): boolean;
var
  buff: array[0..1] of byte;
  status: byte = 1;
begin
  if not FDevOpened then Exit;

  buff[0] := CMD_I2C_WRITEBYTE;
  buff[1] := data;

  usb_bulk_write(FDevHandle, OUT_EP, buff, SizeOf(buff), STREAM_TIMEOUT_MS);
  usb_bulk_read(FDevHandle, IN_EP, status, 1, STREAM_TIMEOUT_MS);
  Result := Boolean(Status);
end;

//MICROWIRE_____________________________________________________________________

function TAvrispHardware.MWInit(speed: integer): boolean;
var
  buffer: array[0..2] of byte;
begin
  if not FDevOpened then Exit(false);
  result := true;

  //spi speed
  buffer[0]:= CMD_SET_PARAMETER;
  buffer[1]:= PARAM_SCK_DURATION;
  buffer[2]:= speed;

  if usb_bulk_write(FDevHandle, OUT_EP, buffer, SizeOf(buffer), STREAM_TIMEOUT_MS) <> SizeOf(buffer) then result := false;
  if usb_bulk_read(FDevHandle, IN_EP, buffer, 2, STREAM_TIMEOUT_MS) <> 2 then result := false;
  if buffer[1] <> 0 then
  begin
    FStrError := 'STR_SET_SPEED_ERROR';
    Exit(false);
  end;

  //spi init
  buffer[0]:= CMD_MW_INIT;
  if usb_bulk_write(FDevHandle, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS) <> 1 then result := false;
end;

procedure TAvrispHardware.MWDeInit;
var
  buffer: array[0..1] of byte;
begin
 if not FDevOpened then Exit;

 buffer[0]:= CMD_LEAVE_PROGMODE_SPI25;
 usb_bulk_write(FDevHandle, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS);
end;

function TAvrispHardware.MWRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
var
  buff: array[0..3] of byte;
begin
  if not FDevOpened then Exit(-1);

  buff[0] := CMD_MW_READ;
  buff[1] := lo(Word(BufferLen));
  buff[2] := hi(Word(BufferLen));
  buff[3] := CS;

  result := 0;
  usb_bulk_write(FDevHandle, OUT_EP, buff, Length(buff), STREAM_TIMEOUT_MS);
  if BufferLen = 0 then BufferLen := 1; //костыль
    result := usb_bulk_read(FDevHandle, IN_EP, buffer, BufferLen, STREAM_TIMEOUT_MS);
end;

function TAvrispHardware.MWWrite(CS: byte; BitsWrite: byte; buffer: array of byte): integer;
const
  HEADER_SIZE = 5;
var
  buff: array of byte;
  bytes: byte;
begin
  if not FDevOpened then Exit(-1);

  SetLength(buff, 2+HEADER_SIZE);

  bytes := ByteNum(BitsWrite);

  buff[0] := CMD_MW_WRITE;
  buff[1] := bytes;
  buff[2] := 0;
  buff[3] := CS;
  buff[4] := BitsWrite;

  Move(buffer, buff[HEADER_SIZE], 2);

  result := usb_bulk_write(FDevHandle, OUT_EP, buff[0], bytes+HEADER_SIZE, STREAM_TIMEOUT_MS)-HEADER_SIZE;
  if result = bytes then result := BitsWrite;
  logprint(inttostr(result));
end;

function TAvrispHardware.MWIsBusy: boolean;
var
  buf: byte;
begin
  buf := CMD_MW_BUSY;
  result := False;

  usb_bulk_write(FDevHandle, OUT_EP, buf, 1, STREAM_TIMEOUT_MS);
  usb_bulk_read(FDevHandle, IN_EP, buf, 1, STREAM_TIMEOUT_MS);

  if buf = 1 then result := True;
end;

end.

