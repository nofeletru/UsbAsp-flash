unit usbhid;
{$mode delphi}
interface

uses
  Classes, SysUtils, libusb, Graphics, msgstr, CH341DLL, ch341mw, avrispmk2;

type
 TPString = array [0..255] of Char;

TDeviceDescription = record
  idVENDOR:integer;
  idPRODUCT:integer;
  nameProduct:PANSIChar;
  nameVendor:PANSIChar;
end;

// usbOpenDevice() error codes:
const
 USBOPEN_SUCCESS         =0;   // no error
 USBOPEN_ERR_ACCESS      =1;   // not enough permissions to open device
 USBOPEN_ERR_IO          =2;   // I/O error
 USBOPEN_ERR_NOTFOUND    =3;   // device not found

 USB2PC = USB_ENDPOINT_IN;
 PC2USB = USB_ENDPOINT_OUT;

function usbGetStringAscii(handle: pusb_dev_handle; index: Integer; langid: Integer; var buf: TPString; buflen: Integer): integer;
function usbOpenDevice(var device: Pusb_dev_handle; DevDscr: TDeviceDescription): Integer;
function USB_Dev_Close(dev: pusb_dev_handle): longword;
function USBSendControlMessage(devHandle: Pusb_dev_handle; direction: byte; request, value, index, bufflen: integer; var buffer: array of byte): integer;

implementation

uses main, usbaspi2c, usbaspmw, usbasp25;

function usbGetStringAscii(handle: pusb_dev_handle; index: Integer; langid: Integer; var buf: TPString; buflen: Integer): integer;
var
 buffer: array [0..255] of char;
 rval, i: Integer;
begin
    rval := usb_control_msg(handle, USB_ENDPOINT_IN, USB_REQ_GET_DESCRIPTOR, (USB_DT_STRING shl 8) + index, langid, buffer, sizeof(buffer), 1000);
    result:=rval;
    if rval < 0 then exit;
    result:=0;
    if buffer[1] <> char(USB_DT_STRING) then Exit;
    if BYTE(buffer[0]) < rval then
        rval := BYTE(buffer[0]);

    rval:= rval div 2;
    (* lossy conversion to ISO Latin1 *)
    for i := 1 to rval-1 do
      begin
        if i > buflen then  (* destination buffer overflow *)
            break;
        buf[i-1] := buffer[2 * i];
        if buffer[2 * i + 1] <> #0 then (* outside of ISO Latin1 range *)
            buf[i-1] := char('?');
      end;
    buf[i-1] := #0;
    Result := i-1;
end;

function usbOpenDevice(var device: Pusb_dev_handle; DevDscr: TDeviceDescription): Integer;
const
{$J+}
   didUsbInit: integer = 0; //not a true constant but a static variable
{$J-}
var
  bus: Pusb_bus;
  dev: Pusb_device;
  handle: Pusb_dev_handle;
  errorCode: integer;
  S: TPstring;
  len: Integer;
begin
handle:=nil;
errorCode := USBOPEN_ERR_NOTFOUND;
    if didUsbInit=0 then
      begin
        didUsbInit := 1;
        usb_init;
      end;
    usb_find_busses;
    usb_find_devices;
    bus := usb_get_busses;
    While assigned(bus) do
      begin
        dev := bus^.devices;
        while assigned(dev) do
          begin
            if(dev.descriptor.idVendor = DevDscr.idVENDOR) and (dev.descriptor.idProduct = DevDscr.idPRODUCT) then
              begin
                handle := usb_open(dev); (* we need to open the device in order to query strings *)
                if not assigned(handle) then
                  begin
                    errorCode := USBOPEN_ERR_ACCESS;
                    raise Exception.Create('Warning: cannot open USB device '+usb_strerror());
                    continue;
                  end;
                if (DevDscr.nameVendor = nil) and (DevDscr.nameProduct = nil) then break; (* name does not matter *)
                (* now check whether the names match: *)
                len := usbGetStringAscii(handle, dev.descriptor.iManufacturer, $0409,S, sizeof(S));
                if (len < 0) then
                  begin
                    errorCode := USBOPEN_ERR_IO;
                    raise Exception.Create('Warning: cannot query manufacturer for device: '+usb_strerror());
                  end
                 else
                  begin
                    errorCode := USBOPEN_ERR_NOTFOUND;
                    (* fprintf(stderr, "seen device from vendor ->%s<-\n", string); *)
                    if StrPas(S)=vendorName then
                      begin
                        len := usbGetStringAscii(handle, dev.descriptor.iProduct, $0409,S, sizeof(S));
                        if (len < 0) then
                          begin
                            errorCode := USBOPEN_ERR_IO;
                            raise Exception.Create('Warning: cannot query product for device: '+usb_strerror());
                          end
                         else
                          begin
                            errorCode := USBOPEN_ERR_NOTFOUND;
                            (* fprintf(stderr, "seen product ->%s<-\n", string); *)
                            if StrPas(S)=DevDscr.nameProduct then
                                break;
                          end;  //if len
                      end; //if string_
                  end;  //if len<0
                usb_close(handle);
                handle := nil;
              end;  //if dev descriptor
            dev := dev.next;
          end;  //while assigned(dev)
        if handle<>nil then break;
        bus := bus.next;
      end;  //while assigned(bus)
    if (handle <> nil) then
      begin
        errorCode := 0;
        device := handle;
      end;
