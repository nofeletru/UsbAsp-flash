#include <arduino.h>
#include "defines.h"
#include "microwire.h"

void mwSendData(byte data, byte n)
{
	for(unsigned char i=0; i < n; i++)
	{
		if ((data >> (7-i)) & 1)
		{
      digitalWrite(ISP_MOSI, HIGH);
		}
		else
		{
			digitalWrite(ISP_MOSI, LOW);
		}

    digitalWrite(ISP_SCK, HIGH);
		delayMicroseconds(MW_DELAY);
    digitalWrite(ISP_SCK, LOW);
		delayMicroseconds(MW_DELAY);
	}
}


byte mwReadByte()
{
	byte dd,i;

    dd =0 ;
	for(i=0;i<8;i++)
	{
		dd = dd<<1;
    digitalWrite(ISP_SCK, HIGH);
		delayMicroseconds(MW_DELAY);
		digitalWrite(ISP_SCK, LOW);
		delayMicroseconds(MW_DELAY);

		if (digitalRead(ISP_MISO) != 0)
		{
				dd++;
		}

	}
	return dd;
}

void mwEnd()
{
	// set CS to 0
  digitalWrite(ISP_RST, LOW);
	// set CLK to 0
  digitalWrite(ISP_SCK, LOW); 
	delayMicroseconds(MW_DELAY);
}

byte mwBusy()
{
	digitalWrite(ISP_RST, HIGH);
	delayMicroseconds(25);
  
	if (digitalRead(ISP_MISO) != 0)
	{
		digitalWrite(ISP_RST, LOW);
		return(0);
	}
	else
	{
		digitalWrite(ISP_RST, LOW);
		return(1); 
	};
}

void mwInitPins() {
  pinMode(ISP_RST, OUTPUT);
  pinMode(ISP_SCK, OUTPUT);
  pinMode(ISP_MOSI, OUTPUT);
  digitalWrite(ISP_RST, LOW);  
}

void mwDeinitPins()  {
  pinMode(ISP_RST, INPUT);
  pinMode(ISP_SCK, INPUT);
  pinMode(ISP_MOSI, INPUT);  
}
