unit avrispmk2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, libusb;

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
  CMD_I2C_WRITE	                = $36;
  CMD_I2C_ACK                   = $37;
  //MW
  CMD_MW_READ		        = $38;
  CMD_MW_WRITE	                = $39;
  CMD_MW_BUSY		        = $40;

  CMD_SET_PARAMETER             = $02;
  CMD_GET_PARAMETER             = $03;

  PARAM_SCK_DURATION            = $98;

  IN_EP                         = $82;
  OUT_EP                        = $02;

  STREAM_TIMEOUT_MS             = 1000;


function is_firmware_supported(): boolean;
function arvisp_spi_read(cs: byte; var buffer: array of byte; bufflen: word): integer;
function arvisp_spi_write(cs: byte; var buffer: array of byte; bufflen: word): integer;
function avrisp_set_ckl(value: byte): boolean;
function avrisp_enter_progmode(): boolean;
function avrisp_leave_progmode(): boolean;

function avrisp_i2c_read(DevAddr, MemAddrLen: byte; Address: word; var buffer: array of byte; bufflen: word): integer;
function avrisp_i2c_write(DevAddr, MemAddrLen: byte; Address: word; var buffer: array of byte; bufflen: word): integer;
function avrisp_i2c_ack(DevAddr: byte): boolean;

function avrisp_mw_read(AddrBitLen: byte; Addr: word; var buffer: array of byte; bufflen: word): integer;
function avrisp_mw_write(AddrBitLen: byte; Addr: word; var buffer: array of byte; bufflen: word): integer;
function avrisp_mw_busy(): boolean;

implementation

uses main;

function is_firmware_supported(): boolean;
var
  buffer: array[0..1] of byte;
begin
 result := true;

 buffer[0]:= CMD_FIRMWARE_VER;
 usb_bulk_write(hUSBDev, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS);
 usb_bulk_read(hUSBDev, IN_EP, buffer, 2, STREAM_TIMEOUT_MS);
 if buffer[1] = STATUS_CMD_UNKNOWN then result := false;
end;

function arvisp_spi_read(cs: byte; var buffer: array of byte; bufflen: word): integer;
var
  buff: array[0..3] of byte;
begin

  buff[0] := CMD_SPI25_READ;
  buff[1] := lo(bufflen);
  buff[2] := hi(bufflen);
  buff[3] := cs;

  usb_bulk_write(hUSBDev, OUT_EP, buff, 4, STREAM_TIMEOUT_MS);

  result := usb_bulk_read(hUSBDev, IN_EP, buffer, bufflen, STREAM_TIMEOUT_MS);
end;

function arvisp_spi_write(cs: byte; var buffer: array of byte; bufflen: word): integer;
var
  full_buffer: array of byte;
begin

  SetLength(full_buffer, bufflen+4);

  full_buffer[0] := CMD_SPI25_WRITE;
  full_buffer[1] := lo(bufflen);
  full_buffer[2] := hi(bufflen);
  full_buffer[3] := cs;

  Move(buffer, full_buffer[4], bufflen);

  result := usb_bulk_write(hUSBDev, OUT_EP, full_buffer[0], bufflen+4, STREAM_TIMEOUT_MS) - 4;

end;

function avrisp_set_ckl(value: byte): boolean;
var
  buffer: array[0..2] of byte;
begin
 result := true;

 buffer[0]:= CMD_SET_PARAMETER;
 buffer[1]:= PARAM_SCK_DURATION;
 buffer[2]:= value;
 if usb_bulk_write(hUSBDev, OUT_EP, buffer, 3, STREAM_TIMEOUT_MS) <> 3 then result := false;
 if usb_bulk_read(hUSBDev, IN_EP, buffer, 2, STREAM_TIMEOUT_MS) <> 2 then result := false;
 if buffer[1] <> 0 then result := false;
end;

function avrisp_enter_progmode(): boolean;
var
  buffer: array[0..1] of byte;
begin
 result := true;

 buffer[0]:= CMD_ENTER_PROGMODE_SPI25;
 if usb_bulk_write(hUSBDev, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS) <> 1 then result := false;
 if usb_bulk_read(hUSBDev, IN_EP, buffer, 2, STREAM_TIMEOUT_MS) <> 2 then result := false;
 if buffer[1] <> 0 then result := false;
end;

function avrisp_leave_progmode(): boolean;
var
  buffer: array[0..1] of byte;
