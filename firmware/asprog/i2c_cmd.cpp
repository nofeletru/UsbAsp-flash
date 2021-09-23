#include <arduino.h>
#include "commands.h"
#include "i2c.h"
#include "i2c_cmd.h"

extern byte buff[256];

void i2c_cmd_init() {

  i2c_init();

  Serial.write(FUNC_I2C_INIT); //Подтверждаем команду
  Serial.flush();
}

void i2c_cmd_writebyte() {
  byte data[1];
  int bytesread;
  byte ack;

  bytesread = Serial.readBytes(data, 1);

  if (bytesread == 0) {
    Serial.write(ERROR_RECV); //Ошибка
    Serial.flush();
    return;
  }

  Serial.write(FUNC_I2C_WRITEBYTE); //Подтверждаем команду
  Serial.flush();

  //i2c_start();
  
  ack = i2c_send_byte(data[0]);
  
  //i2c_stop();

  Serial.write(ack);
  Serial.flush();

}

void i2c_cmd_readbyte() {
  byte data[1];
  int bytesread;
  byte ack[1];

  bytesread = Serial.readBytes(ack, 1);

  if (bytesread == 0) {
    Serial.write(ERROR_RECV); //Ошибка
    Serial.flush();
    return;
  }

  Serial.write(FUNC_I2C_READBYTE); //Подтверждаем команду
  Serial.flush();

  //i2c_start();
  
  data[0] = i2c_read_byte(ack[0]);
  
  //i2c_stop();

  Serial.write(data[0]);
  Serial.flush();

}

void i2c_cmd_read() {
  int prog_nbytes;
  int bytesread;
  byte addr;

  bytesread = Serial.readBytes(buff, 3);
  if (bytesread < 3) {
    Serial.write(ERROR_RECV); //Ошибка
    Serial.flush();
    return;
  }

  addr = buff[0];

  prog_nbytes = buff[1];
  prog_nbytes = prog_nbytes << 8;
  prog_nbytes = prog_nbytes | buff[2];

  Serial.write(FUNC_I2C_READ);
  Serial.flush();

  //Работаем с I2C
  i2c_address(addr, I2C_READ);
  while (prog_nbytes > 0) {
    if (prog_nbytes >= rchunk) {
      for(int i=0; i < rchunk; i++) {
        if(prog_nbytes-1 == i){
         buff[i] = i2c_read_byte(I2C_NACK);
         i2c_stop();
        }
        else
         buff[i] = i2c_read_byte(I2C_ACK);
      }
      prog_nbytes = prog_nbytes - Serial.write(buff, rchunk);
    } else {
      for(int i=0; i < prog_nbytes; i++) {
          if(prog_nbytes-1 == i){
         buff[i] = i2c_read_byte(I2C_NACK);
         i2c_stop();
        }
        else
         buff[i] = i2c_read_byte(I2C_ACK);
      }   
      prog_nbytes = prog_nbytes - Serial.write(buff, prog_nbytes);
    }

    Serial.flush();

    bytesread = Serial.readBytes(buff, 1);
    if ((bytesread == 0) || (buff[0] != ACK)) {
      i2c_stop();
      return;
    }
  }

}

void i2c_cmd_write() {
  int prog_nbytes;
  int bytesread;
  byte addr;
  byte stop_aw;

  //Получаем остальные данные
  bytesread = Serial.readBytes(buff, 4);
  if (bytesread < 4) {
    Serial.write(ERROR_RECV); //Ошибка
    Serial.flush();
    return;
  }

  addr = buff[0];
  stop_aw = buff[1];

  prog_nbytes = buff[2];
  prog_nbytes = prog_nbytes << 8;
  prog_nbytes = prog_nbytes | buff[3];

  Serial.write(FUNC_I2C_WRITE); //Подтверждаем команду
  Serial.flush();


  //Работаем с I2C
  i2c_start();
  i2c_address(addr, I2C_WRITE);
  while (prog_nbytes > 0) {
    if (prog_nbytes >= wchunk) {
      bytesread = Serial.readBytes(buff, wchunk);
      for(int i=0; i < rchunk; i++)
        i2c_send_byte(buff[i]);
    } else {
      bytesread = Serial.readBytes(buff, prog_nbytes);
      for(int i=0; i < prog_nbytes; i++)
        i2c_send_byte(buff[i]);
    }
    
    if (bytesread == 0) {
      i2c_stop();
      return;
    }
    
    prog_nbytes = prog_nbytes - bytesread;

    Serial.write(ACK);
    Serial.flush();
  }

  if(stop_aw == 1) i2c_stop();
    else i2c_start();
}
