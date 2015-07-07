//Functions for sw microwire interface
void mwStart();

void mwSendData(unsigned int data,unsigned char n);

unsigned char mwReadByte();

void mwEnd();

uchar mwBusy();