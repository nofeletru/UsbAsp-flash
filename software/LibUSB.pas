(* LIBUSB-WIN32, Generic Windows USB Library
 * Copyright (c) 2002-2004 Stephan Meyer <ste_meyer@web.de>
 * Copyright (c) 2000-2004 Johannes Erdfelt <johannes@erdfelt.com>
 *
 * Pascal translation
 * Copyright (c) 2004 Yvo Nelemans <ynlmns@xs4all.nl>
 * Fixes by Tifa
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)

unit LibUSB;

interface

{$ifdef unix}
uses unix;
{$endif}

const
{$ifdef windows}
  LIBUSB_PATH_MAX = 510;
  LIBUSB_DLL_NAME =  'libusb0.dll';
{$endif}
{$ifdef unix}
  LIBUSB_PATH_MAX = PATH_MAX;
  LIBUSB_DLL_NAME =  'libusb';
{$endif}

  USB_OK = 0; // 0 = success from functions < 0 is failed


  { Device and/or Interface Class codes }
  USB_CLASS_PER_INTERFACE   =   0; { for DeviceClass }
  USB_CLASS_AUDIO           =   1;
  USB_CLASS_COMM            =   2;
  USB_CLASS_HID             =   3;
  USB_CLASS_PRINTER         =   7;
  USB_CLASS_MASS_STORAGE    =   8;
  USB_CLASS_HUB             =   9;
  USB_CLASS_DATA            =  10;
  USB_CLASS_VENDOR_SPEC     = $ff;

  // Descriptor types
  USB_DT_DEVICE     = $01;
  USB_DT_CONFIG     = $02;
  USB_DT_STRING     = $03;
  USB_DT_INTERFACE  = $04;
  USB_DT_ENDPOINT   = $05;

  USB_DT_HID        = $21;
  USB_DT_REPORT     = $22;
  USB_DT_PHYSICAL   = $23;
  USB_DT_HUB        = $29;

  // Descriptor sizes per descriptor type
  USB_DT_DEVICE_SIZE          = 18;
  USB_DT_CONFIG_SIZE          =  9;
  USB_DT_INTERFACE_SIZE       =  9;
  USB_DT_ENDPOINT_SIZE        =  7;
  USB_DT_ENDPOINT_AUDIO_SIZE  =  9; // Audio extension
  USB_DT_HUB_NONVAR_SIZE      =  7;


type
  // All standard descriptors have these 2 fields in common
  usb_descriptor_header = packed record
    bLength,
    bDescriptorType: byte;
  end;

  // String descriptor
  usb_string_descriptor = packed record
    bLength,
    bDescriptorType: byte;
    wData: packed array [0..0] of word;
  end;

  usb_hid_descriptor = packed record
    bLength,
    bDescriptorType: byte;
    bcdHID: word;
    bCountryCode,
    bNumDescriptors: byte;
  end;

const
  // Endpoint descriptor
  USB_MAXENDPOINTS = 32;

type
  // Endpoint descriptor
  pusb_endpoint_descriptor = ^usb_endpoint_descriptor;
  usb_endpoint_descriptor = packed record
    bLength,
    bDescriptorType,
    bEndpointAddress,
    bmAttributes: byte;

    wMaxPacketSize: word;

    bInterval,
    bRefresh,
    bSynchAddress: byte;

    extra: PByte; // Extra descriptors
    extralen: longword;
  end;
  // pascal translation of C++ struc
  TArray_usb_endpoint_descriptor =
   packed array [0..65535] of usb_endpoint_descriptor;
  PArray_usb_endpoint_descriptor = ^TArray_usb_endpoint_descriptor;


