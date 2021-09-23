#include "ISP/ISPProtocol.h"

#define I2C_DELAY 5

#define I2C_READ 1
#define I2C_WRITE 0

#define I2C_ACK 0
#define I2C_NACK 1

#define I2C_SDA_PIN           PB3                      //линия SDA
#define I2C_SCL_PIN           PB2                      //линия SCL

#define I2C_SDA_PORT_READ     AUX_LINE_PIN             //порт входа

#define I2C_SDA_PORT_DIR      AUX_LINE_DDR             //порт направления
#define I2C_SCL_PORT_DIR      AUX_LINE_DDR             //порт направления
#define I2C_SDA_PORT          AUX_LINE_PORT            //порт выхода
#define I2C_SCL_PORT          AUX_LINE_PORT            //порт выхода

#define CMD_I2C_READ		  0x35
#define CMD_I2C_WRITE		  0x36
#define CMD_I2C_START  		  0x37
#define CMD_I2C_STOP  		  0x55
#define CMD_I2C_READBYTE	  0x56
#define CMD_I2C_WRITEBYTE	  0x57
#define CMD_I2C_INIT    	  0x58

void i2c_init(void);
void i2c_start(void);
void i2c_stop(void);
unsigned char  i2c_send_byte(unsigned char  byte);
unsigned char  i2c_read_byte(unsigned char  ack);
unsigned char i2c_address(unsigned char address, unsigned char rw);
void i2c_read(void);
void i2c_write(void);
void i2c_writebyte(void);
void i2c_readbyte(void);