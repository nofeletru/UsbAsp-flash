{$read}
//reading 24c08
begin
  ChipSize := 1024;
  MemAddr := 0;
  ReadBuff := CreateByteArray(ChipSize);
  DevAddr := $A0;

  I2CEnterProgMode;

  I2CReadWrite(DevAddr, 1, ChipSize, MemAddr, ReadBuff);
  ReadToEditor(ChipSize, 0, ReadBuff);

  I2CExitProgMode;
end

{$write}
function I2CIsBusy(DevAdr): boolean;
begin
  I2CStart;
  Result := not I2CWriteByte(DevAdr);
  I2CStop;
end;
//writing 24c08
begin
  ChipSize := 1024;
  MemAddr := 0;
  WriteByte := 0;
  DevAddr := $A0;
  ProgressBar(0, _IC_SIZE-1, 0);

  I2CEnterProgMode;

  for i:=0 to ChipSize-1 do
  begin
    WriteFromEditor(1, i, WriteByte);
    I2CReadWrite(DevAddr, 2, 0, MemAddr, WriteByte);
    while I2CIsBusy(DevAddr) do;;
    MemAddr := MemAddr + 1;
    if MemAddr = 256 then DevAddr := $A2;
    if MemAddr = 512 then DevAddr := $A4;
    if MemAddr = 768 then DevAddr := $A6;
    ProgressBar(1);
  end;

  I2CExitProgMode;
  ProgressBar(0, 0, 0);
end