const
  USB_ENDPOINT_ADDRESS_MASK      = $0f; // in bEndpointAddress
  USB_ENDPOINT_DIR_MASK          = $80;

  USB_ENDPOINT_TYPE_MASK         = $03; // in bmAttributes
  USB_ENDPOINT_TYPE_CONTROL      = 0;
  USB_ENDPOINT_TYPE_ISOCHRONOUS  = 1;
  USB_ENDPOINT_TYPE_BULK         = 2;
  USB_ENDPOINT_TYPE_INTERRUPT    = 3;

  // Interface descriptor
  USB_MAXINTERFACES = 32;

type
  // Interface descriptor
  pusb_interface_descriptor = ^usb_interface_descriptor;
  usb_interface_descriptor = packed record
    bLength,
    bDescriptorType,
    bInterfaceNumber,
    bAlternateSetting,
    bNumEndpoints,
    bInterfaceClass,
    bInterfaceSubClass,
    bInterfaceProtocol,
    iInterface: byte;

    endpoint: PArray_usb_endpoint_descriptor;

    extra: PByte; // Extra descriptors
    extralen: longword;
  end;
  // pascal translation of C++ struc
  TArray_usb_interface_descriptor =
   packed array [0..65535] of usb_interface_descriptor;
  PArray_usb_interface_descriptor = ^TArray_usb_interface_descriptor;


const
  USB_MAXALTSETTING = 128; // Hard limit

type
  pusb_interface = ^usb_interface;
  usb_interface = packed record
    altsetting: PArray_usb_interface_descriptor;
    num_altsetting: longword;
  end;
  // pascal translation of C++ struc
  TArray_usb_interface = packed array [0..65535] of usb_interface;
  PArray_usb_interface = ^TArray_usb_interface;


const
  // Configuration descriptor information..
  USB_MAXCONFIG = 8;

type
  // Configuration descriptor information..
  pusb_config_descriptor = ^usb_config_descriptor;
  usb_config_descriptor = packed record
    bLength,
    bDescriptorType: byte;

    wTotalLength: word;

    bNumInterfaces,
    bConfigurationValue,
    iConfiguration,
    bmAttributes,
    MaxPower: byte;

    iinterface: PArray_usb_interface;

    extra: PByte; // Extra descriptors
    extralen: longword;
  end;
  // pascal translation of C++ struc
  TArray_usb_config_descriptor =
   packed array [0..65535] of usb_config_descriptor;
  PArray_usb_config_descriptor = ^TArray_usb_config_descriptor;


  // Device descriptor
  usb_device_descriptor = packed record
    bLength,
    bDescriptorType: byte;
    bcdUSB: word;

    bDeviceClass,
    bDeviceSubClass,
    bDeviceProtocol,
    bMaxPacketSize0: byte;

    idVendor,
    idProduct,
    bcdDevice: word;

    iManufacturer,
    iProduct,
    iSerialNumber,
    bNumConfigurations: byte;
  end;

  usb_ctrl_setup = packed record
    bRequestType,
    bRequest: byte;
    wValue,
    wIndex,
    wLength: word;
  end;

const
  // Standard requests
  USB_REQ_GET_STATUS         = $00;
  USB_REQ_CLEAR_FEATURE      = $01;
  // $02 is reserved
  USB_REQ_SET_FEATURE        = $03;
  // $04 is reserved
  USB_REQ_SET_ADDRESS        = $05;
  USB_REQ_GET_DESCRIPTOR     = $06;
  USB_REQ_SET_DESCRIPTOR     = $07;
  USB_REQ_GET_CONFIGURATION  = $08;
  USB_REQ_SET_CONFIGURATION  = $09;
  USB_REQ_GET_INTERFACE      = $0A;
  USB_REQ_SET_INTERFACE      = $0B;
  USB_REQ_SYNCH_FRAME        = $0C;

  USB_TYPE_STANDARD   = ($00 shl 5);
  USB_TYPE_CLASS      = ($01 shl 5);
  USB_TYPE_VENDOR     = ($02 shl 5);
  USB_TYPE_RESERVED   = ($03 shl 5);

  USB_RECIP_DEVICE     = $00;
  USB_RECIP_INTERFACE  = $01;
  USB_RECIP_ENDPOINT   = $02;
  USB_RECIP_OTHER      = $03;

  // Various libusb API related stuff
  USB_ENDPOINT_IN   = $80;
  USB_ENDPOINT_OUT  = $00;

  // Error codes
  USB_ERROR_BEGIN  = 500000;

