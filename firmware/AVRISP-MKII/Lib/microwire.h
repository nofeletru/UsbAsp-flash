#include "ISP/ISPProtocol.h"
#include "spi25.h"

#define MW_DELAY		20

#define ISP_SCK			PB1
#define ISP_MOSI		PB2
#define ISP_MISO		PB3
#define ISP_IN			PINB
#define ISP_OUT			PORTB

#define CMD_MW_READ		0x38
#define CMD_MW_WRITE	0x39
#define CMD_MW_BUSY		0x40
#define CMD_MW_INIT		0x41

//Functions for sw microwire interface
void mwSendData(unsigned char data,unsigned char n);
unsigned char mwReadByte(void);
void mwEnd(void);
unsigned char mwBusy(void);

void mw_read(void);
void mw_write(void);
void mw_busy(void);
void mw_init(void);