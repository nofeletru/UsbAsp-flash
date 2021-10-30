#include <arduino.h>
#include "defines.h"
#include "i2c.h"

#define SET(reg, bit) (reg |= (1 << bit))
#define CLR(reg, bit) (reg &= ~(1 << bit))
#define GETBIT(byte, bit) ((byte >> bit) & 1)


void i2c_init() 
{
  digitalWrite(I2C_SDA_PIN, LOW);
  digitalWrite(I2C_SCL_PIN, LOW);
  I2C_SDA_HIGH;
  I2C_SCL_HIGH;
}

void i2c_start()
{
  I2C_SCL_LOW;
  delayMicroseconds(I2C_DELAY);
  I2C_SDA_HIGH;
  delayMicroseconds(I2C_DELAY);
  I2C_SCL_HIGH;
  delayMicroseconds(I2C_DELAY);
  I2C_SDA_LOW;
  delayMicroseconds(I2C_DELAY);
}

void i2c_stop() 
{
  I2C_SCL_LOW;
  I2C_SDA_LOW;
  delayMicroseconds(I2C_DELAY);
  I2C_SCL_HIGH;
  delayMicroseconds(I2C_DELAY); 
  I2C_SDA_HIGH;
  delayMicroseconds(I2C_DELAY);
}

byte i2c_send_byte(byte  sbyte) 
{
  byte  i;
  for(i = 0; i < 8; i ++) 
  {
    I2C_SCL_LOW;
    if(GETBIT(sbyte, 7)) 
  {
      I2C_SDA_HIGH;
    } 
  else 
  {
      I2C_SDA_LOW;
    }
    delayMicroseconds(I2C_DELAY);
    I2C_SCL_HIGH;
    delayMicroseconds(I2C_DELAY);
    sbyte <<= 1;
  }
  I2C_SCL_LOW;
  I2C_SDA_HIGH;
  delayMicroseconds(I2C_DELAY);
  I2C_SCL_HIGH;
  delayMicroseconds(I2C_DELAY);
  if(I2C_SDA_VALUE == 1) 
  {
    return 0;
  }
  return 1;
}

byte  i2c_read_byte(byte  ack) 
{ 
  I2C_SCL_LOW;
  I2C_SDA_HIGH;
  delayMicroseconds(I2C_DELAY);
  I2C_SCL_HIGH;
  delayMicroseconds(I2C_DELAY);
  byte  i, result = I2C_SDA_VALUE; 
  for(i = 0; i < 7; i ++) 
  {
    I2C_SCL_LOW;
    delayMicroseconds(I2C_DELAY);
    I2C_SCL_HIGH;
    delayMicroseconds(I2C_DELAY);
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
  delayMicroseconds(I2C_DELAY);
  I2C_SCL_HIGH;
  delayMicroseconds(I2C_DELAY);
  return result; 
}

byte i2c_address(byte address, byte rw) 
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
  
