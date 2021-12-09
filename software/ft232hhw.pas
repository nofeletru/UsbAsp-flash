unit ft232hhw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, basehw, msgstr, D2XXUnit, utilfunc;

type

{ TFT232HHardware }

TFT232HHardware = class(TBaseHardware)
private
  FDevOpened: boolean;
  FStrError: string;
  procedure SetI2CPins(scl, sda: byte);
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
  procedure SetSPIcs(cs: byte);

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
MSB_RISING_EDGE_CLOCK_BYTE_IN = $20;
MSB_RISING_EDGE_CLOCK_BYTE_OUT = $10;
MSB_RISING_EDGE_CLOCK_BIT_IN = $22;
MSB_RISING_EDGE_CLOCK_BIT_OUT = $12;

procedure TFT232HHardware.SetI2CPins(scl, sda: byte);
var pins: byte;
begin
  if scl > 0 then scl := 1;
  if sda > 0 then sda := 2;

  pins := 0;
  pins := pins or scl or sda;

  FT_Out_Buffer[0] := $80; //MPSSE Command to set low bits of port
  FT_Out_Buffer[1] := pins;
  FT_Out_Buffer[2] := %00000011; //Pin directions
  Write_USB_Device_Buffer(3);

end;

procedure TFT232HHardware.SetSPIcs(cs: byte);
begin
  FT_Out_Buffer[0] := $80; //MPSSE Command to set low bits of port
  if cs > 0 then
    FT_Out_Buffer[1] := %00001110 else
      FT_Out_Buffer[1] := %00000110;
  FT_Out_Buffer[2] := %00001011; //Pin directions
  Write_USB_Device_Buffer(3);
end;

constructor TFT232HHardware.Create;
begin
  FHardwareName := 'FT232H';
  FHardwareID := CHW_FT232H;
end;

destructor TFT232HHardware.Destroy;
begin
  DevClose;
end;

function TFT232HHardware.GetLastError: string;
begin
  result := FStrError;
end;

function TFT232HHardware.DevOpen: boolean;
var
  err: integer;
begin
  if FDevOpened then DevClose;

  err := Open_USB_Device();

  if err > 0 then
  begin
    FStrError :=  STR_CONNECTION_ERROR+ FHardwareName +'('+IntToStr(err)+')';
    FDevOpened := false;
    Exit(false);
  end;

  FDevOpened := true;
  Result := true;
end;

procedure TFT232HHardware.DevClose;
begin
  if FDevOpened then
  begin
    Close_USB_Device();
    FDevOpened := false;
  end;
end;


//SPI___________________________________________________________________________
 //SPI speed 0 = 6Mhz; >1 = 30Mhz
function TFT232HHardware.SPIInit(speed: integer): boolean;
var
  err: integer;
begin
  if not FDevOpened then Exit(false);
  Result := True;
  Purge_USB_Device_In();
  Purge_USB_Device_Out();

  err := Set_USB_Device_BitMode($FF, FT_BITMODE_MPSSE);
  if err <> FT_OK then Result := False;
  err := Set_USB_Device_LatencyTimer(1);
  if err <> FT_OK then Result := False;

  //Setting Clock Divisor  12Mhz/60Mhz
  if speed > 0 then
    FT_Out_Buffer[0] := $8A  //MPSSE command disable div5
  else
    FT_Out_Buffer[0] := $8B; //MPSSE command enable div5;

  FT_Out_Buffer[1] := $86; //MPSSE command Setting Clock Divisor
  FT_Out_Buffer[2] := $00;
  FT_Out_Buffer[3] := $00;

  FT_Out_Buffer[4] := $8D; //Disable 3 phase data clock
  //Setting Port Data and Direction
  //Bits assigned on FT232H AD bus
  //0 Out SPI CLK (SCK)
  //1 Out SPI DO (MOSI)
  //2 In SPI DI (MISO)
  //3 Out SPI CS0

  FT_Out_Buffer[5] := $80; //MPSSE Command to set low bits of port
  FT_Out_Buffer[6] := %00001110;
  FT_Out_Buffer[7] := %00001011; //Pin directions

  FT_Out_Buffer[8] := $9E; //Set I/O to only drive on a ‘0’ and tristate on a ‘1’
  FT_Out_Buffer[9] := $00;
  FT_Out_Buffer[10] := $00;
  err := Write_USB_Device_Buffer(11);
  if err <> 11 then Result := False;
end;

