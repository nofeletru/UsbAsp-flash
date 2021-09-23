#define I2C_READ 1
#define I2C_WRITE 0

#define I2C_ACK 0
#define I2C_NACK 1

void i2c_init();
void i2c_start();
void i2c_stop();
byte i2c_send_byte(byte  sbyte);
byte i2c_read_byte(byte  ack);
byte i2c_address(byte address, byte rw);
