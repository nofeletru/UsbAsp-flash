/**
 * \brief Header for tpi
 * \file tpi.h
 * \author S³awomir Fraœ
 */
#ifndef __TPI_H__
#define __TPI_H__
#include <stdint.h>


/* Globals */
/** Number of iterations in tpi_delay loop */
extern uint16_t tpi_dly_cnt;


/* Functions */
/**
 * TPI init
 */
void tpi_init(void);
/**
 * Send raw byte by TPI
 * \param b Byte to send
 */
void tpi_send_byte(uint8_t b);
/**
 * Receive one raw byte from TPI
 * \return Received byte
 */
uint8_t tpi_recv_byte(void);
/**
 * Read block
 * \param addr Address of block
 * \param dptr Pointer to dest memory block
 * \param len Length of read
 */
void tpi_read_block(uint16_t addr, uint8_t* dptr, uint8_t len);
/**
 * Write block
 * \param addr Address to program
 * \param sptr Pointer to source block
 * \param len Length of write
 */
void tpi_write_block(uint16_t addr, const uint8_t* sptr, uint8_t len);


#endif /*__TPI_H__*/