procedure TFT232HHardware.SPIDeinit;
begin
  if not FDevOpened then Exit;
  Set_USB_Device_BitMode($FF, FT_BITMODE_RESET);
end;

function TFT232HHardware.SPIRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
begin
  if not FDevOpened then Exit(-1);

  //SetSPIcs(0);
  FT_Out_Buffer[0] := $80; //MPSSE Command to set low bits of port
  FT_Out_Buffer[1] := %00000110;
  FT_Out_Buffer[2] := %00001011; //Pin directions

  FT_Out_Buffer[3] := $24; //MPSSE command to read bytes in from SPI
  FT_Out_Buffer[4] := BufferLen-1;
  FT_Out_Buffer[5] := (BufferLen-1) shr 8;
  FT_Out_Buffer[6] := $87; //Send answer back immediate command
  Write_USB_Device_Buffer(7);

  result := Read_USB_Device_Buffer(BufferLen);
  Move(FT_In_Buffer[0], buffer[0], BufferLen);

  if (CS = 1)then SetSPIcs(1); //release cs
end;

function TFT232HHardware.SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer;
begin
  if not FDevOpened then Exit(-1);

  //SetSPIcs(0);
  FT_Out_Buffer[0] := $80; //MPSSE Command to set low bits of port
  FT_Out_Buffer[1] := %00000110;
  FT_Out_Buffer[2] := %00001011; //Pin directions

  FT_Out_Buffer[3] := $11; //MPSSE command to write bytes from from SPI
  FT_Out_Buffer[4] := BufferLen-1;
  FT_Out_Buffer[5] := (BufferLen-1) shr 8;

  Move(buffer[0], FT_Out_Buffer[6], BufferLen);
  result := Write_USB_Device_Buffer(BufferLen+6)-6;

  if (CS = 1)then SetSPIcs(1); //release cs
end;

//i2c___________________________________________________________________________

procedure TFT232HHardware.I2CInit;
begin
  if not FDevOpened then Exit;
  Purge_USB_Device_In();
  Purge_USB_Device_Out();

  Set_USB_Device_BitMode($FF, FT_BITMODE_MPSSE);
  Set_USB_Device_LatencyTimer(1);

  //Setting Clock Divisor  200Khz
  FT_Out_Buffer[0] := $8A;  //MPSSE command disable div5
  FT_Out_Buffer[1] := $86; //MPSSE command Setting Clock Divisor
  FT_Out_Buffer[2] := $95;
  FT_Out_Buffer[3] := $00;
  FT_Out_Buffer[4] := $97; //Ensure turn off adaptive clocking
  FT_Out_Buffer[5] := $8C; //Enable 3 phase data clock, used by I2C to allow data on both clock edges

  FT_Out_Buffer[6] := $9E; //Set I/O to only drive on a ‘0’ and tristate on a ‘1’
  FT_Out_Buffer[7] := %00000111;
  FT_Out_Buffer[8] := $00;
  //Setting Port Data and Direction
  //Bits assigned on FT232H AD bus
  //0 Out SPI CLK (SCK)
  //1 Out SPI DO (MOSI)
  //2 In SPI DI (MISO)
  //3 Out SPI CS0

  FT_Out_Buffer[9] := $80; //MPSSE Command to set low bits of port
  FT_Out_Buffer[10] := %00000011;
  FT_Out_Buffer[11] := %00000011; //Pin directions
  Write_USB_Device_Buffer(12);

end;

procedure TFT232HHardware.I2CDeinit;
begin
  if not FDevOpened then Exit;
  Set_USB_Device_BitMode($FF, FT_BITMODE_RESET);
  FT_Out_Buffer[0] := $9E; //Set I/O to only drive on a ‘0’ and tristate on a ‘1’
  FT_Out_Buffer[2] := $00;
  FT_Out_Buffer[3] := $00;
  Write_USB_Device_Buffer(3);
end;

function TFT232HHardware.I2CReadWrite(DevAddr: byte;
                        WBufferLen: integer; WBuffer: array of byte;
                        RBufferLen: integer; var RBuffer: array of byte): integer;
var
  full_buff: array of byte;
  i, j: integer;
