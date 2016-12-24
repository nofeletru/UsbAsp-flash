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


  CMD_ENTER_PROGMODE_SPI25      = $30;
  CMD_LEAVE_PROGMODE_SPI25      = $31;

  CMD_SPI25_READ		= $32;
  CMD_SPI25_WRITE		= $33;

  CMD_SET_PARAMETER             = $02;
  CMD_GET_PARAMETER             = $03;

  PARAM_SCK_DURATION            = $98;

  IN_EP                         = $82;
  OUT_EP                        = $02;


function arvisp_spi_read(cs: byte; var buffer: array of byte; bufflen: word): integer;
function arvisp_spi_write(cs: byte; var buffer: array of byte; bufflen: word): integer;
function avrisp_set_ckl(value: byte): boolean;
function avrisp_enter_progmode(): boolean;
function avrisp_leave_progmode(): boolean;

implementation

uses main;

function arvisp_spi_read(cs: byte; var buffer: array of byte; bufflen: word): integer;
var
  buff: array[0..3] of byte;
begin

  buff[0] := CMD_SPI25_READ;
  buff[1] := lo(bufflen);
  buff[2] := hi(bufflen);
  buff[3] := cs;

  usb_bulk_write(hUSBDev, OUT_EP, buff, 4, 10000);

  result := usb_bulk_read(hUSBDev, IN_EP, buffer, bufflen, 10000);
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

  result := usb_bulk_write(hUSBDev, OUT_EP, full_buffer[0], bufflen+4, 10000) - 4;

end;


function avrisp_set_ckl(value: byte): boolean;
var
  buffer: array[0..2] of byte;
begin
 result := true;

 buffer[0]:= CMD_SET_PARAMETER;
 buffer[1]:= PARAM_SCK_DURATION;
 buffer[2]:= value;
 if usb_bulk_write(hUSBDev, OUT_EP, buffer, 3, 10000) <> 3 then result := false;
 if usb_bulk_read(hUSBDev, IN_EP, buffer, 2, 10000) <> 2 then result := false;
 if buffer[1] <> 0 then result := false;
end;

function avrisp_enter_progmode(): boolean;
var
  buffer: array[0..1] of byte;
begin
 result := true;

 buffer[0]:= CMD_ENTER_PROGMODE_SPI25;
 if usb_bulk_write(hUSBDev, OUT_EP, buffer, 1, 10000) <> 1 then result := false;
 if usb_bulk_read(hUSBDev, IN_EP, buffer, 2, 10000) <> 2 then result := false;
 if buffer[1] <> 0 then result := false;
end;

function avrisp_leave_progmode(): boolean;
var
  buffer: array[0..1] of byte;
begin
 result := true;

 buffer[0]:= CMD_LEAVE_PROGMODE_SPI25;
 if usb_bulk_write(hUSBDev, OUT_EP, buffer, 1, 10000) <> 1 then result := false;
 if usb_bulk_read(hUSBDev, IN_EP, buffer, 2, 10000) <> 2 then result := false;
 if buffer[1] <> 0 then result := false;
end;

end.

