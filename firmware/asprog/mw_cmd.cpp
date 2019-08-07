#include <arduino.h>
#include "mw_cmd.h"
#include "microwire.h"
#include "commands.h"
#include "defines.h"

extern byte buff[256];

void mw_cmd_init() {

  Serial.write(FUNC_MW_INIT); //Подтверждаем команду
  Serial.flush();

  mwInitPins();
}

void mw_cmd_deinit() {

  Serial.write(FUNC_MW_DEINIT); 
  Serial.flush();
  
  mwDeinitPins();
}

void mw_cmd_busy() {

  Serial.write(FUNC_MW_BUSY); 
  Serial.write(mwBusy());
  Serial.flush();     
}

void mw_cmd_read() {
  int bytesread;
  int prog_nbytes;
  byte mw_cs_lo;

  //Получаем остальные данные
  bytesread = Serial.readBytes(buff, 3);
  if (bytesread < 3) {
    Serial.write(ERROR_RECV); //Ошибка
    Serial.flush();
    return;
  }

  mw_cs_lo = buff[0];

  prog_nbytes = buff[1];
  prog_nbytes = prog_nbytes << 8;
  prog_nbytes = prog_nbytes | buff[2];

  Serial.write(FUNC_MW_READ); //Подтверждаем команду
  Serial.flush();

  //Работаем с MW
  while (prog_nbytes > 0) {
    if (prog_nbytes >= rchunk) {
      for(int i=0; i < rchunk; i++) {
        buff[i] = mwReadByte();
      }
      prog_nbytes = prog_nbytes - Serial.write(buff, rchunk);
    } else {
      for(int i=0; i < prog_nbytes; i++) {
        buff[i] = mwReadByte();
      }
      prog_nbytes = prog_nbytes - Serial.write(buff, prog_nbytes);
    }

    Serial.flush();

    bytesread = Serial.readBytes(buff, 1);
      if ((bytesread == 0) || (buff[0] != ACK)) {
      mwDeinitPins();
      return;
      }
  }

  if (mw_cs_lo) mwEnd();
}

void mw_cmd_write() {
  int bytesread;
  int prog_nbytes;
  byte mw_cs_lo;
  byte mw_bitnum;

  //Получаем остальные данные
  bytesread = Serial.readBytes(buff, 4);
  if (bytesread < 4) {
    Serial.write(ERROR_RECV); //Ошибка
    Serial.flush();
    return;
  }

  digitalWrite(ISP_RST, HIGH);

  mw_cs_lo = buff[0];
  mw_bitnum = buff[1];

  prog_nbytes = buff[2];
  prog_nbytes = prog_nbytes << 8;
  prog_nbytes = prog_nbytes | buff[3];

  Serial.write(FUNC_MW_WRITE); //Подтверждаем команду
  Serial.flush();

  //Работаем с MW (максимум 32 байта за раз)
  while (prog_nbytes > 0) {
    bytesread = Serial.readBytes(buff, prog_nbytes);
    for(int i=0; i < prog_nbytes; i++) {
      
      if(mw_bitnum > 0){
        if(mw_bitnum < 8)
        {
          mwSendData(buff[i], mw_bitnum);
          mw_bitnum = 0;
        }
        else
        { 
          mwSendData(buff[i], 8);
          mw_bitnum -= 8; 
        }
        
    }
  } 
    
    if (bytesread == 0) {
      mwDeinitPins();
      return;
    }
    
    prog_nbytes = prog_nbytes - bytesread;

    Serial.write(ACK);
    Serial.flush();
  }

  if (mw_cs_lo) mwEnd();
  
}
