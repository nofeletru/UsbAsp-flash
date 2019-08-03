#include "commands.h"
#include "spi_cmd.h"
#include "i2c_cmd.h"
#include "mw_cmd.h"

#include <arduino.h>

byte buff[256];

void ParseCommand(char cmd) {
  //spi
  if (cmd == FUNC_SPI_READ) {
    spi_cmd_read();

  } else if (cmd == FUNC_SPI_WRITE) {
    spi_cmd_write();

  } else if (cmd == FUNC_SPI_INIT) {
    spi_cmd_init();

  } else if (cmd == FUNC_SPI_DEINIT) {
    spi_cmd_deinit();

  //i2c
  } else if (cmd == FUNC_I2C_INIT) {
    i2c_cmd_init(); 
 
  } else if (cmd == FUNC_I2C_ACK) {
    i2c_cmd_ack();  
 
  } else if (cmd == FUNC_I2C_READ) {
    i2c_cmd_read();  
 
  } else if (cmd == FUNC_I2C_WRITE) {
    i2c_cmd_write();

  //MICROWIRE
  } else if (cmd == FUNC_MW_WRITE) {
    mw_cmd_write();    

  } else if (cmd == FUNC_MW_READ) {
    mw_cmd_read();    

  } else if (cmd == FUNC_MW_BUSY) {
    mw_cmd_busy();    

  } else if (cmd == FUNC_MW_INIT) {
    mw_cmd_init();    

  } else if (cmd == FUNC_MW_DEINIT) {
    mw_cmd_deinit();    

  //
  } else {
    Serial.write(ERROR_NO_CMD);
    Serial.flush();
  }

}
