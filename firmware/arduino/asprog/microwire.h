
//Functions for sw microwire interface
void mwSendData(byte data, byte n);
byte mwReadByte();
void mwEnd();
byte mwBusy();

void mwInitPins();
void mwDeinitPins();