type
  pusb_device = ^usb_device;
  pusb_bus = ^usb_bus;

  usb_device = record
    next,
    prev: pusb_device;
    filename: packed array [0..LIBUSB_PATH_MAX+1] of char;
    bus: pusb_bus;
    descriptor: usb_device_descriptor;
    config: PArray_usb_config_descriptor;
    dev: pointer; // Darwin support
    devnum,
     num_children: byte;
     children : ^pusb_device;
  end;

  usb_bus = record
    next,
    prev: pusb_bus;
    dirname: packed array [0..LIBUSB_PATH_MAX+1] of char;
    devices: pusb_device;
    location: longint;
     root_dev: pusb_device;
   end;

  // Version information, Windows specific
  pusb_version = ^usb_version;
  usb_version = packed record
    dllmajor,
    dllminor,
    dllmicro,
    dllnano: longint;
    drivermajor,
    driverminor,
    drivermicro,
    drivernano: longint;
  end;

  pusb_dev_handle = pointer; // struct usb_dev_handle;


{ Function prototypes }

// usb.c
function  usb_open(dev: pusb_device): pusb_dev_handle; cdecl;
function  usb_close(dev: pusb_dev_handle): longword; cdecl;
function  usb_get_string(dev: pusb_dev_handle;index, langid: longword; var buf;buflen: longword): longword; cdecl;
function  usb_get_string_simple(dev: pusb_dev_handle;index: longword; var buf;buflen: longword): longword; cdecl;


// descriptors.c
function  usb_get_descriptor_by_endpoint(udev: pusb_dev_handle;ep: longword;ttype: byte;index: byte;var buf;size: longword): longword; cdecl;
function  usb_get_descriptor(udev: pusb_dev_handle;ttype: byte;index: byte;var buf;size: longword): longword; cdecl;

// <arch>.c
function  usb_bulk_write(dev: pusb_dev_handle;ep : longword; var bytes;size,timeout:longword): integer; cdecl;
function  usb_bulk_read(dev: pusb_dev_handle;ep: longword; var bytes; size,timeout:longword): integer; cdecl;

function  usb_interrupt_write(dev: pusb_dev_handle;ep : longword; var bytes; size, timeout: longword): longword; cdecl;
function  usb_interrupt_read(dev: pusb_dev_handle;ep : longword; var bytes; size, timeout: longword): longword; cdecl;
//function  usb_control_msg(dev: pusb_dev_handle;requesttype, request, value, index: longword;var bytes;size, timeout: longword): longword; cdecl;
function  usb_control_msg(dev: pusb_dev_handle;requesttype, request, value, index: integer;var bytes;size, timeout: integer): integer; cdecl;
function  usb_set_configuration(dev: pusb_dev_handle;configuration: longword): longword; cdecl;
function  usb_claim_interface(dev: pusb_dev_handle;iinterface: longword): longword;  cdecl; // was interface, a pascal reserved word
function  usb_release_interface(dev: pusb_dev_handle;iinterface: longword): longword; cdecl;
function  usb_set_altinterface(dev: pusb_dev_handle;alternate: longword): longword; cdecl;
function  usb_resetep(dev: pusb_dev_handle;ep: longword): longword; cdecl;
function  usb_clear_halt(dev: pusb_dev_handle;ep: longword): longword; cdecl;
function  usb_reset(dev: pusb_dev_handle): longword; cdecl;

function usb_strerror: pchar; cdecl;

