{$readSR} // Read Security Register
begin
  if not SPIEnterProgMode(_SPI_SPEED_MAX) then LogPrint('Error setting SPI speed');
  SRvalue :=0; //variable for Security Register

  SPIWrite(0, 1, $2B); //send 0x2b command for read SR
  SPIRead(1, 1, SRvalue); //read 1byte of SR into variable
  //now checking bit 0 and 1
  LogPrint('SR factory lock: '+IntToStr(SRvalue and 1));
  LogPrint('SR customer lock: '+IntToStr((SRvalue shr 1) and 1));

  SPIExitProgMode();
end

{$writeOTP}
begin
  if not SPIEnterProgMode(_SPI_SPEED_MAX) then LogPrint('Error setting SPI speed');

  PageSize := 256;
  OTPsize := 4096;
  ProgressBar(0, (OTPsize / PageSize)-1, 0);

  SPIWrite(1, 1, $B1); //enter secured OTP

  for i:=0 to (OTPsize / PageSize)-1 do
  begin
    SPIWrite(1, 1, $06); //write enable
    SPIWrite(0, 4, $02, 0,i,0); // write page command and address
    SPIWriteFromEditor(1, PageSize, i*PageSize); //write data

    //Busy?
    sreg := 0;
    repeat
      SPIWrite(0, 1, $05);
      SPIRead(1, 1, sreg);
    until((sreg and 1) <> 1);

    ProgressBar(1);
  end;

  ProgressBar(0, 0, 0);
  SPIWrite(1, 1, $C1); //exit secured OTP
  SPIExitProgMode();
end

{$readOTP}
begin
  if not SPIEnterProgMode(_SPI_SPEED_MAX) then LogPrint('Error setting SPI speed');

  PageSize := 256;
  OTPsize := 4096;
  ProgressBar(0, (OTPsize / PageSize)-1, 0);

  SPIWrite(1, 1, $B1); //enter secured OTP

  for i:=0 to (OTPsize / PageSize)-1 do
  begin
    SPIWrite(0, 4, $03, 0,i,0);
    SPIReadToEditor(1, PageSize);
    ProgressBar(1);
  end;

  ProgressBar(0, 0, 0);
  SPIWrite(1, 1, $C1); //exit secured OTP
  SPIExitProgMode();
end
