#include <arduino.h>
#include <SPI.h>
#include "defines.h"
#include "spi_cmd.h"
#include "commands.h"

extern byte buff[256];

void spi_cmd_init() {
  long spi_speed;
  byte bytesread;

  bytesread = Serial.readBytes(buff, 1);

  if (bytesread == 0) {
    Serial.write(ERROR_RECV); //Ошибка
    Serial.flush();
    return;
  }

  if (buff[0] == 0) {
    spi_speed = 8000000;
  } else if (buff[0] == 1) {
    spi_speed = 4000000;
  } else if (buff[0] == 2) {
    spi_speed = 2000000;
  } else if (buff[0] == 3) {
    spi_speed = 1000000;
  } else {
    spi_speed = 8000000;
  }

  SPI.begin();
  SPI.beginTransaction(SPISettings(spi_speed, MSBFIRST, SPI_MODE0));
  pinMode(ISP_RST, OUTPUT);

  Serial.write(FUNC_SPI_INIT); //Подтверждаем команду
  Serial.flush();
}

void spi_cmd_deinit() {
  SPI.endTransaction();
  SPI.end();
  pinMode(ISP_RST, INPUT);
  
  Serial.write(FUNC_SPI_DEINIT); //Подтверждаем команду
  Serial.flush();
}

void spi_cmd_read() {
  int bytesread;
  int prog_nbytes;
  byte spi_cs_hi;

  //Получаем остальные данные
  bytesread = Serial.readBytes(buff, 3);
  if (bytesread < 3) {
    Serial.write(ERROR_RECV); //Ошибка
    Serial.flush();
    return;
  }

  digitalWrite(ISP_RST, LOW);

  spi_cs_hi = buff[0];

  prog_nbytes = buff[1];
  prog_nbytes = prog_nbytes << 8;
  prog_nbytes = prog_nbytes | buff[2];

  Serial.write(FUNC_SPI_READ); //Подтверждаем команду
  Serial.flush();

  //Работаем с SPI
  while (prog_nbytes > 0) {
    if (prog_nbytes >= rchunk) {
      SPI.transfer(buff, rchunk);
      prog_nbytes = prog_nbytes - Serial.write(buff, rchunk);
    } else {
      SPI.transfer(buff, prog_nbytes);
      prog_nbytes = prog_nbytes - Serial.write(buff, prog_nbytes);
    }

    Serial.flush();

    bytesread = Serial.readBytes(buff, 1);
      if ((bytesread == 0) || (buff[0] != ACK)) {
      digitalWrite(ISP_RST, HIGH);
      return;
      }
  }

  if (spi_cs_hi) digitalWrite(ISP_RST, HIGH);

}

void spi_cmd_write() {
  int bytesread;
  int prog_nbytes;
  int len;
  byte spi_cs_hi;

  //Получаем остальные данные
  bytesread = Serial.readBytes(buff, 3);
  if (bytesread < 3) {
    Serial.write(ERROR_RECV); //Ошибка
    Serial.flush();
    return;
  }

  digitalWrite(ISP_RST, LOW);

  spi_cs_hi = buff[0];

  prog_nbytes = buff[1];
  prog_nbytes = prog_nbytes << 8;
  prog_nbytes = prog_nbytes | buff[2];
  len = prog_nbytes;

  Serial.write(FUNC_SPI_WRITE); //Подтверждаем команду
  Serial.flush();


  //Работаем с SPI
  while (prog_nbytes > 0) {
    if (prog_nbytes >= wchunk) {
      bytesread = Serial.readBytes(buff, wchunk);
      SPI.transfer(buff, wchunk);
    } else {
      bytesread = Serial.readBytes(buff, prog_nbytes);
      SPI.transfer(buff, prog_nbytes);
    }
    
    if (bytesread == 0) {
      digitalWrite(ISP_RST, HIGH);
      return;
    }
    
    prog_nbytes = prog_nbytes - bytesread;

    Serial.write(ACK);
    Serial.flush();
  }

  if (spi_cs_hi) digitalWrite(ISP_RST, HIGH);
}
