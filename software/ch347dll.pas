unit CH347DLL;

interface

uses
  SysUtils;

//SPI Controller Configuration
type _SPI_CONFIG = packed record
	iMode: byte;                 // 0-3:SPI Mode0/1/2/3
	iClock: byte;                // 0=60MHz, 1=30MHz, 2=15MHz, 3=7.5MHz, 4=3.75MHz, 5=1.875MHz, 6=937.5KHz,7=468.75KHz
	iByteOrder: byte;            // 0=LSB first(LSB), 1=MSB first(MSB)
	iSpiWriteReadInterval: word; // The SPI interface routinely reads and writes data command, the unit is uS
	iSpiOutDefaultData: byte;    // SPI prints data by default when it reads data
	iChipSelect: cardinal;           // Piece of selected control, if bit 7 is 0, slice selection control is ignored, if bit 7 is 1, the parameter is valid: bit 1 bit 0 is 00/01 and CS1/CS2 pins are selected as low level active chip options respectively
	CS1Polarity: byte;           // Bit 0: CS1 polarity control: 0: effective low level; 1: effective lhigh level;
	CS2Polarity: byte;           // Bit 0: CS2 polarity control: 0: effective low level; 1: effective lhigh level;
	iIsAutoDeativeCS: word;      // Whether to undo slice selection automatically after the operation is complete
	iActiveDelay: word;          // Set the latency for read/write operations after slice selection,the unit is us
	iDelayDeactive: cardinal;        // Delay time for read and write operations after slice selection is unselected,the unit is us
end;

  mpSpiCfgS = ^_SPI_CONFIG;

const
  mCH347_PACKET_LENGTH = 512;		// Length of packets supported by ch347
  mCH341_MAX_NUMBER = 16;			// Maximum number of CH375 connected at the same time

  mCH341A_CMD_I2C_STREAM = $AA;		// The command package of the I2C interface, starting from the secondary byte, is the I2C command stream

  mCH341A_CMD_I2C_STM_STA =	$74;		// Command flow of I2C interface: generate start bit
  mCH341A_CMD_I2C_STM_STO =	$75;		// Command flow of I2C interface: generate stop bit
  mCH341A_CMD_I2C_STM_OUT =	$80;		// Command flow of I2C interface: output data, bit 5- bit 0 is the length, subsequent bytes are data, and length 0 only sends one byte and returns an answer
  mCH341A_CMD_I2C_STM_IN =	$C0;		// I2C interface command flow: input data, bit 5-bit 0 is the length, and 0 length only receives one byte and sends no response
  mCH341A_CMD_I2C_STM_SET =	$60;		// Command flow of I2C interface: set parameters, bit 2=i/o number of SPI (0= single input single output, 1= double input double output), bit 1 0=i2c speed (00= low speed, 01= standard, 10= fast, 11= high speed)
  mCH341A_CMD_I2C_STM_US =	$40;		// Command flow of I2C interface: delay in microseconds, bit 3- bit 0 as delay value
  mCH341A_CMD_I2C_STM_MS =	$50;		// Command flow of I2C interface: delay in microseconds, bit 3-bit 0 as delay value
  mCH341A_CMD_I2C_STM_DLY =	$0F;		// Maximum value of single command delay of command flow of I2C interface
  mCH341A_CMD_I2C_STM_END =	$00;		// Command flow of I2C interface: Command package ends in advance


//CH347 Mode Common Function,support open,close,USB read,USB written and HID of all modes.
//Open USB device
function CH347OpenDevice(DevI: cardinal): integer; stdcall; external 'CH347DLL.DLL';

//Close USB device
function CH347CloseDevice(iIndex: cardinal): boolean; stdcall; external 'CH347DLL.DLL';

// Read USB data block
function CH347ReadData(iIndex: cardinal;      // Specifies the device number
		       oBuffer: pointer;         // Points to a buffer large enough to save the read data
		       ioLength: pcardinal): boolean; stdcall; external 'CH347DLL.DLL';  // Points to the length unit, the length to be read when input is the length to be read, and the actual read length after return

// Write USB data block
function CH347WriteData(iIndex: cardinal;      // Specifies the device number
			iBuffer: pointer;     // Points to a buffer large enough to save the written data
			ioLength: pcardinal): boolean; stdcall; external 'CH347DLL.DLL';  // Points to the length unit,the input length is the intended length, and the return length is the actual length


//***************SPI********************
// SPI Controller Initialization
function CH347SPI_Init(iIndex: cardinal; SpiCfg: mpSpiCfgS): boolean; stdcall; external 'CH347DLL.DLL';

// Get SPI controller configuration information
//BOOL    WINAPI  CH347SPI_GetCfg(ULONG iIndex,mSpiCfgS *SpiCfg);

// Before setting the chip selection status, call CH347SPI_Init to set CS
function CH347SPI_ChangeCS(iIndex: cardinal;         // Specify device number
			   iStatus: byte): boolean; stdcall; external 'CH347DLL.DLL';       // 0=Cancel the piece to choose,1=Set piece selected

