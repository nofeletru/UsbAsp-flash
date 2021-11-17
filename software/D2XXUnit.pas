unit D2XXUnit;
{$MODE DELPHI}
interface

Type FT_Result = Integer;



// Device Info Node structure for info list functions
type FT_Device_Info_Node = record
  Flags         : DWord;
  DeviceType    : Dword;
  ID            : DWord;
  LocID         : DWord;
  SerialNumber  : array [0..15] of Char;
  Description   : array [0..63] of Char;
  DeviceHandle  : DWord;
end;


type TDWordptr = ^DWord;

// Structure to hold EEPROM data for FT_EE_Program function
TFT_Program_Data = record
  Signature1        : DWord;
  Signature2        : DWord;
  Version           : DWord;
  VendorID          : Word;
  ProductID         : Word;
  Manufacturer      : PChar;
  ManufacturerID    : PChar;
  Description       : PChar;
  SerialNumber      : PChar;
  MaxPower          : Word;
  PnP               : Word;
  SelfPowered       : Word;
  RemoteWakeup      : Word;
// Rev4 extensions
  Rev4              : Byte;
  IsoIn             : Byte;
  IsoOut            : Byte;
  PullDownEnable    : Byte;
  SerNumEnable      : Byte;
  USBVersionEnable  : Byte;
  USBVersion        : Word;
// FT2232C extensions
  Rev5              : Byte;
  IsoInA            : Byte;
  IsoInB            : Byte;
  IsoOutA           : Byte;
  IsoOutB           : Byte;
  PullDownEnable5   : Byte;
  SerNumEnable5     : Byte;
  USBVersionEnable5 : Byte;
  USBVersion5       : Word;
  AIsHighCurrent    : Byte;
  BIsHighCurrent    : Byte;
  IFAIsFifo         : Byte;
  IFAIsFifoTar      : Byte;
  IFAIsFastSer      : Byte;
  AIsVCP            : Byte;
  IFBIsFifo         : Byte;
  IFBIsFifoTar      : Byte;
  IFBIsFastSer      : Byte;
  BIsVCP            : Byte;
// FT232R extensions
  UseExtOsc         : Byte;
  HighDriveIOs      : Byte;
  EndpointSize      : Byte;
  PullDownEnableR   : Byte;
  SerNumEnableR     : Byte;
  InvertTXD         : Byte;
  InvertRXD         : Byte;
  InvertRTS         : Byte;
  InvertCTS         : Byte;
  InvertDTR         : Byte;
  InvertDSR         : Byte;
  InvertDCD         : Byte;
  InvertRI          : Byte;
  Cbus0             : Byte;
  Cbus1             : Byte;
  Cbus2             : Byte;
  Cbus3             : Byte;
  Cbus4             : Byte;
  RIsVCP            : Byte;
end;


// Exported Functions
// Classic Functions
Function GetFTDeviceCount : FT_Result;
Function GetFTDeviceSerialNo(DeviceIndex:DWord) : FT_Result;
Function GetFTDeviceDescription(DeviceIndex:DWord) : FT_Result;
Function GetFTDeviceLocation(DeviceIndex:DWord) : FT_Result;
Function Open_USB_Device : FT_Result;
Function Open_USB_Device_By_Serial_Number(Serial_Number:string) : FT_Result;
Function Open_USB_Device_By_Device_Description(Device_Description:string) : FT_Result;
Function Open_USB_Device_By_Device_Location(Location:DWord) : FT_Result;
Function Close_USB_Device : FT_Result;
Function Read_USB_Device_Buffer(Read_Count:Integer) : Integer;
Function Write_USB_Device_Buffer(Write_Count:Integer) : Integer;
Function Reset_USB_Device : FT_Result;
Function Set_USB_Device_BaudRate : FT_Result;
Function Set_USB_Device_BaudRate_Divisor(Divisor:Dword) : FT_Result;
Function Set_USB_Device_DataCharacteristics : FT_Result;
Function Set_USB_Device_FlowControl : FT_Result;
Function Set_USB_Device_RTS : FT_Result;
Function Clr_USB_Device_RTS : FT_Result;
Function Set_USB_Device_DTR : FT_Result;
Function Clr_USB_Device_DTR : FT_Result;
Function Get_USB_Device_ModemStatus : FT_Result;
Function Set_USB_Device_Chars : FT_Result;
Function Purge_USB_Device_Out : FT_Result;
Function Purge_USB_Device_In : FT_Result;
Function Set_USB_Device_TimeOuts(ReadTimeOut,WriteTimeOut:DWord) : FT_Result;
Function Get_USB_Device_QueueStatus : FT_Result;
Function Set_USB_Device_Break_On : FT_Result;
Function Set_USB_Device_Break_Off : FT_Result;
Function Get_USB_Device_Status : FT_Result;
Function Set_USB_Device_Event_Notification(EventMask:DWord) : FT_Result;
Function USB_FT_GetDeviceInfo(DevType,ID:DWord; SerialNumber,Description:array of char) : FT_Result;
Function Set_USB_Device_Reset_Pipe_Retry_Count(RetryCount:DWord) : FT_Result;
Function Stop_USB_Device_InTask : FT_Result;
Function Restart_USB_Device_InTask : FT_Result;
Function Reset_USB_Port : FT_Result;
Function Cycle_USB_Port : FT_Result;
Function Create_USB_Device_List : FT_Result;
Function Get_USB_Device_List : FT_Result;
Function Get_USB_Device_List_Detail(Index:DWord) : FT_Result;
// EEPROM Functions
function USB_FT_EE_Read : FT_Result;
function USB_FT_C_EE_Read : FT_Result;
function USB_FT_R_EE_Read : FT_Result;
function USB_FT_EE_Program : FT_Result;
function USB_FT_ReadEE(WordAddr:Dword) : FT_Result;
function USB_FT_WriteEE(WordAddr:Dword;WordData:Word) : FT_Result;
function USB_FT_EraseEE : FT_Result;
function USB_FT_EE_UARead : FT_Result;
function USB_FT_EE_UAWrite : FT_Result;
function USB_FT_EE_UASize : FT_Result;
// FT2232C, FT232BM and FT245BM Extended API Functions
Function Get_USB_Device_LatencyTimer : FT_Result;
Function Set_USB_Device_LatencyTimer(Latency : Byte) : FT_Result;
Function Get_USB_Device_BitMode(var BitMode:Byte) : FT_Result;
Function Set_USB_Device_BitMode(Mask, Enable:Byte) : FT_Result;
Function Set_USB_Parameters(InSize, OutSize:Dword) : FT_Result;

