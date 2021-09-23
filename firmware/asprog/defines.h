#define I2C_DELAY 5

#define I2C_SDA_PIN ISP_MISO                       
#define I2C_SCL_PIN ISP_MOSI  

#define I2C_SDA_LOW  pinMode(I2C_SDA_PIN, OUTPUT)
#define I2C_SDA_HIGH pinMode(I2C_SDA_PIN, INPUT)
#define I2C_SCL_LOW  pinMode(I2C_SCL_PIN, OUTPUT)
#define I2C_SCL_HIGH pinMode(I2C_SCL_PIN, INPUT)

#define I2C_SDA_VALUE digitalRead(I2C_SDA_PIN)

#define MW_DELAY 15

#define ISP_RST   10
#define ISP_MOSI  11
#define ISP_MISO  12
#define ISP_SCK   13