begin
  if not FDevOpened then Exit(-1);

  SetLength(full_buff, WBufferLen+1);
  move(WBuffer, full_buff[1], WBufferLen);
  full_buff[0] := DevAddr;
  ClearBit(full_buff[0], 0);

  I2CStart();
  j:= 0;
  for i:= 0 to WBufferLen do //+devaddr
  begin
    FT_Out_Buffer[0+j] := MSB_RISING_EDGE_CLOCK_BYTE_OUT; //Clock data byte out on –ve Clock Edge MSB first
    FT_Out_Buffer[1+j] := 0;
    FT_Out_Buffer[2+j] := 0; //Data length of 0x0000 means 1 byte data to clock out
    FT_Out_Buffer[3+j] := full_buff[i]; //Add data to be send

    FT_Out_Buffer[4+j] := $80; //Command to set directions of lower 8 pins and force value on bits set as output
    FT_Out_Buffer[5+j] := 0; //Set SCL low
    FT_Out_Buffer[6+j] := 1; //Set SK to 1, DO and other pins as input with bit ‘0’

    FT_Out_Buffer[7+j] := MSB_RISING_EDGE_CLOCK_BIT_IN; //Command to scan in ACK bit , +ve clock Edge MSB first
    FT_Out_Buffer[8+j] := 0; //Length of 0x0 means to scan in 1 bit
    FT_Out_Buffer[9+j] := $87; //Send answer back immediate command

    FT_Out_Buffer[10+j] := $80; //Command to set directions of lower 8 pins and force value on bits set as output
    FT_Out_Buffer[11+j] := $02; //Set SDA high, SCL low
    FT_Out_Buffer[12+j] := $03; //Set SK,DO pins as output with bit ‘1’, other pins as input with bit ‘0’

    Inc(j, 13);
  end;
  Write_USB_Device_Buffer((WBufferLen+1)*13);
  Read_USB_Device_Buffer(WBufferLen+1);

  if RBufferLen > 0 then
  begin
    I2CStart();
    DevAddr := SetBit(DevAddr, 0);
    I2CWriteByte(DevAddr);
    j:= 0;

    for i:= 0 to RBufferLen -1 do
    begin
        FT_Out_Buffer[0+j] := $80; //Command to set directions of lower 8 pins and force value on bits set as output
        FT_Out_Buffer[1+j] := %00000000; //Set SCL low
        FT_Out_Buffer[2+j] := %00000001; //Set SK, DO and other pins as input

        FT_Out_Buffer[3+j] := MSB_RISING_EDGE_CLOCK_BYTE_IN; //Command to clock data byte in
        FT_Out_Buffer[4+j] := 0;
        FT_Out_Buffer[5+j] := 0;

        //Set DO for output
        FT_Out_Buffer[6+j] := $80; //Command to set directions of lower 8 pins and force value on bits set as output
        FT_Out_Buffer[7+j] := %00000000;
        FT_Out_Buffer[8+j] := %00000011;

        FT_Out_Buffer[9+j] := $13; //acknowledge bit , +ve clock Edge MSB first
        FT_Out_Buffer[10+j] := 0; //Length of 0 means to send 1 bit
        if i = RBufferLen-1 then FT_Out_Buffer[11+j] := $FF else FT_Out_Buffer[11+j] := 0;

        FT_Out_Buffer[12+j] := $87; //Send answer back immediate command

        Inc(j, 13);
    end;

    Write_USB_Device_Buffer(RBufferLen*13);
    Read_USB_Device_Buffer(RBufferLen);
    Move(FT_In_Buffer[0], RBuffer[0], RBufferLen);

  end;
  I2CStop();
  result := WBufferLen + RBufferLen;
end;

procedure TFT232HHardware.I2CStart;
var i, num: integer;
begin
  if not FDevOpened then Exit;

  num := 0;

  for i:=0 to 3 do
  begin
    FT_Out_Buffer[num] := $80; //MPSSE Command to set low bits of port
    inc(num);
    FT_Out_Buffer[num] := %00000011;
    inc(num);
    FT_Out_Buffer[num] := %00000011; //Pin directions
    inc(num);
  end;

  for i:=0 to 3 do
  begin
    FT_Out_Buffer[num] := $80; //MPSSE Command to set low bits of port
    inc(num);
    FT_Out_Buffer[num] := %00000001;
    inc(num);
    FT_Out_Buffer[num] := %00000011; //Pin directions
    inc(num);
  end;

  FT_Out_Buffer[num] := $80; //MPSSE Command to set low bits of port
  inc(num);
  FT_Out_Buffer[num] := %00000000;
  inc(num);
  FT_Out_Buffer[num] := %00000011; //Pin directions
  inc(num);

  Write_USB_Device_Buffer(num);