procedure usb_init; cdecl;
procedure usb_set_debug(level: longword); cdecl;
function  usb_find_busses: longword; cdecl;
function  usb_find_devices: longword; cdecl;
function  usb_get_device(dev: pusb_dev_handle): pusb_device;  cdecl; // renamed from usb_device because of same named record
function  usb_get_busses: pusb_bus; cdecl;

implementation


function  usb_open(dev: pusb_device): pusb_dev_handle; cdecl; external LIBUSB_DLL_NAME name 'usb_open';
function  usb_close(dev: pusb_dev_handle): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_close';
function  usb_get_string(dev: pusb_dev_handle;index, langid: longword;var buf;buflen: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_get_string';
function  usb_get_string_simple(dev: pusb_dev_handle;index: longword;var buf;buflen: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_get_string_simple';


// descriptors.c
function  usb_get_descriptor_by_endpoint(udev: pusb_dev_handle;ep: longword;ttype: byte;index: byte;var buf;size: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_get_descriptor_by_endpoint';
function  usb_get_descriptor(udev: pusb_dev_handle;ttype: byte;index: byte;var buf;size: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_get_descriptor';

// <arch>.c
function  usb_bulk_write(dev: pusb_dev_handle;ep : longword; var bytes;size,timeout:longword): integer; cdecl; external LIBUSB_DLL_NAME name 'usb_bulk_write';
function  usb_bulk_read(dev: pusb_dev_handle;ep: longword; var bytes; size,timeout:longword): integer; cdecl; external LIBUSB_DLL_NAME name 'usb_bulk_read';

function  usb_interrupt_write(dev: pusb_dev_handle;ep : longword; var bytes; size, timeout: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_interrupt_write';
function  usb_interrupt_read(dev: pusb_dev_handle;ep : longword; var bytes; size, timeout: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_interrupt_read';
//function  usb_control_msg(dev: pusb_dev_handle;requesttype, request, value, index: longword;var bytes;size, timeout: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_control_msg';
function  usb_control_msg(dev: pusb_dev_handle;requesttype, request, value, index: integer;var bytes;size, timeout: integer): integer; cdecl; external LIBUSB_DLL_NAME name 'usb_control_msg';
function  usb_set_configuration(dev: pusb_dev_handle;configuration: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_set_configuration';
function  usb_claim_interface(dev: pusb_dev_handle;iinterface: longword): longword;  cdecl; external LIBUSB_DLL_NAME name 'usb_claim_interface';// was interface, a pascal reserved word
function  usb_release_interface(dev: pusb_dev_handle;iinterface: longword): longword;  cdecl; external LIBUSB_DLL_NAME name 'usb_release_interface';
function  usb_set_altinterface(dev: pusb_dev_handle;alternate: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_set_altinterface';
function  usb_resetep(dev: pusb_dev_handle;ep: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_resetep';
function  usb_clear_halt(dev: pusb_dev_handle;ep: longword): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_clear_halt';
function  usb_reset(dev: pusb_dev_handle): longword; cdecl; external LIBUSB_DLL_NAME name 'usb_reset';

function  usb_strerror: pchar; cdecl; external LIBUSB_DLL_NAME name 'usb_strerror';

procedure usb_init; cdecl; external LIBUSB_DLL_NAME name 'usb_init';
procedure usb_set_debug(level: longword); cdecl; external LIBUSB_DLL_NAME name 'usb_set_debug';
function  usb_find_busses: longword; cdecl; external LIBUSB_DLL_NAME name 'usb_find_busses';
function  usb_find_devices: longword; cdecl; external LIBUSB_DLL_NAME name 'usb_find_devices';
function  usb_get_device(dev: pusb_dev_handle): pusb_device;  cdecl; external LIBUSB_DLL_NAME name 'usb_device'; // renamed from usb_device because of same named record
function  usb_get_busses: pusb_bus; cdecl; external LIBUSB_DLL_NAME name 'usb_get_busses';




end.
