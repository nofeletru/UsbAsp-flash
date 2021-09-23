
#include "i2c.h"

#define SET(reg, bit) (reg |= (1 << bit))
#define CLR(reg, bit) (reg &= ~(1 << bit))
#define GETBIT(byte, bit) ((byte >> bit) & 1)

#define I2C_SDA_LOW (SET(I2C_SDA_PORT_DIR, I2C_SDA_PIN))
#define I2C_SDA_HIGH (CLR(I2C_SDA_PORT_DIR, I2C_SDA_PIN))
#define I2C_SCL_LOW (SET(I2C_SCL_PORT_DIR, I2C_SCL_PIN))
#define I2C_SCL_HIGH (CLR(I2C_SCL_PORT_DIR, I2C_SCL_PIN))

#define I2C_SDA_VALUE (GETBIT(I2C_SDA_PORT_READ, I2C_SDA_PIN))


void i2c_init(void) 
{
  CLR(I2C_SDA_PORT, I2C_SDA_PIN);
  CLR(I2C_SCL_PORT, I2C_SCL_PIN);
  I2C_SDA_HIGH;
  I2C_SCL_HIGH;
}

void i2c_start(void)
{
  I2C_SCL_LOW;
  _delay_us(I2C_DELAY);
  I2C_SDA_HIGH;
  _delay_us(I2C_DELAY);
  I2C_SCL_HIGH;
  _delay_us(I2C_DELAY);
  I2C_SDA_LOW;
  _delay_us(I2C_DELAY);
}

void i2c_stop(void) 
{
  I2C_SCL_LOW;
  I2C_SDA_LOW;
  _delay_us(I2C_DELAY);
  I2C_SCL_HIGH;
  _delay_us(I2C_DELAY); 
  I2C_SDA_HIGH;
  _delay_us(I2C_DELAY);
}

unsigned char i2c_send_byte(unsigned char  byte) 
{
  unsigned char  i;
  for(i = 0; i < 8; i ++) 
  {
    I2C_SCL_LOW;
    if(GETBIT(byte, 7)) 
	{
      I2C_SDA_HIGH;
    } 
	else 
	{
      I2C_SDA_LOW;
    }
    _delay_us(I2C_DELAY);
    I2C_SCL_HIGH;
    _delay_us(I2C_DELAY);
    byte <<= 1;
  }
  I2C_SCL_LOW;
  I2C_SDA_HIGH;
  _delay_us(I2C_DELAY);
  I2C_SCL_HIGH;
  _delay_us(I2C_DELAY);
  if(I2C_SDA_VALUE == 1) 
  {
    return 0;
  }
  return 1;
}

unsigned char  i2c_read_byte(unsigned char  ack) 
{ 
  I2C_SCL_LOW;
  I2C_SDA_HIGH;
  _delay_us(I2C_DELAY);
  I2C_SCL_HIGH;
  _delay_us(I2C_DELAY);
  unsigned char  i, result = I2C_SDA_VALUE; 
  for(i = 0; i < 7; i ++) 
  {
    I2C_SCL_LOW;
    _delay_us(I2C_DELAY);
    I2C_SCL_HIGH;
    _delay_us(I2C_DELAY);
    result <<= 1;
    if(I2C_SDA_VALUE == 1) 
	{
      result |= 1;
    }
  }
  I2C_SCL_LOW;
  if(ack == I2C_ACK) 
  {
    I2C_SDA_LOW;
  } 
  else 
  {
    I2C_SDA_HIGH;
  }
  _delay_us(I2C_DELAY);
  I2C_SCL_HIGH;
  _delay_us(I2C_DELAY);
  return result; 
}

unsigned char i2c_address(unsigned char address, unsigned char rw) 
  {
	 if(rw == I2C_READ) 
  	 {
		SET(address, 0);
	 }		   
	 else
	 {
		CLR(address, 0);
	 }		 
	 
	 return i2c_send_byte(address); 
  }
  
void i2c_read(void) 
{
	uint16_t BytesToRead;
	uint8_t dev_address;
	
	BytesToRead = Endpoint_Read_16_LE();
	dev_address = Endpoint_Read_8();
	
	Endpoint_ClearOUT();
	Endpoint_SelectEndpoint(AVRISP_DATA_IN_EPADDR);
	Endpoint_SetEndpointDirection(ENDPOINT_DIR_IN);
	
	i2c_init();
	i2c_address(dev_address, I2C_READ);
	//читаем
	while (BytesToRead > 0)
	{

		/* Read the next byte */
		if(BytesToRead == 1)//последний байт
		{
			Endpoint_Write_8(i2c_read_byte(I2C_NACK));
			i2c_stop();
		}
		else
			Endpoint_Write_8(i2c_read_byte(I2C_ACK));

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
}

void i2c_write(void)
{
	uint16_t BytesToWrite;
	uint8_t  ChunkToWrite;
	uint8_t  ProgData[16];
	uint8_t i2c_stop_aw;
	uint8_t dev_address;
	
	BytesToWrite = Endpoint_Read_16_LE();
	dev_address = Endpoint_Read_8();
	i2c_stop_aw = Endpoint_Read_8();
	
	i2c_init();
	i2c_start();
	i2c_address(dev_address, I2C_WRITE);
	
	while (BytesToWrite > 0)
	{	
		if (BytesToWrite < sizeof(ProgData)) ChunkToWrite = BytesToWrite; 
			else ChunkToWrite = sizeof(ProgData);
			
		Endpoint_Read_Stream_LE(&ProgData, ChunkToWrite, NULL);
		
		for (uint8_t CurrentByte = 0; CurrentByte < ChunkToWrite; CurrentByte++)
		{
			i2c_send_byte(ProgData[CurrentByte]);
			BytesToWrite--;
		}
	}
	
	if(i2c_stop_aw == 1) i2c_stop();
	else i2c_start();
	
	Endpoint_ClearOUT();
}

void i2c_writebyte(void)
{
	uint8_t data;
	
	data = Endpoint_Read_8();
	
	Endpoint_ClearOUT();
	Endpoint_SelectEndpoint(AVRISP_DATA_IN_EPADDR);
	Endpoint_SetEndpointDirection(ENDPOINT_DIR_IN);
	
	//i2c_init();
	//i2c_start();
	Endpoint_Write_8(i2c_send_byte(data));
    
	//i2c_stop();
	Endpoint_ClearIN();
}

void i2c_readbyte(void)
{
	uint8_t ack;
	
	ack = Endpoint_Read_8();
	
	Endpoint_ClearOUT();
	Endpoint_SelectEndpoint(AVRISP_DATA_IN_EPADDR);
	Endpoint_SetEndpointDirection(ENDPOINT_DIR_IN);
	
	//i2c_init();
	//i2c_start();
	Endpoint_Write_8(i2c_read_byte(ack));
    
	//i2c_stop();
	Endpoint_ClearIN(); 
}