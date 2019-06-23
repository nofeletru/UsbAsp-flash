#include <avr/io.h>
#include "clock.h"
#include <util/delay.h>
#include "isp.h"
#include "clock.h"
#include "usbasp.h"
#include "microwire.h"


void mwStart()
{
	// set CS to 0
    ISP_OUT &= ~(1 <<ISP_RST);
	// set CLK to 0
    ISP_OUT &= ~(1 << ISP_SCK);
	ispDelay();

	// set CS to 1
    ISP_OUT |= (1 << ISP_RST);
	/*
	//send start bit
                ISP_OUT |= (1 << ISP_MOSI);
	ispDelay();
                ISP_OUT |= (1 << ISP_SCK);
	ispDelay();
                ISP_OUT &= ~(1 << ISP_SCK);
	ispDelay();	*/
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
		ispDelay();
        ISP_OUT &= ~(1 << ISP_SCK);
		ispDelay();
		n--;
	}
}


unsigned char mwReadByte()
{
	unsigned char dd,i;

    dd =0 ;
	for(i=0;i<8;i++)
	{
		dd = dd<<1;
		ISP_OUT |= (1 << ISP_SCK);
		ispDelay();
		ISP_OUT &= ~(1 << ISP_SCK);
		ispDelay();

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
	ispDelay();
}

uchar mwBusy()
{
	CS_HI();
	_delay_us(10);
	ispDelay();
	if ((ISP_IN & (1 << ISP_MISO)) != 0)
	{
		CS_LOW();
		return(0);
	}
	else
	{
		CS_LOW();
		return(1); //Линия занята
	};
}
	