Function Get_USB_Driver_Version(DrVersion :  TDWordptr): FT_Result;
Function Get_USB_Library_Version(LbVersion :  TDWordptr): FT_Result;




Var
// Port Handle Returned by the Open Function
// Used by the Subsequent Function Calls
    FT_HANDLE : DWord = 0;
// Used to handle multiple device instances in future
// versions. Must be set to 0 for now.
//    PV_Device : DWord = 0;

// Holding Variables for the current settings
// Can be configured visually using the CFGUnit Unit
// or manually before calling SetUp_USB_Device
    FT_Current_Baud : Dword;
    FT_Current_DataBits : Byte;
    FT_Current_StopBits : Byte;
    FT_Current_Parity : Byte;
    FT_Current_FlowControl : Word;
    FT_RTS_On : Boolean;
    FT_DTR_On : Boolean;
    FT_Event_On : Boolean;
    FT_Error_On : Boolean;
    FT_XON_Value : Byte = $11;
    FT_XOFF_Value : Byte = $13;
    FT_EVENT_Value : Byte = $0;
    FT_ERROR_Value : Byte = $0;
// Used by CFGUnit to flag a bad value
    FT_SetupError : Boolean;
// Used to Return the current Modem Status
    FT_Modem_Status : DWord;
//  Used to return the number of bytes pending
//  in the Rx Buffer Queue
    FT_Q_Bytes : DWord;
    FT_TxQ_Bytes : DWord;
    FT_Event_Status : DWord;
//  Used to Enable / Disable the Error Report Dialog
    FT_Enable_Error_Report : Boolean = True;
//  Deposit for Get latency timer
    FT_LatencyRd : Byte;

    FT_DeviceInfoList : array of FT_Device_Info_Node;

    Manufacturer: array [0..63] of char;
    ManufacturerID: array [0..15] of char;
    Description:  array [0..63] of char;
    SerialNumber:  array [0..15] of char;
    LocID : DWord;
    EEDataBuffer : TFT_Program_Data;
    UserData :  array [0..63] of byte;
    FT_UA_Size : integer;
    WordRead : Word;


Const
// FT_Result Values
    FT_OK = 0;
    FT_INVALID_HANDLE = 1;
    FT_DEVICE_NOT_FOUND = 2;
    FT_DEVICE_NOT_OPENED = 3;
    FT_IO_ERROR = 4;
    FT_INSUFFICIENT_RESOURCES = 5;
    FT_INVALID_PARAMETER = 6;
    FT_SUCCESS = FT_OK;
    FT_INVALID_BAUD_RATE = 7;
    FT_DEVICE_NOT_OPENED_FOR_ERASE = 8;
    FT_DEVICE_NOT_OPENED_FOR_WRITE = 9;
    FT_FAILED_TO_WRITE_DEVICE = 10;
    FT_EEPROM_READ_FAILED = 11;
    FT_EEPROM_WRITE_FAILED = 12;
    FT_EEPROM_ERASE_FAILED = 13;
    FT_EEPROM_NOT_PRESENT = 14;
    FT_EEPROM_NOT_PROGRAMMED = 15;
    FT_INVALID_ARGS = 16;
    FT_OTHER_ERROR = 17;
// FT_Open_Ex Flags
    FT_OPEN_BY_SERIAL_NUMBER = 1;
    FT_OPEN_BY_DESCRIPTION = 2;
    FT_OPEN_BY_LOCATION = 4;
// FT_List_Devices Flags
    FT_LIST_NUMBER_ONLY = $80000000;
    FT_LIST_BY_INDEX = $40000000;
    FT_LIST_ALL = $20000000;
// Baud Rate Selection
    FT_BAUD_300 = 300;
    FT_BAUD_600 = 600;
    FT_BAUD_1200 = 1200;
    FT_BAUD_2400 = 2400;
    FT_BAUD_4800 = 4800;
    FT_BAUD_9600 = 9600;
    FT_BAUD_14400 = 14400;
    FT_BAUD_19200 = 19200;
    FT_BAUD_38400 = 38400;
    FT_BAUD_57600 = 57600;
    FT_BAUD_115200 = 115200;
    FT_BAUD_230400 = 230400;
    FT_BAUD_460800 = 460800;
    FT_BAUD_921600 = 921600;
// Data Bits Selection
    FT_DATA_BITS_7 = 7;
    FT_DATA_BITS_8 = 8;
// Stop Bits Selection
    FT_STOP_BITS_1 = 0;
    FT_STOP_BITS_2 = 2;
// Parity Selection
    FT_PARITY_NONE = 0;
    FT_PARITY_ODD = 1;
    FT_PARITY_EVEN = 2;
    FT_PARITY_MARK = 3;
    FT_PARITY_SPACE = 4;
// Flow Control Selection
    FT_FLOW_NONE = $0000;
    FT_FLOW_RTS_CTS = $0100;
    FT_FLOW_DTR_DSR = $0200;
    FT_FLOW_XON_XOFF = $0400;
// Purge Commands
    FT_PURGE_RX = 1;
    FT_PURGE_TX = 2;
// Notification Events
    FT_EVENT_RXCHAR = 1;
    FT_EVENT_MODEM_STATUS = 2;
// Modem Status
    CTS = $10;
    DSR = $20;
    RI = $40;
    DCD = $80;
