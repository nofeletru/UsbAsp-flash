#define I2C_DELAY 5

#define I2C_READ 1
#define I2C_WRITE 0

#define I2C_ACK 0
#define I2C_NACK 1

#define I2C_SDA_PIN           PB4                       
#define I2C_SCL_PIN           PB3                      

#define I2C_SDA_PORT_READ     PINB                       

#define I2C_SDA_PORT_DIR      DDRB                       
#define I2C_SCL_PORT_DIR      DDRB                       
#define I2C_SDA_PORT          PORTB                       
#define I2C_SCL_PORT          PORTB

void i2c_init();
void i2c_start();
void i2c_start_rep();
void i2c_stop();
byte i2c_send_byte(byte  sbyte);
byte i2c_read_byte(byte  ack);
byte i2c_address(byte address, byte rw);
