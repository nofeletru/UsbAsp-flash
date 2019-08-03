#include <arduino.h>
#include <util/delay.h>
#include "microwire.h"

#define CS_LOW()  ISP_OUT &= ~(1 << ISP_RST); /* RST low */
#define CS_HI()   ISP_OUT |= (1 << ISP_RST); /* RST high */

void mwStart()
{
	// set CS to 0
    ISP_OUT &= ~(1 <<ISP_RST);
	// set CLK to 0
    ISP_OUT &= ~(1 << ISP_SCK);
	_delay_us(15);

	// set CS to 1
    ISP_OUT |= (1 << ISP_RST);
}

void mwSendData(unsigned int data,byte n)
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
		_delay_us(15);
        ISP_OUT &= ~(1 << ISP_SCK);
		_delay_us(15);
		n--;
	}
}


byte mwReadByte()
{
	byte dd,i;

    dd =0 ;
	for(i=0;i<8;i++)
	{
		dd = dd<<1;
		ISP_OUT |= (1 << ISP_SCK);
		_delay_us(15);
		ISP_OUT &= ~(1 << ISP_SCK);
		_delay_us(15);

		if ((ISP_IN & (1 << ISP_MISO)) != 0)
		{
				dd++;
		}

	}
	return dd;
}

void mwEnd()
{
	// set CS to 0
    ISP_OUT &= ~(1 <<ISP_RST);
	// set CLK to 0
                ISP_OUT &= ~(1 << ISP_SCK);
	_delay_us(15);
}

byte mwBusy()
{
	CS_HI();
	_delay_us(25);
	if ((ISP_IN & (1 << ISP_MISO)) != 0)
	{
		CS_LOW();
		return(0);
	}
	else
	{
		CS_LOW();
		return(1); 
	};
}

void mwInitPins() {
  ISP_DDR |= (1 << ISP_RST) | (1 << ISP_SCK) | (1 << ISP_MOSI);
  CS_LOW();  
}

void mwDeinitPins()  {
  ISP_DDR &= ~((1 << ISP_RST) | (1 << ISP_SCK) | (1 << ISP_MOSI));
  ISP_OUT &= ~((1 << ISP_RST) | (1 << ISP_SCK) | (1 << ISP_MOSI));   
}