end;

procedure TFT232HHardware.I2CStop;
var i, num: integer;
begin
  if not FDevOpened then Exit;

  num := 0;

  for i:=0 to 3 do
  begin
    FT_Out_Buffer[num] := $80; //MPSSE Command to set low bits of port
    inc(num);
    FT_Out_Buffer[num] := %00000000;
    inc(num);
    FT_Out_Buffer[num] := %00000011; //Pin directions
    inc(num);
  end;

  for i:=0 to 3 do
  begin
    FT_Out_Buffer[num] := $80; //MPSSE Command to set low bits of port
    inc(num);
    FT_Out_Buffer[num] := %00000001;
    inc(num);
    FT_Out_Buffer[num] := %00000011; //Pin directions
    inc(num);
  end;

  for i:=0 to 3 do
  begin
    FT_Out_Buffer[num] := $80; //MPSSE Command to set low bits of port
    inc(num);
    FT_Out_Buffer[num] := %00000011;
    inc(num);
    FT_Out_Buffer[num] := %00000011; //Pin directions
    inc(num);
  end;



  Write_USB_Device_Buffer(num);

end;

function TFT232HHardware.I2CReadByte(ack: boolean): byte;
begin
  if not FDevOpened then Exit;

  FT_Out_Buffer[0] := $80; //Command to set directions of lower 8 pins and force value on bits set as output
  FT_Out_Buffer[1] := %00000000; //Set SCL low
  FT_Out_Buffer[2] := %00000001; //Set SK, DO and other pins as input


  FT_Out_Buffer[3] := MSB_RISING_EDGE_CLOCK_BYTE_IN; //Command to clock data byte in
  FT_Out_Buffer[4] := 0;
  FT_Out_Buffer[5] := 0;

  //Set DO for output
  FT_Out_Buffer[6] := $80; //Command to set directions of lower 8 pins and force value on bits set as output
  FT_Out_Buffer[7] := %00000000;
  FT_Out_Buffer[8] := %00000011;

  FT_Out_Buffer[9] := $13; //acknowledge bit , +ve clock Edge MSB first
  FT_Out_Buffer[10] := 0; //Length of 0 means to send 1 bit
  if not ack then FT_Out_Buffer[11] := $FF else FT_Out_Buffer[11] := 0;

  FT_Out_Buffer[12] := $87; //Send answer back immediate command

 // FT_Out_Buffer[13] := $80; //Command to set directions of lower 8 pins and force value on bits set as output
 // FT_Out_Buffer[14] := 2; //Set SDA high, SCL low
 // FT_Out_Buffer[15] := 3; //Set SK,DO,GPIOL0 pins as output with bit ’’, other pins as input with bit ‘’

  Write_USB_Device_Buffer(13);
  Read_USB_Device_Buffer(1);
  result := FT_In_Buffer[0];
 end;

function TFT232HHardware.I2CWriteByte(data: byte): boolean;
begin
  if not FDevOpened then Exit;

  FT_Out_Buffer[0] := MSB_RISING_EDGE_CLOCK_BYTE_OUT; //Clock data byte out on +ve Clock Edge MSB first
  FT_Out_Buffer[1] := 0;
  FT_Out_Buffer[2] := 0; //Data length of 0x0000 means 1 byte data to clock out
  FT_Out_Buffer[3] := data; //Add data to be send

  FT_Out_Buffer[4] := $80; //Command to set directions of lower 8 pins and force value on bits set as output
  FT_Out_Buffer[5] := 0; //Set SCL low
  FT_Out_Buffer[6] := 1; //Set SK to 1, DO and other pins as input with bit ‘0’

  FT_Out_Buffer[7] := MSB_RISING_EDGE_CLOCK_BIT_IN; //Command to scan in ACK bit , +ve clock Edge MSB first
  FT_Out_Buffer[8] := 0; //Length of 0x0 means to scan in 1 bit
  FT_Out_Buffer[9] := $87; //Send answer back immediate command

  FT_Out_Buffer[10] := $80; //Command to set directions of lower 8 pins and force value on bits set as output
  FT_Out_Buffer[11] := $02; //Set SDA high, SCL low
  FT_Out_Buffer[12] := $03; //Set SK,DO pins as output with bit ‘1’, other pins as input with bit ‘0’

  Write_USB_Device_Buffer(13);
  Read_USB_Device_Buffer(1);

  Result := not IsBitSet(FT_In_Buffer[0], 0);

end;

