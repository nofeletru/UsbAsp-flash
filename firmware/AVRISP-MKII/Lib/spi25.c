
#include "spi25.h"

void SPI_Set_CS(uint8_t line_level)
{
	if(line_level)
	{
		AUX_LINE_DDR |= AUX_LINE_MASK;
		AUX_LINE_PORT |=  AUX_LINE_MASK;
	}
	else
	{
		AUX_LINE_DDR |= AUX_LINE_MASK;
		AUX_LINE_PORT &= ~AUX_LINE_MASK;
	}
}

void give_firmware_ver(void)
{
	Endpoint_ClearOUT();
	Endpoint_SelectEndpoint(AVRISP_DATA_IN_EPADDR);
	Endpoint_SetEndpointDirection(ENDPOINT_DIR_IN);

	Endpoint_Write_8(CMD_FIRMWARE_VER);
	Endpoint_Write_8(FIRMWARE_VER);
	Endpoint_ClearIN();	
}

void SPI_Enter25Mode(void)
{
	Endpoint_ClearOUT();
	Endpoint_SelectEndpoint(AVRISP_DATA_IN_EPADDR);
	Endpoint_SetEndpointDirection(ENDPOINT_DIR_IN);
	
	ISPTarget_EnableTargetISP();
	SPI_Set_CS(1);

	Endpoint_Write_8(CMD_ENTER_PROGMODE_SPI25);
	Endpoint_Write_8(STATUS_CMD_OK);
	Endpoint_ClearIN();
}

void SPI_Leave25Mode(void)
{	
	Endpoint_ClearOUT();
	Endpoint_SelectEndpoint(AVRISP_DATA_IN_EPADDR);
	Endpoint_SetEndpointDirection(ENDPOINT_DIR_IN);

	ISPTarget_DisableTargetISP();	
    ISPTarget_ChangeTargetResetLine(false); //floating

	Endpoint_Write_8(CMD_LEAVE_PROGMODE_SPI25);
	Endpoint_Write_8(STATUS_CMD_OK);
	Endpoint_ClearIN();
}

void SPI_25Read(void)
{	
	uint16_t BytesToRead;
	uint8_t cs_hi;
	
	BytesToRead = Endpoint_Read_16_LE();
	cs_hi = Endpoint_Read_8();
	
	Endpoint_ClearOUT();
	Endpoint_SelectEndpoint(AVRISP_DATA_IN_EPADDR);
	Endpoint_SetEndpointDirection(ENDPOINT_DIR_IN);

	SPI_Set_CS(0); 

	/* Read each byte from the device and write them to the packet for the host */
	while (BytesToRead > 0)
	{

		/* Read the next byte */		
		Endpoint_Write_8(SPI_TransferByte(0));

		/* Check if the endpoint bank is currently full, if so send the packet */
		if (!(Endpoint_IsReadWriteAllowed()))
		{
			Endpoint_ClearIN();
			Endpoint_WaitUntilReady();
		}
		
		BytesToRead--;
	}
	
	if (Endpoint_BytesInEndpoint() > 0) 
	{
		Endpoint_WaitUntilReady();
		Endpoint_ClearIN();
		Endpoint_WaitUntilReady();
	} 
	
	if (cs_hi) SPI_Set_CS(1); 
}

void SPI_25Write(void)
{	
	uint16_t BytesToWrite;
	uint8_t  ChunkToWrite;
	uint8_t  ProgData[128];
	uint8_t  cs_hi;
	
	BytesToWrite = Endpoint_Read_16_LE();
	cs_hi = Endpoint_Read_8();
	
	SPI_Set_CS(0);
	
	while (BytesToWrite > 0)
	{	
		if (BytesToWrite < sizeof(ProgData)) ChunkToWrite = BytesToWrite; 
			else ChunkToWrite = sizeof(ProgData);
			
		Endpoint_Read_Stream_LE(&ProgData, ChunkToWrite, NULL);
		
		for (uint8_t CurrentByte = 0; CurrentByte < ChunkToWrite; CurrentByte++)
		{
			SPI_TransferByte(ProgData[CurrentByte]);
			BytesToWrite--;
		}
	}
	
	Endpoint_ClearOUT();

	if (cs_hi) SPI_Set_CS(1);
}
