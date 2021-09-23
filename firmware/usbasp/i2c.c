
#include <avr/io.h>
#include "clock.h"
#include <util/delay.h>
#include "stdio.h"
#include "stdlib.h"
#include "i2c.h"
#include "isp.h"

#define I2C_SDA_PIN           ISP_MISO                       //ëèíèÿ SDA
#define I2C_SCL_PIN           ISP_MOSI                      //ëèíèÿ SCL

#define I2C_SDA_PORT_READ     ISP_IN                        //ïîðò âõîäà

#define I2C_SDA_PORT_DIR      ISP_DDR                       //ïîðò íàïðàâëåíèÿ
#define I2C_SCL_PORT_DIR      ISP_DDR                       //ïîðò íàïðàâëåíèÿ
#define I2C_SDA_PORT          ISP_OUT                       //ïîðò âûõîäà
#define I2C_SCL_PORT          ISP_OUT                       //ïîðò âûõîäà

#define SET(reg, bit) (reg |= (1 << bit))
#define CLR(reg, bit) (reg &= ~(1 << bit))
#define GETBIT(byte, bit) ((byte >> bit) & 1)

#define I2C_SDA_LOW (SET(I2C_SDA_PORT_DIR, I2C_SDA_PIN))
#define I2C_SDA_HIGH (CLR(I2C_SDA_PORT_DIR, I2C_SDA_PIN))
#define I2C_SCL_LOW (SET(I2C_SCL_PORT_DIR, I2C_SCL_PIN))
#define I2C_SCL_HIGH (CLR(I2C_SCL_PORT_DIR, I2C_SCL_PIN))

#define I2C_SDA_VALUE (GETBIT(I2C_SDA_PORT_READ, I2C_SDA_PIN))


void i2c_init() 
{
  CLR(I2C_SDA_PORT, I2C_SDA_PIN);
  CLR(I2C_SCL_PORT, I2C_SCL_PIN);
  I2C_SDA_HIGH;
  I2C_SCL_HIGH;
}

void i2c_start()
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

void i2c_stop() 
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

