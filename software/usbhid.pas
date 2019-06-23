unit usbhid;
{$mode delphi}
interface

uses
  Classes, SysUtils, libusb, Graphics, msgstr;

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
function USBSendControlMessage(devHandle: Pusb_dev_handle; direction: byte; request, value, index, bufflen: integer; var buffer: array of byte): integer;

implementation

uses main;

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
begin
  Result := usb_control_msg(devHandle, USB_TYPE_VENDOR or USB_RECIP_DEVICE or direction, request, value, index, buffer, bufflen, 10000);
  if result < 0 then
  begin
    if result = -116 then Main.LogPrint(STR_USB_TIMEOUT)
    else
      Main.LogPrint(AnsiToUtf8(usb_strerror));
  end;
end;

end.

