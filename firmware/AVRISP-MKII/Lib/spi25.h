
#include <LUFA/Drivers/USB/USB.h>
#include "ISP/ISPProtocol.h"

#define  CMD_ENTER_PROGMODE_SPI25      0x30
#define  CMD_LEAVE_PROGMODE_SPI25      0x31

#define  CMD_SPI25_READ			       0x32
#define  CMD_SPI25_WRITE			   0x33

#define  CMD_FIRMWARE_VER			   0x34

#define  FIRMWARE_VER				   0xEE

void give_firmware_ver(void);
void SPI_Set_CS(uint8_t line_level);
void SPI_Enter25Mode(void);
void SPI_Leave25Mode(void);
void SPI_25Read(void);
void SPI_25Write(void);