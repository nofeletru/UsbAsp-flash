unit UsbAspHW;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, basehw, libusb, usbhid, msgstr, utilfunc;

type

{ TUsbAspHardware }

TUsbAspHardware = class(TBaseHardware)
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

  function SendControllMessage(direction: byte; request, value, index, bufflen: integer; var buffer: array of byte): integer;

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

const

 USBASP_FUNC_GETCAPABILITIES    = 127;
 USBASP_FUNC_DISCONNECT         = 2;
 USBASP_FUNC_SETISPSCK          = 10;
 USBASP_FUNC_25_CONNECT         = 50;
 USBASP_FUNC_25_READ            = 51;
 USBASP_FUNC_25_WRITE           = 52;

 USBASP_FUNC_I2C_INIT		= 70;
 USBASP_FUNC_I2C_READ		= 71;
 USBASP_FUNC_I2C_WRITE		= 72;
 USBASP_FUNC_I2C_START 		= 73;
 USBASP_FUNC_I2C_STOP 		= 74;
 USBASP_FUNC_I2C_READBYTE	= 75;
 USBASP_FUNC_I2C_WRITEBYTE      = 76;

 USBASP_FUNC_MW_READ            = 92;
 USBASP_FUNC_MW_WRITE	        = 93;
 USBASP_FUNC_MW_BUSY	        = 94;

constructor TUsbAspHardware.Create;
begin
  FDevHandle := nil;
  FDeviceDescription.idPRODUCT := $05DC;
  FDeviceDescription.idVENDOR := $16C0;
  FHardwareName := 'UsbAsp';
  FHardwareID := CHW_USBASP;
end;

destructor TUsbAspHardware.Destroy;
begin
  DevClose;
end;

function TUsbAspHardware.GetLastError: string;
begin
  result := usb_strerror;
  if UpCase(result) = 'NO ERROR' then
    result := FStrError;
end;

function TUsbAspHardware.DevOpen: boolean;
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

  //0=не поддерживается
  //1=урезана
  //2=полная

  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_GETCAPABILITIES, 1, 0, 4, buff);
  //if buff[3] = 11 then result := 1;
  //if buff[3] = 1 then result := 2;
  if buff[3] = 0 then
  begin
    FStrError := STR_NO_EEPROM_SUPPORT;
    Exit(false);
  end;

  FDevOpened := true;
  Result := true;
end;

procedure TUsbAspHardware.DevClose;
begin
  if FDevHandle <> nil then
  begin
    USB_Close(FDevHandle);
    FDevHandle := nil;
    FDevOpened := false;
  end;
end;

function TUsbAspHardware.SendControllMessage(direction: byte; request, value, index, bufflen: integer; var buffer: array of byte): integer;
begin
  result := USBSendControlMessage(FDevHandle, direction, request, value, index, bufflen, buffer);
end;

//SPI___________________________________________________________________________

function TUsbAspHardware.SPIInit(speed: integer): boolean;
var buff: byte;
begin
  if not FDevOpened then Exit(false);
  buff := $FF;
  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_SETISPSCK, speed, 0, 1, buff);
  if buff <> 0 then
  begin
    FStrError := 'STR_SET_SPEED_ERROR';
    Exit(false);
  end;
  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_25_CONNECT, 0, 0, 0, buff);
  Result := true;
end;

procedure TUsbAspHardware.SPIDeinit;
var buff: byte;
begin
  if not FDevOpened then Exit;
  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_DISCONNECT, 0, 0, 0, buff);
end;

function TUsbAspHardware.SPIRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
begin
  if not FDevOpened then Exit(-1);
  result := USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_25_READ, CS, 0, BufferLen, buffer);
end;

function TUsbAspHardware.SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer;
begin
  if not FDevOpened then Exit(-1);
  result := USBSendControlMessage(FDevHandle, PC2USB, USBASP_FUNC_25_WRITE, CS, 0, BufferLen, buffer);
end;

//i2c___________________________________________________________________________

procedure TUsbAspHardware.I2CInit;
var
  buff: byte;
begin
  if not FDevOpened then Exit;
  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_I2C_INIT, 0, 0, 0, buff);
end;

procedure TUsbAspHardware.I2CDeinit;
var
  buff: byte;
begin
  if not FDevOpened then Exit;
  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_DISCONNECT, 0, 0, 0, buff);
end;

function TUsbAspHardware.I2CReadWrite(DevAddr: byte;
                        WBufferLen: integer; WBuffer: array of byte;
                        RBufferLen: integer; var RBuffer: array of byte): integer;
var
  StopAfterWrite: byte;
begin
  if not FDevOpened then Exit(-1);

  StopAfterWrite := 1;

  if WBufferLen > 0 then
  begin
    if RBufferLen > 0 then StopAfterWrite := 0;
    Result := USBSendControlMessage(FDevHandle, PC2USB, USBASP_FUNC_I2C_WRITE, DevAddr, StopAfterWrite, WBufferLen, WBuffer);
  end;

  if RBufferLen > 0 then
    Result := Result + USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_I2C_READ, DevAddr, 0, RBufferLen, RBuffer);
end;

procedure TUsbAspHardware.I2CStop;
var dummy: byte;
begin
  if not FDevOpened then Exit;
  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_I2C_STOP, 0, 0, 0, dummy);
end;

procedure TUsbAspHardware.I2CStart;
var dummy: byte;
begin
  if not FDevOpened then Exit;
  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_I2C_START, 0, 0, 0, dummy);
end;

function TUsbAspHardware.I2CWriteByte(data: byte): boolean;
var
  ack: byte;
begin
  ack := 0;
  if not FDevOpened then Exit;
  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_I2C_WRITEBYTE, data, 0, 1, ack);
  Result := Boolean(ack);
end;

function TUsbAspHardware.I2CReadByte(ack: boolean): byte;
var
  data: byte;
  acknack: byte = 1;
begin
  if not FDevOpened then Exit;
  if ack then acknack := 0;
  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_I2C_READBYTE, acknack, 0, 1, data);
  Result := data;
end;

//MICROWIRE_____________________________________________________________________

function TUsbAspHardware.MWInit(speed: integer): boolean;
var buff: byte;
begin
    if not FDevOpened then Exit(false);
    buff := $FF;
    USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_SETISPSCK, speed, 0, 1, buff);
    if buff <> 0 then
    begin
      FStrError := 'STR_SET_SPEED_ERROR';
      Exit(false);
    end;
    USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_25_CONNECT, 0, 0, 0, buff);
    Result := true;
end;

procedure TUsbAspHardware.MWDeInit;
var buff: byte;
begin
  if not FDevOpened then Exit;
  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_DISCONNECT, 0, 0, 0, buff);
end;

function TUsbAspHardware.MWRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
begin
  if not FDevOpened then Exit(-1);
  result := USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_MW_READ, CS, 0, BufferLen, buffer);
end;

function TUsbAspHardware.MWWrite(CS: byte; BitsWrite: byte; buffer: array of byte): integer;
var
  bytes: byte;
begin
  if not FDevOpened then Exit(-1);
  bytes := ByteNum(BitsWrite);
  result := USBSendControlMessage(FDevHandle, PC2USB, USBASP_FUNC_MW_WRITE, CS, BitsWrite, bytes, buffer);
  if result = bytes then result := BitsWrite;
end;

function TUsbAspHardware.MWIsBusy: boolean;
var
  buf: byte;
begin
  buf := 0;
  result := False;

  USBSendControlMessage(FDevHandle, USB2PC, USBASP_FUNC_MW_BUSY, 0, 0, 1, buf);

  Result := Boolean(buf);
end;

end.

