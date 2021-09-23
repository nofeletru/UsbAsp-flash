#define rchunk 64
#define wchunk 256

#define FUNC_SPI_INIT 7
#define FUNC_SPI_DEINIT 8
#define FUNC_SPI_READ 10
#define FUNC_SPI_WRITE 11

#define FUNC_I2C_INIT      20
#define FUNC_I2C_READ      21
#define FUNC_I2C_WRITE     22
#define FUNC_I2C_START     23
#define FUNC_I2C_STOP      24
#define FUNC_I2C_READBYTE  25
#define FUNC_I2C_WRITEBYTE 26

#define FUNC_MW_READ      30
#define FUNC_MW_WRITE     31
#define FUNC_MW_BUSY      32
#define FUNC_MW_INIT      33
#define FUNC_MW_DEINIT    34

#define ACK 81

#define ERROR_RECV 99
#define ERROR_NO_CMD 100

void ParseCommand(char cmd);