begin
 result := true;

 buffer[0]:= CMD_LEAVE_PROGMODE_SPI25;
 if usb_bulk_write(hUSBDev, OUT_EP, buffer, 1, STREAM_TIMEOUT_MS) <> 1 then result := false;
 if usb_bulk_read(hUSBDev, IN_EP, buffer, 2, STREAM_TIMEOUT_MS) <> 2 then result := false;
 if buffer[1] <> 0 then result := false;
end;


function avrisp_i2c_read(DevAddr, MemAddrLen: byte; Address: word; var buffer: array of byte; bufflen: word): integer;
var
  buff: array[0..6] of byte;
begin
  buff[0] := CMD_I2C_READ;
  buff[1] := lo(bufflen);
  buff[2] := hi(bufflen);
  buff[3] := DevAddr;
  buff[4] := MemAddrLen;
  buff[5] := lo(Address);
  buff[6] := hi(Address);

  usb_bulk_write(hUSBDev, OUT_EP, buff, 7, STREAM_TIMEOUT_MS);
  result := usb_bulk_read(hUSBDev, IN_EP, buffer, bufflen, STREAM_TIMEOUT_MS);
end;


function avrisp_i2c_write(DevAddr, MemAddrLen: byte; Address: word; var buffer: array of byte; bufflen: word): integer;
const
  HEADER_LEN = 7;
var
  buff: array of byte;
begin
  SetLength(buff, bufflen+HEADER_LEN);

  buff[0] := CMD_I2C_WRITE;
  buff[1] := lo(bufflen);
  buff[2] := hi(bufflen);
  buff[3] := DevAddr;
  buff[4] := MemAddrLen;
  buff[5] := lo(Address);
  buff[6] := hi(Address);

  Move(buffer, buff[HEADER_LEN], bufflen);

  result := usb_bulk_write(hUSBDev, OUT_EP, buff[0], bufflen+HEADER_LEN, STREAM_TIMEOUT_MS) - HEADER_LEN;
end;

function avrisp_i2c_ack(DevAddr: byte): boolean;
var
  buff: array[0..1] of byte;
  status: byte = 1;
begin
  buff[0] := CMD_I2C_ACK;
  buff[1] := DevAddr;

  usb_bulk_write(hUSBDev, OUT_EP, buff, 2, STREAM_TIMEOUT_MS);
  usb_bulk_read(hUSBDev, IN_EP, status, 1, STREAM_TIMEOUT_MS);
  Result := Boolean(Status);
end;

function avrisp_mw_read(AddrBitLen: byte; Addr: word; var buffer: array of byte; bufflen: word): integer;
var
  buff: array[0..5] of byte;
begin
  buff[0] := CMD_MW_READ;
  buff[1] := lo(bufflen);
  buff[2] := hi(bufflen);
  buff[3] := lo(Addr);
  buff[4] := hi(Addr);
  buff[5] := AddrBitLen;

  result := 0;
  usb_bulk_write(hUSBDev, OUT_EP, buff, 6, STREAM_TIMEOUT_MS);
  if bufflen = 0 then bufflen := 1; //костыль
    result := usb_bulk_read(hUSBDev, IN_EP, buffer, bufflen, STREAM_TIMEOUT_MS);
end;

function avrisp_mw_write(AddrBitLen: byte; Addr: word; var buffer: array of byte; bufflen: word): integer;
const
  HEADER_SIZE = 6;
var
  buff: array of byte;
begin
  SetLength(buff, bufflen+HEADER_SIZE);

  buff[0] := CMD_MW_WRITE;
  buff[1] := lo(bufflen);
  buff[2] := hi(bufflen);
  buff[3] := lo(Addr);
  buff[4] := hi(Addr);
  buff[5] := AddrBitLen;

  Move(buffer, buff[HEADER_SIZE], bufflen);

  result := usb_bulk_write(hUSBDev, OUT_EP, buff[0], bufflen+HEADER_SIZE, STREAM_TIMEOUT_MS)-HEADER_SIZE;
end;

function avrisp_mw_busy(): boolean;
var
  buf: byte;
begin
  buf := CMD_MW_BUSY;
  result := False;

  usb_bulk_write(hUSBDev, OUT_EP, buf, 1, STREAM_TIMEOUT_MS);
  usb_bulk_read(hUSBDev, IN_EP, buf, 1, STREAM_TIMEOUT_MS);

  if buf = 1 then result := True;
end;

end.

