#define ISP_OUT   PORTB
#define ISP_IN    PINB
#define ISP_DDR   DDRB
#define ISP_RST   PB2
#define ISP_MOSI  PB3
#define ISP_MISO  PB4
#define ISP_SCK   PB5

//Functions for sw microwire interface
void mwStart();
void mwSendData(unsigned int data,byte n);
byte mwReadByte();
void mwEnd();
byte mwBusy();

void mwInitPins();
void mwDeinitPins();