//MICROWIRE_____________________________________________________________________

function TFT232HHardware.MWInit(speed: integer): boolean;
var
  err: integer;
begin
  if not FDevOpened then Exit(false);
  Result := True;
  Purge_USB_Device_In();
  Purge_USB_Device_Out();

  err := Set_USB_Device_BitMode($FF, FT_BITMODE_MPSSE);
  if err <> FT_OK then Result := False;
  err := Set_USB_Device_LatencyTimer(1);
  if err <> FT_OK then Result := False;

  //Setting Clock Divisor
  FT_Out_Buffer[0] := $8A;  //MPSSE command disable div5

  FT_Out_Buffer[1] := $86; //MPSSE command Setting Clock Divisor
  FT_Out_Buffer[2] := 29; //1Mhz
  FT_Out_Buffer[3] := $00;

  FT_Out_Buffer[4] := $8D; //Disable 3 phase data clock
  //Setting Port Data and Direction
  //Bits assigned on FT232H AD bus
  //0 Out SPI CLK (SCK)
  //1 Out SPI DO (MOSI)
  //2 In SPI DI (MISO)
  //3 Out SPI CS0

  FT_Out_Buffer[5] := $80; //MPSSE Command to set low bits of port
  FT_Out_Buffer[6] := %00001110;
  FT_Out_Buffer[7] := %00001011; //Pin directions

  FT_Out_Buffer[8] := $9E; //Set I/O to only drive on a ‘0’ and tristate on a ‘1’
  FT_Out_Buffer[9] := $00;
  FT_Out_Buffer[10] := $00;
  err := Write_USB_Device_Buffer(11);
  if err <> 11 then Result := False;
end;

procedure TFT232HHardware.MWDeInit;
begin
  if not FDevOpened then Exit;
  Set_USB_Device_BitMode($FF, FT_BITMODE_RESET);
end;

function TFT232HHardware.MWRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer;
begin
  if not FDevOpened then Exit(-1);
  SetSPIcs(1); //cs hi

  FT_Out_Buffer[0] := $24; //MPSSE command to read bytes in from SPI
  FT_Out_Buffer[1] := BufferLen-1;
  FT_Out_Buffer[2] := (BufferLen-1) shr 8;
  FT_Out_Buffer[3] := $87; //Send answer back immediate command
  Write_USB_Device_Buffer(4);

  result := Read_USB_Device_Buffer(BufferLen);
  Move(FT_In_Buffer[0], buffer[0], BufferLen);

  if Boolean(CS) then SetSPIcs(0);
end;

function TFT232HHardware.MWWrite(CS: byte; BitsWrite: byte; buffer: array of byte): integer;
var
  i, BuffIndex: integer;
begin
  if not FDevOpened then Exit(-1);

  if BitsWrite > 0 then
  begin
    SetSPIcs(1); //cs hi

    BuffIndex:= 0;
    if (BitsWrite div 8) > 0 then  //if we have a whole byte
    begin
      FT_Out_Buffer[BuffIndex] := $11; //write byte
      Inc(BuffIndex);
      FT_Out_Buffer[BuffIndex] := (BitsWrite div 8)-1;
      Inc(BuffIndex);
      FT_Out_Buffer[BuffIndex] := 0;
      Inc(BuffIndex);
      for i:= 0 to (BitsWrite div 8)-1 do
      begin
         FT_Out_Buffer[BuffIndex] := buffer[i];
         Inc(BuffIndex);
      end;

      Write_USB_Device_Buffer((BitsWrite div 8)+3);
    end;

    if (BitsWrite mod 8) > 0 then //bits
    begin
      FT_Out_Buffer[0] := $13; //write bit
      FT_Out_Buffer[1] := (BitsWrite mod 8)-1;
      FT_Out_Buffer[2] := buffer[i+1];
      FT_Out_Buffer[3] := $87; //Send answer back immediate command
      Write_USB_Device_Buffer(4);
    end;

  end;

    if Boolean(CS) then SetSPIcs(0);
end;

function TFT232HHardware.MWIsBusy: boolean;
begin
  SetSPIcs(1);

  FT_Out_Buffer[0] := $81; //read port lbyte
  FT_Out_Buffer[1] := $87; //Send answer back immediate command
  Write_USB_Device_Buffer(2);
  Read_USB_Device_Buffer(1);

  SetSPIcs(0);

  result := not IsBitSet(FT_In_Buffer[0], 2);

end;

end.