// Bit Modes
    FT_BITMODE_RESET =				$00; //Reset
    FT_BITMODE_ASYNC_BITBANG =		$01; //Asynchronous Bit Bang
    FT_BITMODE_MPSSE =				$02; //MPSSE (FT2232, FT2232H, FT4232H and FT232H devices only)
    FT_BITMODE_SYNC_BITBANG =		$04; //Synchronous Bit Bang (FT232R, FT245R, FT2232, FT2232H, FT4232H and FT232H devices only)
    FT_BITMODE_MCU_HOST =			$08; //MCU Host Bus Emulation Mode (FT2232, FT2232H, FT4232H and FT232H devices only)
    FT_BITMODE_FAST_SERIAL =		$10; //Fast Opto-Isolated Serial Mode (FT2232, FT2232H, FT4232H and FT232H devices only)
	FT_BITMODE_CBUS_BITBANG = 		$20; //CBUS Bit Bang Mode (FT232R and FT232H devices only)
    FT_BITMODE_SYNC_FIFO =			$40; //Single Channel Synchronous 245 FIFO Mode (FT2232H and FT232H devices only)	


// IO Buffer Sizes
    FT_In_Buffer_Size = $10000;    // 64k
    FT_In_Buffer_Index = FT_In_Buffer_Size - 1;
    FT_Out_Buffer_Size = $10000;    // 64k
    FT_Out_Buffer_Index = FT_Out_Buffer_Size - 1;
// DLL Name
    FT_DLL_Name = 'FTD2XX.DLL';


var
// Declare Input and Output Buffers
   FT_In_Buffer : Array[0..FT_In_Buffer_Index] of Byte;
   FT_Out_Buffer : Array[0..FT_Out_Buffer_Index] of Byte;
// A variable used to detect time-outs
// Attach a timer to the main project form
// which decrements this every 10mS if
// FT_TimeOut_Count <> 0
   FT_TimeOut_Count : Integer = 0;
// Used to determine how many bytes were
// actually received by FT_Read_Device_All
// in the case of a time-out
   FT_All_Bytes_Received : Integer = 0;
   FT_IO_Status : Ft_Result = FT_OK;
// Used By FT_ListDevices
   FT_Device_Count : DWord;
   FT_Device_String_Buffer : array [1..50] of Char;
   FT_Device_String : String;
   FT_Device_Location : DWord;
   USB_Device_Info_Node : FT_Device_Info_Node;
   FT_Event_Handle : DWord;


