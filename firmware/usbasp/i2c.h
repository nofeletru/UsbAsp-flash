
#define I2C_DELAY 5

#define I2C_READ 1
#define I2C_WRITE 0

#define I2C_ACK 0
#define I2C_NACK 1

void i2c_init();
void i2c_start();
void i2c_stop();
unsigned char  i2c_send_byte(unsigned char  byte);
unsigned char  i2c_read_byte(unsigned char  ack);
unsigned char i2c_address(unsigned char address, unsigned char rw);