Result := errorCode;
end;

function USBSendControlMessage(devHandle: Pusb_dev_handle; direction: byte; request, value, index, bufflen: integer; var buffer: array of byte): integer;
var
  writebuff: array[0..2] of byte;
  full_buffer: array of byte;
  address_size: byte;
begin
  if CH341 then
  begin

    if request = USBASP_FUNC_MW_READ then
    begin
      if (value shr (index-2)) = 0 then
        ch341mw_sendop((value shr (index-4)), index-2)
      else
        result := ch341mw_read(index-2, value, buffer, bufflen);

        exit;
    end;

    if request = USBASP_FUNC_MW_WRITE then
    begin
      result := ch341mw_write(lo(word(index))-2, value, buffer, bufflen);
      exit;
    end;

    if request = USBASP_FUNC_I2C_READ then
    begin
      writebuff[0] := byte(value);
      writebuff[1] := hi(word(index));
      writebuff[2] := lo(word(index));
      address_size := hi(word(value))+1; //байты адреса + байт адреса устройства

      if not CH341StreamI2C(0, address_size, @writebuff, bufflen, @buffer) then result :=0 else result := bufflen;
      exit;
    end;

    if request = USBASP_FUNC_I2C_WRITE then
    begin
      address_size := hi(word(value))+1;
      SetLength(full_buffer, SizeOf(buffer)+address_size);

      full_buffer[0] := byte(value);

      if address_size = I2C_1BYTE_ADDR+1 then
      begin
        full_buffer[1] := lo(word(index));
      end;

      if address_size = I2C_2BYTE_ADDR+1 then
      begin
        full_buffer[1] := hi(word(index));
        full_buffer[2] := lo(word(index));
      end;

      move(buffer, full_buffer[address_size], bufflen);

      if not CH341StreamI2C(0, address_size+bufflen, @full_buffer[0], 0, nil) then result :=0 else result := bufflen;
      exit;
    end;

    //spi
    CH341Set_D5_D0(0, $29, 0); //Вручную дергаем cs
    if not CH341StreamSPI4(0, 0, bufflen, @buffer) then result :=0 else result := bufflen;
    if (value = 1)then CH341Set_D5_D0(0, $29, 1); //Отпускаем cs
    exit;
  end;

  if AVRISP then
  begin
    if request = USBASP_FUNC_25_READ then
      Result := arvisp_spi_read(value, buffer, bufflen);
    if request = USBASP_FUNC_25_WRITE then
      Result := arvisp_spi_write(value, buffer, bufflen);

    if request = USBASP_FUNC_I2C_INIT then exit;
    if request = USBASP_FUNC_I2C_READ then
      result := avrisp_i2c_read(value, hi(word(value)), index, buffer, bufflen);
    if request = USBASP_FUNC_I2C_WRITE then
      result := avrisp_i2c_write(value, hi(word(value)), index, buffer, bufflen);

    if request = USBASP_FUNC_MW_READ then
      result := avrisp_mw_read(index, value, buffer, bufflen);
    if request = USBASP_FUNC_MW_WRITE then
      //                                     opcode                                 addr
      result := avrisp_mw_write(Byte(index), Hi(Word(Index)) shl (Byte(index)-2) or Word(Value), buffer, bufflen);

    if result < 0 then
        if result = -116 then Main.LogPrint(STR_USB_TIMEOUT, clRed)
      else
        Main.LogPrint(AnsiToUtf8(usb_strerror), ClRed);
    exit;
  end;

  Result := usb_control_msg(devHandle, USB_TYPE_VENDOR or USB_RECIP_DEVICE or direction, request, value, index, buffer, bufflen, 10000);
  if result < 0 then
  begin
    if result = -116 then Main.LogPrint(STR_USB_TIMEOUT, clRed)
    else
      Main.LogPrint(AnsiToUtf8(usb_strerror), ClRed);
  end;
end;

function USB_Dev_Close(dev: pusb_dev_handle): longword;
begin

  if CH341 then
  begin
    CH341CloseDevice(0);
    Exit;
  end;

  if dev <> nil then
  begin
    if AVRISP then
      usb_release_interface(dev, 0);

    result := USB_Close(dev);
    dev := nil;
  end;
end;

end.

