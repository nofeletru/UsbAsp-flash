#include <arduino.h>
#include "commands.h"

#define UART_SPEED 1000000 

int CMD;

void setup() {
  Serial.begin(UART_SPEED);
  Serial.setTimeout(1000);
}

void loop() {
  if (Serial.available() > 0) {
    CMD = Serial.read();
    ParseCommand(CMD);
  }
}
