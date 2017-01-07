#include "microwire.h"


void mwStart(void)
{
	SPI_Disable();
	DDRB  |= ((1 << 1) | (1 << 2));
	PORTB |= ((1 << 0) | (1 << 3));
		
	// set CS to 0
    SPI_Set_CS(0);
	// set CLK to 0
    ISP_OUT &= ~(1 << ISP_SCK);
	_delay_us(MW_DELAY);

	// set CS to 1
    SPI_Set_CS(1);
	//send start bit
                ISP_OUT |= (1 << ISP_MOSI);
	_delay_us(MW_DELAY);
                ISP_OUT |= (1 << ISP_SCK);
	_delay_us(MW_DELAY);
                ISP_OUT &= ~(1 << ISP_SCK);
	_delay_us(MW_DELAY);	
}

void mwSendData(unsigned int data,unsigned char n)
{
	while(n !=0)
	{
		if ((data >> (n-1)) & 1)
		{
			ISP_OUT |= (1 << ISP_MOSI);
		}
		else
		{
			ISP_OUT &= ~(1 << ISP_MOSI);
		}
		
		ISP_OUT |= (1 << ISP_SCK);
		_delay_us(MW_DELAY);
        ISP_OUT &= ~(1 << ISP_SCK);
		_delay_us(MW_DELAY);
		n--;
	}
}


unsigned char mwReadByte(void)
{
	unsigned char dd,i;

    dd =0 ;
	for(i=0;i<8;i++)
	{
		dd = dd<<1;
		ISP_OUT |= (1 << ISP_SCK);
		_delay_us(MW_DELAY);
		ISP_OUT &= ~(1 << ISP_SCK);
		_delay_us(MW_DELAY);

		if ((ISP_IN & (1 << ISP_MISO)) != 0)
		{
				dd++;
		}

	}
	return dd;
}

void mwEnd(void)
{
	// set CS to 0
    SPI_Set_CS(0);
	// set CLK to 0
                ISP_OUT &= ~(1 << ISP_SCK);
	_delay_us(MW_DELAY);
}

unsigned char mwBusy(void)
{
	SPI_Set_CS(1);
	_delay_us(10);
	_delay_us(MW_DELAY);
	if ((ISP_IN & (1 << ISP_MISO)) != 0)
	{
		SPI_Set_CS(0);
		return(0);
	}
	else
	{
		SPI_Set_CS(0);
		return(1); //Линия занята
	};
}

void mw_read(void)
{
	uint16_t BytesToRead;
	uint16_t Address;
	uint8_t addr_bitlen;
	
	BytesToRead = Endpoint_Read_16_LE();
	Address = Endpoint_Read_16_LE();
	addr_bitlen = Endpoint_Read_8();
	
	Endpoint_ClearOUT();
	Endpoint_SelectEndpoint(AVRISP_DATA_IN_EPADDR);
	Endpoint_SetEndpointDirection(ENDPOINT_DIR_IN); 
	
	mwStart();
	mwSendData(Address, addr_bitlen);
	
	if (BytesToRead == 0) //В любом случае отсылаем хоть что-то, иначе нихера не пашет :(
	{
		Endpoint_Write_8(0);
	}
		
	/* Read each byte from the device and write them to the packet for the host */
	while (BytesToRead > 0)
	{

		/* Read the next byte */		
		Endpoint_Write_8(mwReadByte());

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
	
	mwEnd(); 
}
	
void mw_write(void)
{
	uint16_t BytesToWrite;
	uint8_t  ChunkToWrite;
	static uint8_t  ProgData[8];
	uint16_t Address;
	uint8_t addr_bitlen;
	
	BytesToWrite = Endpoint_Read_16_LE();
	Address = Endpoint_Read_16_LE();
	addr_bitlen = Endpoint_Read_8();
	
	mwStart();
	mwSendData(Address, addr_bitlen);
	
	while (BytesToWrite > 0)
	{	
		if (BytesToWrite < sizeof(ProgData)) ChunkToWrite = BytesToWrite; 
			else ChunkToWrite = sizeof(ProgData);
			
		Endpoint_Read_Stream_LE(&ProgData, ChunkToWrite, NULL);
		
		for (uint8_t CurrentByte = 0; CurrentByte < ChunkToWrite; CurrentByte++)
		{
			mwSendData(ProgData[CurrentByte], 8);
			BytesToWrite--;
		}
	}
	
	Endpoint_ClearOUT();
	
	mwEnd(); 
}

void mw_busy(void)
{
	Endpoint_ClearOUT();
	Endpoint_SelectEndpoint(AVRISP_DATA_IN_EPADDR);
	Endpoint_SetEndpointDirection(ENDPOINT_DIR_IN);
	
	Endpoint_Write_8(mwBusy());
	
	Endpoint_WaitUntilReady();
	Endpoint_ClearIN();
}
