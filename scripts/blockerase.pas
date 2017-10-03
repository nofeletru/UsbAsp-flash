{$erase} //секция будет выполняться при нажатии кнопки "стереть"
begin
  if not SPISetSpeed(_SPI_SPEED_MAX) then LogPrint('Error setting SPI speed');
  SPIEnterProgMode();

  BlockSize := 65536; //Размер блока
  sreg := 0;
  ProgressBar(0, (_IC_SIZE / BlockSize)-1, 0);

  for i:=0 to (_IC_SIZE / BlockSize)-1 do
  begin
    SPIWrite(1, 1, $06); //wren
    SPIWrite(1, 4, $D8, i,0,0); //BE

    //Busy?
    repeat
      SPIWrite(0, 1, $05);
      SPIRead(1, 1, sreg);
    until((sreg and 1) <> 1);
    ProgressBar(1);
  end;

  ProgressBar(0, 0, 0);
  SPIExitProgMode();
end
