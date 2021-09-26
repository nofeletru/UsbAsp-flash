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