implementation
uses main;
//Classic functions
function FT_GetNumDevices(pvArg1:Pointer; pvArg2:Pointer; dwFlags:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_ListDevices';
function FT_ListDevices(pvArg1:Dword; pvArg2:Pointer; dwFlags:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_ListDevices';
function FT_Open(Index:Integer; ftHandle:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_Open';
function FT_OpenEx(pvArg1:Pointer; dwFlags:Dword; ftHandle:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_OpenEx';
function FT_OpenByLocation(pvArg1:DWord; dwFlags:Dword; ftHandle:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_OpenEx';
function FT_Close(ftHandle:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_Close';
function FT_Read(ftHandle:Dword; FTInBuf:Pointer; BufferSize:LongInt; ResultPtr:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_Read';
function FT_Write(ftHandle:Dword; FTOutBuf:Pointer; BufferSize:LongInt; ResultPtr:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_Write';
function FT_ResetDevice(ftHandle:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_ResetDevice';
function FT_SetBaudRate(ftHandle:Dword; BaudRate:DWord):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetBaudRate';
function FT_SetDivisor(ftHandle:Dword; Divisor:DWord):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetDivisor';
function FT_SetDataCharacteristics(ftHandle:Dword; WordLength,StopBits,Parity:Byte):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetDataCharacteristics';
function FT_SetFlowControl(ftHandle:Dword; FlowControl:Word; XonChar,XoffChar:Byte):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetFlowControl';
function FT_SetDtr(ftHandle:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetDtr';
function FT_ClrDtr(ftHandle:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_ClrDtr';
function FT_SetRts(ftHandle:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetRts';
function FT_ClrRts(ftHandle:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_ClrRts';
function FT_GetModemStatus(ftHandle:Dword; ModemStatus:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_GetModemStatus';
function FT_SetChars(ftHandle:Dword; EventChar,EventCharEnabled,ErrorChar,ErrorCharEnabled:Byte):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetChars';
function FT_Purge(ftHandle:Dword; Mask:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_Purge';
function FT_SetTimeouts(ftHandle:Dword; ReadTimeout,WriteTimeout:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetTimeouts';
function FT_GetQueueStatus(ftHandle:Dword; RxBytes:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_GetQueueStatus';
function FT_SetBreakOn(ftHandle:Dword) : FT_Result; stdcall; External FT_DLL_Name name 'FT_SetBreakOn';
function FT_SetBreakOff(ftHandle:Dword) : FT_Result; stdcall; External FT_DLL_Name name 'FT_SetBreakOff';
function FT_GetStatus(ftHandle:DWord; RxBytes,TxBytes,EventStatus:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_GetStatus';
function FT_SetEventNotification(ftHandle:DWord; EventMask:DWord; pvArgs:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetEventNotification';
function FT_GetDeviceInfo(ftHandle:DWord; DevType,ID,SerNum,Desc,pvDummy:Pointer) : FT_Result; stdcall; External FT_DLL_Name name 'FT_GetDeviceInfo';
function FT_SetResetPipeRetryCount(ftHandle:Dword; RetryCount:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetResetPipeRetryCount';
function FT_StopInTask(ftHandle:Dword) : FT_Result; stdcall; External FT_DLL_Name name 'FT_StopInTask';
function FT_RestartInTask(ftHandle:Dword) : FT_Result; stdcall; External FT_DLL_Name name 'FT_RestartInTask';
function FT_ResetPort(ftHandle:Dword) : FT_Result; stdcall; External FT_DLL_Name name 'FT_ResetPort';
function FT_CyclePort(ftHandle:Dword) : FT_Result; stdcall; External 'FTD2XX.DLL' name 'FT_CyclePort';
function FT_CreateDeviceInfoList(NumDevs:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_CreateDeviceInfoList';
function FT_GetDeviceInfoList(pFT_Device_Info_List:Pointer; NumDevs:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_GetDeviceInfoList';
function FT_GetDeviceInfoDetail(Index:DWord; Flags,DevType,ID,LocID,SerialNumber,Description,DevHandle:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_GetDeviceInfoDetail';
function FT_GetDriverVersion(ftHandle:Dword; DrVersion:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_GetDriverVersion';
function FT_GetLibraryVersion(LbVersion:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_GetLibraryVersion';

// EEPROM functions
function FT_EE_Read(ftHandle:DWord; pEEData:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_EE_Read';
function FT_EE_Program(ftHandle:DWord; pEEData:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_EE_Program';
// EEPROM primitives - you need an NDA for EEPROM checksum
function FT_ReadEE(ftHandle:DWord; WordAddr:DWord; WordRead:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_ReadEE';
function FT_WriteEE(ftHandle:DWord; WordAddr:DWord; WordData:word):FT_Result; stdcall; External FT_DLL_Name name 'FT_WriteEE';
function FT_EraseEE(ftHandle:DWord):FT_Result; stdcall; External FT_DLL_Name name 'FT_EraseEE';
function FT_EE_UARead(ftHandle:DWord; Data:Pointer; DataLen:DWord; BytesRead:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_EE_UARead';
function FT_EE_UAWrite(ftHandle:DWord; Data:Pointer; DataLen:DWord):FT_Result; stdcall; External FT_DLL_Name name 'FT_EE_UAWrite';
function FT_EE_UASize(ftHandle:DWord; UASize:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_EE_UASize';

// FT2232C, FT232BM and FT245BM Extended API Functions
function FT_GetLatencyTimer(ftHandle:Dword; Latency:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_GetLatencyTimer';
function FT_SetLatencyTimer(ftHandle:Dword; Latency:Byte):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetLatencyTimer';
function FT_GetBitMode(ftHandle:Dword; BitMode:Pointer):FT_Result; stdcall; External FT_DLL_Name name 'FT_GetBitMode';
function FT_SetBitMode(ftHandle:Dword; Mask,Enable:Byte):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetBitMode';
function FT_SetUSBParameters(ftHandle:Dword; InSize,OutSize:Dword):FT_Result; stdcall; External FT_DLL_Name name 'FT_SetUSBParameters';


Procedure FT_Error_Report(ErrStr: String; PortStatus : Integer);
Var Str : String;
Begin
If Not FT_Enable_Error_Report then Exit;
If PortStatus = FT_OK then Exit;
Case PortStatus of
    FT_INVALID_HANDLE : Str := ErrStr+' - Invalid handle...';
    FT_DEVICE_NOT_FOUND : Str := ErrStr+' - Device not found...';
    FT_DEVICE_NOT_OPENED : Str := ErrStr+' - Device not opened...';
    FT_IO_ERROR : Str := ErrStr+' - General IO error...';
    FT_INSUFFICIENT_RESOURCES : Str := ErrStr+' - Insufficient resources...';
    FT_INVALID_PARAMETER : Str := ErrStr+' - Invalid parameter...';
    FT_INVALID_BAUD_RATE : Str := ErrStr+' - Invalid baud rate...';
    FT_DEVICE_NOT_OPENED_FOR_ERASE : Str := ErrStr+' Device not opened for erase...';
    FT_DEVICE_NOT_OPENED_FOR_WRITE : Str := ErrStr+' Device not opened for write...';
    FT_FAILED_TO_WRITE_DEVICE : Str := ErrStr+' - Failed to write...';
    FT_EEPROM_READ_FAILED : Str := ErrStr+' - EEPROM read failed...';
    FT_EEPROM_WRITE_FAILED : Str := ErrStr+' - EEPROM write failed...';
    FT_EEPROM_ERASE_FAILED : Str := ErrStr+' - EEPROM erase failed...';
    FT_EEPROM_NOT_PRESENT : Str := ErrStr+' - EEPROM not present...';
    FT_EEPROM_NOT_PROGRAMMED : Str := ErrStr+' - EEPROM not programmed...';
    FT_INVALID_ARGS : Str := ErrStr+' - Invalid arguments...';
    FT_OTHER_ERROR : Str := ErrStr+' - Other error ...';
    End;
LogPrint(Str);
End;


Function GetDeviceString : String;
Var I : Integer;
Begin
Result := ''; I := 1;
FT_Device_String_Buffer[50] := Chr(0); // Just in case !
While FT_Device_String_Buffer[I] <> Chr(0) do
  Begin
  Result := Result + FT_Device_String_Buffer[I];
  Inc(I);
  End;
End;


Procedure SetDeviceString ( S : String );
Var I,L : Integer;
Begin
FT_Device_String_Buffer[1] := Chr(0);
L := Length(S);  If L > 49 then L := 49;
If L = 0 then Exit;
For I := 1 to L do FT_Device_String_Buffer[I] := S[I];
FT_Device_String_Buffer[L+1] := Chr(0);
End;


// FTD2XX functions from here
Function GetFTDeviceCount : FT_Result;
Begin
Result := FT_GetNumDevices(@FT_Device_Count,Nil,FT_LIST_NUMBER_ONLY);
If Result <> FT_OK then FT_Error_Report('GetFTDeviceCount',Result);
End;

Function GetFTDeviceSerialNo(DeviceIndex:DWord) : FT_Result;
Begin
Result := FT_ListDevices(DeviceIndex,@SerialNumber,(FT_OPEN_BY_SERIAL_NUMBER or FT_LIST_BY_INDEX));
If Result = FT_OK then FT_Device_String := SerialNumber;
If Result <> FT_OK then FT_Error_Report('GetFTDeviceSerialNo',Result);
End;


Function GetFTDeviceDescription(DeviceIndex:DWord) : FT_Result;
Begin
Result := FT_ListDevices(DeviceIndex,@Description,(FT_OPEN_BY_DESCRIPTION or FT_LIST_BY_INDEX));
If Result = FT_OK then FT_Device_String := Description;
If Result <> FT_OK then FT_Error_Report('GetFTDeviceDescription',Result);
End;


Function GetFTDeviceLocation(DeviceIndex:DWord) : FT_Result;
Begin
Result := FT_ListDevices(DeviceIndex,@LocID,(FT_OPEN_BY_LOCATION or FT_LIST_BY_INDEX));
If Result = FT_OK then FT_Device_Location := LocID;
If Result <> FT_OK then FT_Error_Report('GetFTDeviceLocation',Result);
End;


Function Open_USB_Device : FT_Result;
Var
  DevIndex : DWord;
Begin
DevIndex := 0;
Result := FT_Open(DevIndex,@FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_Open',Result);
End;


Function Open_USB_Device_By_Serial_Number(Serial_Number:string) : FT_Result;
Begin
SetDeviceString(Serial_Number);
Result := FT_OpenEx(@FT_Device_String_Buffer,FT_OPEN_BY_SERIAL_NUMBER,@FT_Handle);
If Result <> FT_OK then FT_Error_Report('Open_USB_Device_By_Serial_Number',Result);
End;


Function Open_USB_Device_By_Device_Description(Device_Description:string) : FT_Result;
Begin
SetDeviceString(Device_Description);
Result := FT_OpenEx(@FT_Device_String_Buffer,FT_OPEN_BY_DESCRIPTION,@FT_Handle);
If Result <> FT_OK then FT_Error_Report('Open_USB_Device_By_Device_Description',Result);
End;


Function Open_USB_Device_By_Device_Location(Location:DWord) : FT_Result;
Begin
Result := FT_OpenByLocation(Location,FT_OPEN_BY_LOCATION,@FT_Handle);
If Result <> FT_OK then FT_Error_Report('Open_USB_Device_By_Device_Location',Result);
End;


Function Close_USB_Device : FT_Result;
Begin
Result :=  FT_Close(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_Close',Result);
End;


function Read_USB_Device_Buffer( Read_Count : Integer ) : Integer;
// Reads Read_Count Bytes (or less) from the USB device to the FT_In_Buffer
// Function returns the number of bytes actually received  which may range from zero
// to the actual number of bytes requested, depending on how many have been received
// at the time of the request + the read timeout value.
Var Read_Result : Integer;
Begin

if (read_count = 1) then
  begin
  read_result := read_count;
  end;
FT_IO_Status := FT_Read(FT_Handle,@FT_In_Buffer,Read_Count,@Read_Result);
If FT_IO_Status <> FT_OK then FT_Error_Report('FT_Read',FT_IO_Status);
Result := Read_Result;
End;


function Write_USB_Device_Buffer( Write_Count : Integer ) : Integer;
// Writes Write_Count Bytes from FT_Out_Buffer to the USB device
// Function returns the number of bytes actually sent
// In this example, Write_Count should be 32k bytes max
Var Write_Result : Integer;
Begin
FT_IO_Status := FT_Write(FT_Handle,@FT_Out_Buffer,Write_Count,@Write_Result);
If FT_IO_Status <> FT_OK then FT_Error_Report('FT_Write',FT_IO_Status);
Result := Write_Result;
End;


Function Reset_USB_Device : FT_Result;
Begin
Result :=  FT_ResetDevice(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_ResetDevice',Result);
End;


Function Set_USB_Device_BaudRate : FT_Result;
Begin
Result :=  FT_SetBaudRate(FT_Handle,FT_Current_Baud);
If Result <> FT_OK then FT_Error_Report('FT_SetBaudRate',Result);
End;


Function Set_USB_Device_BaudRate_Divisor(Divisor:Dword) : FT_Result;
Begin
Result :=  FT_SetDivisor(FT_Handle,Divisor);
If Result <> FT_OK then FT_Error_Report('FT_SetDivisor',Result);
End;


Function Set_USB_Device_DataCharacteristics : FT_Result;
Begin
Result :=  FT_SetDataCharacteristics(FT_Handle,FT_Current_DataBits,FT_Current_StopBits,FT_Current_Parity);
If Result <> FT_OK then FT_Error_Report('FT_SetDataCharacteristics',Result);
End;


Function Set_USB_Device_FlowControl : FT_Result;
Begin
Result :=  FT_SetFlowControl(FT_Handle,FT_Current_FlowControl,FT_XON_Value,FT_XOFF_Value);
If Result <> FT_OK then FT_Error_Report('FT_SetFlowControl',Result);
End;


Function Set_USB_Device_RTS : FT_Result;
Begin
Result :=  FT_SetRTS(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_SetRTS',Result);
End;


Function Clr_USB_Device_RTS : FT_Result;
Begin
Result :=  FT_ClrRTS(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_ClrRTS',Result);
End;


Function Set_USB_Device_DTR : FT_Result;
Begin
Result :=  FT_SetDTR(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_SetDTR',Result);
End;


Function Clr_USB_Device_DTR : FT_Result;
Begin
Result :=  FT_ClrDTR(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_ClrDTR',Result);
End;


Function Get_USB_Device_ModemStatus : FT_Result;
Begin
Result :=  FT_GetModemStatus(FT_Handle,@FT_Modem_Status);
If Result <> FT_OK then FT_Error_Report('FT_GetModemStatus',Result);
End;


Function Set_USB_Device_Chars : FT_Result;
Var Events_On,Errors_On : Byte;
Begin
If FT_Event_On then Events_On := 1 else Events_On := 0;
If FT_Error_On then Errors_On := 1 else Errors_On := 0;
Result :=  FT_SetChars(FT_Handle,FT_EVENT_Value,Events_On,FT_ERROR_Value,Errors_On);
If Result <> FT_OK then FT_Error_Report('FT_SetChars',Result);
End;


Function Purge_USB_Device_Out : FT_Result;
Begin
Result :=  FT_Purge(FT_Handle,FT_PURGE_RX);
If Result <> FT_OK then FT_Error_Report('FT_Purge RX',Result);
End;

Function Purge_USB_Device_In : FT_Result;
Begin
Result :=  FT_Purge(FT_Handle,FT_PURGE_TX);
If Result <> FT_OK then FT_Error_Report('FT_Purge TX',Result);
End;


Function Set_USB_Device_TimeOuts(ReadTimeOut,WriteTimeOut:DWord) : FT_Result;
Begin
Result :=  FT_SetTimeouts(FT_Handle,ReadTimeout,WriteTimeout);
If Result <> FT_OK then FT_Error_Report('FT_SetTimeouts',Result);
End;


Function Get_USB_Device_QueueStatus : FT_Result;
Begin
Result :=  FT_GetQueueStatus(FT_Handle,@FT_Q_Bytes);
If Result <> FT_OK then FT_Error_Report('FT_GetQueueStatus',Result);
End;


Function Set_USB_Device_Break_On : FT_Result;
Begin
Result :=  FT_SetBreakOn(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_SetBreakOn',Result);
End;


Function Set_USB_Device_Break_Off : FT_Result;
Begin
Result :=  FT_SetBreakOff(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_SetBreakOff',Result);
End;


Function Get_USB_Device_Status : FT_Result;
Begin
Result :=  FT_GetStatus(FT_Handle, @FT_Q_Bytes, @FT_TxQ_Bytes, @FT_Event_Status);
If Result <> FT_OK then FT_Error_Report('FT_GetStatus',Result);
End;


Function Set_USB_Device_Event_Notification(EventMask:DWord) : FT_Result;
Begin
Result := FT_SetEventNotification(FT_Handle,EventMask,FT_Event_Handle);
If Result <> FT_OK then FT_Error_Report('FT_SetEventNotification ',Result);
End;


Function USB_FT_GetDeviceInfo(DevType,ID:DWord; SerialNumber,Description:array of char) : FT_Result;
begin
Result := FT_GetDeviceInfo(FT_Handle,@DevType,@ID,@SerialNumber,@Description,Nil);
If Result <> FT_OK then FT_Error_Report('FT_GetDeviceInfo ',Result);
end;


Function Set_USB_Device_Reset_Pipe_Retry_Count(RetryCount:DWord) : FT_Result;
Begin
Result :=  FT_SetResetPiperetryCount(FT_Handle, RetryCount);
If Result <> FT_OK then FT_Error_Report('FT_SetResetPipeRetryCount',Result);
End;


Function Stop_USB_Device_InTask : FT_Result;
Begin
Result :=  FT_StopInTask(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_StopInTask',Result);
End;


Function Restart_USB_Device_InTask : FT_Result;
Begin
Result :=  FT_RestartInTask(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_RestartInTask',Result);
End;


Function Reset_USB_Port : FT_Result;
Begin
Result :=  FT_ResetPort(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_ResetPort',Result);
End;


Function Cycle_USB_Port : FT_Result;
Begin
Result :=  FT_CyclePort(FT_Handle);
If Result <> FT_OK then FT_Error_Report('FT_CyclePort',Result);
End;


Function Create_USB_Device_List : FT_Result;
Begin
Result :=  FT_CreateDeviceInfoList(@FT_Device_Count);
If Result <> FT_OK then FT_Error_Report('FT_CreateDeviceInfoList',Result);
End;


Function Get_USB_Device_List : FT_Result;
Begin
SetLength(FT_DeviceInfoList,FT_Device_Count);
Result :=  FT_GetDeviceInfoList(FT_DeviceInfoList, @FT_Device_Count);
If Result <> FT_OK then FT_Error_Report('FT_GetDeviceInfoList',Result);
End;

Function Get_USB_Driver_Version(DrVersion : TDWordPtr) : FT_Result;
Begin
   Result :=  FT_GetDriverVersion(FT_Handle, DrVersion);
   If Result <> FT_OK then FT_Error_Report('FT_GetDriverVersion',Result);
End;

Function Get_USB_Library_Version(LbVersion : TDWordPtr) : FT_Result;
Begin
   Result :=  FT_GetLibraryVersion(LbVersion);
   If Result <> FT_OK then FT_Error_Report('FT_GetLibraryVersion',Result);
End;


Function Get_USB_Device_List_Detail(Index:DWord) : FT_Result;
Begin
// Initialise structure
USB_Device_Info_Node.Flags := 0;
USB_Device_Info_Node.DeviceType := 0;
USB_Device_Info_Node.ID := 0;
USB_Device_Info_Node.LocID := 0;
USB_Device_Info_Node.SerialNumber := '';
USB_Device_Info_Node.Description := '';
USB_Device_Info_Node.DeviceHandle := 0;
Result := FT_GetDeviceInfoDetail(Index,@USB_Device_Info_Node.Flags,@USB_Device_Info_Node.DeviceType,
    @USB_Device_Info_Node.ID,@USB_Device_Info_Node.LocID,@USB_Device_Info_Node.SerialNumber,
    @USB_Device_Info_Node.Description,@USB_Device_Info_Node.DeviceHandle);
If Result <> FT_OK then FT_Error_Report('FT_GetDeviceInfoListDetail',Result);
End;


function USB_FT_EE_Read : FT_Result;
// Read BM/AM device EEPROM
begin
EEDataBuffer.Signature1 := 0;
EEDataBuffer.Signature2 := $FFFFFFFF;
EEDataBuffer.Version := 0;  // 0 for AM/BM, 1 for C, 2 for R
EEDataBuffer.VendorId :=0;
EEDataBuffer.ProductId := 0;
EEDataBuffer.Manufacturer := @Manufacturer;
EEDataBuffer.ManufacturerId := @ManufacturerId;
EEDataBuffer.Description := @Description;
EEDataBuffer.SerialNumber := @SerialNumber;
EEDataBuffer.MaxPower := 0;
EEDataBuffer.PnP := 0;
EEDataBuffer.SelfPowered := 0;
EEDataBuffer.RemoteWakeup := 0;
EEDataBuffer.Rev4 := 0;
EEDataBuffer.IsoIn := 0;
EEDataBuffer.IsoOut := 0;
EEDataBuffer.PullDownEnable := 0;
EEDataBuffer.SerNumEnable := 0;
EEDataBuffer.USBVersionEnable := 0;
EEDataBuffer.USBVersion := 0;
// FT2232C Extensions
EEDataBuffer.Rev5 := 0;
EEDataBuffer.IsoInA := 0;
EEDataBuffer.IsoInB := 0;
EEDataBuffer.IsoOutA := 0;
EEDataBuffer.IsoOutB := 0;
EEDataBuffer.PullDownEnable5 := 0;
EEDataBuffer.SerNumEnable5 := 0;
EEDataBuffer.USBVersionEnable5 := 0;
EEDataBuffer.USBVersion5 := 0;
EEDataBuffer.AIsHighCurrent := 0;
EEDataBuffer.BIsHighCurrent := 0;
EEDataBuffer.IFAIsFifo := 0;
EEDataBuffer.IFAIsFifoTar := 0;
EEDataBuffer.IFAIsFastSer := 0;
EEDataBuffer.AIsVCP := 0;
EEDataBuffer.IFBIsFifo := 0;
EEDataBuffer.IFBIsFifoTar := 0;
EEDataBuffer.IFBIsFastSer := 0;
EEDataBuffer.BIsVCP := 0;
// FT232R extensions
EEDataBuffer.UseExtOsc := 0;
EEDataBuffer.HighDriveIOs := 0;
EEDataBuffer.EndpointSize := 0;
EEDataBuffer.PullDownEnableR := 0;
EEDataBuffer.SerNumEnableR := 0;
EEDataBuffer.InvertTXD := 0;
EEDataBuffer.InvertRXD := 0;
EEDataBuffer.InvertRTS := 0;
EEDataBuffer.InvertCTS := 0;
EEDataBuffer.InvertDTR := 0;
EEDataBuffer.InvertDSR := 0;
EEDataBuffer.InvertDCD := 0;
EEDataBuffer.InvertRI := 0;
EEDataBuffer.Cbus0 := 0;
EEDataBuffer.Cbus1 := 0;
EEDataBuffer.Cbus2 := 0;
EEDataBuffer.Cbus3 := 0;
EEDataBuffer.Cbus4 := 0;
EEDataBuffer.RIsVCP := 0;
Result :=  FT_EE_Read(FT_Handle,@EEDataBuffer);
If Result <> FT_OK then FT_Error_Report('FT_EE_Read ',Result);
end;


function USB_FT_C_EE_Read : FT_Result;
// Read FT2232C device EEPROM
begin
EEDataBuffer.Signature1 := 0;
EEDataBuffer.Signature2 := $FFFFFFFF;
EEDataBuffer.Version := 1;  // 0 for AM/BM, 1 for C, 2 for R
EEDataBuffer.VendorId :=0;
EEDataBuffer.ProductId := 0;
EEDataBuffer.Manufacturer := @Manufacturer;
EEDataBuffer.ManufacturerId := @ManufacturerId;
EEDataBuffer.Description := @Description;
EEDataBuffer.SerialNumber := @SerialNumber;
EEDataBuffer.MaxPower := 0;
EEDataBuffer.PnP := 0;
EEDataBuffer.SelfPowered := 0;
EEDataBuffer.RemoteWakeup := 0;
EEDataBuffer.Rev4 := 0;
EEDataBuffer.IsoIn := 0;
EEDataBuffer.IsoOut := 0;
EEDataBuffer.PullDownEnable := 0;
EEDataBuffer.SerNumEnable := 0;
EEDataBuffer.USBVersionEnable := 0;
EEDataBuffer.USBVersion := 0;
// FT2232C Extensions
EEDataBuffer.Rev5 := 0;
EEDataBuffer.IsoInA := 0;
EEDataBuffer.IsoInB := 0;
EEDataBuffer.IsoOutA := 0;
EEDataBuffer.IsoOutB := 0;
EEDataBuffer.PullDownEnable5 := 0;
EEDataBuffer.SerNumEnable5 := 0;
EEDataBuffer.USBVersionEnable5 := 0;
EEDataBuffer.USBVersion5 := 0;
EEDataBuffer.AIsHighCurrent := 0;
EEDataBuffer.BIsHighCurrent := 0;
EEDataBuffer.IFAIsFifo := 0;
EEDataBuffer.IFAIsFifoTar := 0;
EEDataBuffer.IFAIsFastSer := 0;
EEDataBuffer.AIsVCP := 0;
EEDataBuffer.IFBIsFifo := 0;
EEDataBuffer.IFBIsFifoTar := 0;
EEDataBuffer.IFBIsFastSer := 0;
EEDataBuffer.BIsVCP := 0;
// FT232R extensions
EEDataBuffer.UseExtOsc := 0;
EEDataBuffer.HighDriveIOs := 0;
EEDataBuffer.EndpointSize := 0;
EEDataBuffer.PullDownEnableR := 0;
EEDataBuffer.SerNumEnableR := 0;
EEDataBuffer.InvertTXD := 0;
EEDataBuffer.InvertRXD := 0;
EEDataBuffer.InvertRTS := 0;
EEDataBuffer.InvertCTS := 0;
EEDataBuffer.InvertDTR := 0;
EEDataBuffer.InvertDSR := 0;
EEDataBuffer.InvertDCD := 0;
EEDataBuffer.InvertRI := 0;
EEDataBuffer.Cbus0 := 0;
EEDataBuffer.Cbus1 := 0;
EEDataBuffer.Cbus2 := 0;
EEDataBuffer.Cbus3 := 0;
EEDataBuffer.Cbus4 := 0;
EEDataBuffer.RIsVCP := 0;
Result :=  FT_EE_Read(FT_Handle,@EEDataBuffer);
If Result <> FT_OK then FT_Error_Report('FT_EE_Read ',Result);
end;


function USB_FT_R_EE_Read : FT_Result;
// Read FT232R device EEPROM
begin
EEDataBuffer.Signature1 := 0;
EEDataBuffer.Signature2 := $FFFFFFFF;
EEDataBuffer.Version := 2;  // 0 for AM/BM, 1 for C, 2 for R
EEDataBuffer.VendorId :=0;
EEDataBuffer.ProductId := 0;
EEDataBuffer.Manufacturer := @Manufacturer;
EEDataBuffer.ManufacturerId := @ManufacturerId;
EEDataBuffer.Description := @Description;
EEDataBuffer.SerialNumber := @SerialNumber;
EEDataBuffer.MaxPower := 0;
EEDataBuffer.PnP := 0;
EEDataBuffer.SelfPowered := 0;
EEDataBuffer.RemoteWakeup := 0;
EEDataBuffer.Rev4 := 0;
EEDataBuffer.IsoIn := 0;
EEDataBuffer.IsoOut := 0;
EEDataBuffer.PullDownEnable := 0;
EEDataBuffer.SerNumEnable := 0;
EEDataBuffer.USBVersionEnable := 0;
EEDataBuffer.USBVersion := 0;
// FT2232C Extensions
EEDataBuffer.Rev5 := 0;
EEDataBuffer.IsoInA := 0;
EEDataBuffer.IsoInB := 0;
EEDataBuffer.IsoOutA := 0;
EEDataBuffer.IsoOutB := 0;
EEDataBuffer.PullDownEnable5 := 0;
EEDataBuffer.SerNumEnable5 := 0;
EEDataBuffer.USBVersionEnable5 := 0;
EEDataBuffer.USBVersion5 := 0;
EEDataBuffer.AIsHighCurrent := 0;
EEDataBuffer.BIsHighCurrent := 0;
EEDataBuffer.IFAIsFifo := 0;
EEDataBuffer.IFAIsFifoTar := 0;
EEDataBuffer.IFAIsFastSer := 0;
EEDataBuffer.AIsVCP := 0;
EEDataBuffer.IFBIsFifo := 0;
EEDataBuffer.IFBIsFifoTar := 0;
EEDataBuffer.IFBIsFastSer := 0;
EEDataBuffer.BIsVCP := 0;
// FT232R extensions
EEDataBuffer.UseExtOsc := 0;
EEDataBuffer.HighDriveIOs := 0;
EEDataBuffer.EndpointSize := 0;
EEDataBuffer.PullDownEnableR := 0;
EEDataBuffer.SerNumEnableR := 0;
EEDataBuffer.InvertTXD := 0;
EEDataBuffer.InvertRXD := 0;
EEDataBuffer.InvertRTS := 0;
EEDataBuffer.InvertCTS := 0;
EEDataBuffer.InvertDTR := 0;
EEDataBuffer.InvertDSR := 0;
EEDataBuffer.InvertDCD := 0;
EEDataBuffer.InvertRI := 0;
EEDataBuffer.Cbus0 := 0;
EEDataBuffer.Cbus1 := 0;
EEDataBuffer.Cbus2 := 0;
EEDataBuffer.Cbus3 := 0;
EEDataBuffer.Cbus4 := 0;
EEDataBuffer.RIsVCP := 0;
Result :=  FT_EE_Read(FT_Handle,@EEDataBuffer);
If Result <> FT_OK then FT_Error_Report('FT_EE_Read ',Result);
end;


function USB_FT_EE_Program : FT_Result;
begin
Result := FT_EE_Program(FT_Handle, @EEDataBuffer);
If Result <> FT_OK then FT_Error_Report('FT_EE_Read ',Result);
end;


function USB_FT_WriteEE(WordAddr:Dword; WordData:Word) : FT_Result;
begin
Result := FT_WriteEE(FT_Handle,WordAddr,WordData);
end;


function USB_FT_ReadEE(WordAddr:Dword) : FT_Result;
begin
Result := FT_ReadEE(FT_Handle,WordAddr,@WordRead);
end;


function USB_FT_EraseEE : FT_Result;
begin
Result := FT_EraseEE(FT_Handle);
end;


function USB_FT_EE_UARead : FT_Result;
begin
Result :=  FT_EE_UARead(FT_Handle,@UserData,64,@FT_UA_Size);
If Result <> FT_OK then FT_Error_Report('FT_EE_UARead ',Result);
end;


function USB_FT_EE_UAWrite : FT_Result;
begin
Result :=  FT_EE_UAWrite(FT_Handle,@UserData,FT_UA_Size);
If Result <> FT_OK then FT_Error_Report('FT_EE_UAWrite ',Result);
end;


function USB_FT_EE_UASize : FT_Result;
begin
Result :=  FT_EE_UASize(FT_Handle,@FT_UA_Size);
If Result <> FT_OK then FT_Error_Report('FT_EE_UASize ',Result);
end;


Function Get_USB_Device_LatencyTimer : FT_Result;
Begin
Result := FT_GetLatencyTimer(FT_Handle,@FT_LatencyRd);
If Result <> FT_OK then FT_Error_Report('FT_GetLatencyTimer ',Result);
End;


Function Set_USB_Device_LatencyTimer(Latency:Byte) : FT_Result;
Begin
Result :=  FT_SetLatencyTimer(FT_Handle, Latency);
If Result <> FT_OK then FT_Error_Report('FT_SetLatencyTimer ',Result);
End;


Function Get_USB_Device_BitMode(var BitMode:Byte) : FT_Result;
Begin
Result := FT_GetBitMode(FT_Handle,@BitMode);
If Result <> FT_OK then FT_Error_Report('FT_GetBitMode ',Result);
End;


Function Set_USB_Device_BitMode(Mask,Enable:Byte) : FT_Result ;
Begin
Result := FT_SetBitMode(FT_Handle,Mask,Enable);
If Result <> FT_OK then FT_Error_Report('FT_SetBitMode ',Result);
End;


Function Set_USB_Parameters(InSize,OutSize:Dword) : FT_Result ;
Begin
Result :=  FT_SetUSBParameters(FT_Handle,InSize,OutSize);
If Result <> FT_OK then FT_Error_Report('FT_SetUSBParameters ',Result);
End;


End.