// Set SPI slice selection
function CH347SPI_SetChipSelect(iIndex: cardinal;            // Specify device number
				iEnableSelect: word;     // The lower octet is CS1 and the higher octet is CS2. A byte value of 1= sets CS, 0= ignores this CS setting
				iChipSelect: word;       // The lower octet is CS1 and the higher octet is CS2. A byte value of 1= sets CS, 0= ignores this CS setting
				iIsAutoDeativeCS: cardinal;  // The lower 16 bits are CS1 and the higher 16 bits are CS2. Whether to undo slice selection automatically after the operation is complete
				iActiveDelay: cardinal;      // The lower 16 bits are CS1 and the higher 16 bits are CS2. Set the latency of read/write operations after chip selection, the unit is us
				iDelayDeactive: cardinal): boolean; stdcall; external 'CH347DLL.DLL';  // The lower 16 bits are CS1 and the higher 16 bits are CS2. Delay time for read and write operations after slice selection the unit is us

//SPI4 write data
function CH347SPI_Write(iIndex: cardinal;          // Specify device number
			iChipSelect: cardinal;     // Slice selection control, when bit 7 is 0, slice selection control is ignored, and when bit 7 is 1, slice selection operation is performed
			iLength: cardinal;         // Number of bytes of data to be transferred
			iWriteStep: cardinal;      // The length of a single block to be read
			ioBuffer: pointer): boolean; stdcall; external 'CH347DLL.DLL';       // Point to a buffer to place the data to be written out from MOSI

//SPI4 read data. No need to write data first, the efficiency is higher than that of the CH347SPI_WriteRead
function CH347SPI_Read(iIndex: cardinal;           // Specify device number
		       iChipSelect: cardinal;      // Slice selection control, when bit 7 is 0, slice selection control is ignored, and when bit 7 is 1, slice selection operation is performed
		       oLength: cardinal;          // Number of bytes to send
		       iLength: pcardinal;          // Number of bytes of data to be read in
		       ioBuffer: pointer): boolean; stdcall; external 'CH347DLL.DLL';        // Points to a buffer that place the data to be written out from DOUT, return the data read in from DIN

// Handle SPI data stream 4-wire interface
function CH347SPI_WriteRead(iIndex: cardinal;       // Specify the device number
			    iChipSelect: cardinal;  // Selection control, if the film selection control bit 7 is 0, ignore the film selection control bit 7 is 1 and operate the film selection
			    iLength: cardinal;      // Number of bytes of data to be transferred
			    ioBuffer: pointer): boolean; stdcall; external 'CH347DLL.DLL';   // Points to a buffer that place the data to be written out from DOUT, return the data read in from DIN

//place the data to be written from MOSI, return the data read in from MISO
function CH347StreamSPI4(iIndex: cardinal;       // Specify the device number
			 iChipSelect: cardinal;  // Film selection control, if bit 7 is 0, slice selection control is ignored.If bit 7 is 1, the parameter is valid:Bit 1 bit 0 is 00/01/10. Select D0/D1/D2 pins as low level active chip options respectively
			 iLength: cardinal;      // Number of bytes of data to be transferred
			 ioBuffer: pointer): boolean; stdcall; external 'CH347DLL.DLL';   // Points to a buffer, places data to be written out from DOUT, and returns data to be read in from DIN


//********IIC***********/
//Set the serial port flow mode
function CH347I2C_Set(iIndex: cardinal;   // Specify the device number
		      iMode: cardinal): boolean; stdcall; external 'CH347DLL.DLL'; // See downlink for the specified mode
//bit 1-bit 0: I2C interface speed /SCL frequency, 00= low speed /20KHz,01= standard /100KHz(default),10= fast /400KHz,11= high speed /750KHz
//Other reservations, must be 0

//Set the hardware asynchronous delay to a specified number of milliseconds before the next stream operation
function CH347I2C_SetDelaymS(iIndex: cardinal;        // Specify the device number
                             iDelay: cardinal): boolean; stdcall; external 'CH347DLL.DLL';    // Specifies the delay duration (mS)

//Process I2C data stream, 2-wire interface, clock line for SCL pin, data line for SDA pin
function CH347StreamI2C(iIndex: cardinal;        // Specify the device number
                        iWriteLength: cardinal;  // The number of bytes of data to write
			iWriteBuffer: pointer;  // Points to a buffer to place data ready to be written out, the first byte is usually the I2C device address and read/write direction bit
			iReadLength: cardinal;   // Number of bytes of data to be read
			oReadBuffer: pointer): boolean; stdcall; external 'CH347DLL.DLL'; // Points to a buffer to place data ready to be read in



//Get the GPIO direction and pin level of CH347
function CH347GPIO_Get(iIndex: cardinal;
		       iDir: PCHAR;       // Pin direction: GPIo0-7 corresponding bit 0-7,0: input; 1: output
		       iData: PCHAR): boolean; stdcall; external 'CH347DLL.DLL';     // GPIO0 level: GPIO0-7 corresponding bit 0-7,0: low level; 1: high level


//Set the GPIO direction and pin level of CH347
function CH347GPIO_Set(iIndex: cardinal;
		       iEnable: byte;        // Data validity flag: The corresponding bits 0-7 correspond to GPIO0-7.
		       iSetDirOut: byte;     // Sets the I/O direction, with pin 0 corresponding to input and pin 1 corresponding to output. Gpio0-7 corresponds to bits 0-7.
		       iSetDataOut: byte): boolean; stdcall; external 'CH347DLL.DLL';   // Outputs data. If the I/O direction is output, then a pin outputs low level at a clear 0 and high level at a position 1

implementation

end.

