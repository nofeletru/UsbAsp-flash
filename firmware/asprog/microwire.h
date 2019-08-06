
//Functions for sw microwire interface
void mwStart();
void mwSendData(unsigned int data,byte n);
byte mwReadByte();
void mwEnd();
byte mwBusy();

void mwInitPins();
void mwDeinitPins();
