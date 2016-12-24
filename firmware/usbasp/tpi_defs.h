/**
 * \brief Internal defs for tpi
 * \file tpi_defs.h
 * \author S³awomir Fraœ
 */
#ifndef __TPI_DEFS_H__
#define __TPI_DEFS_H__

/* TPI instructions */
#define TPI_OP_SLD      0x20
#define TPI_OP_SLD_INC  0x24
#define TPI_OP_SST      0x60
#define TPI_OP_SST_INC  0x64
#define TPI_OP_SSTPR(a) (0x68 | (a))
#define TPI_OP_SIN(a)   (0x10 | (((a)<<1)&0x60) | ((a)&0x0F) )
#define TPI_OP_SOUT(a)  (0x90 | (((a)<<1)&0x60) | ((a)&0x0F) )
#define TPI_OP_SLDCS(a) (0x80 | ((a)&0x0F) )
#define TPI_OP_SSTCS(a) (0xC0 | ((a)&0x0F) )
#define TPI_OP_SKEY     0xE0

/* TPI control/status registers */
#define TPIIR  0xF
#define TPIPCR 0x2
#define TPISR  0x0

// TPIPCR bits
#define TPIPCR_GT_2    0x04
#define TPIPCR_GT_1    0x02
#define TPIPCR_GT_0    0x01
#define TPIPCR_GT_128b 0x00
#define TPIPCR_GT_64b  0x01
#define TPIPCR_GT_32b  0x02
#define TPIPCR_GT_16b  0x03
#define TPIPCR_GT_8b   0x04
#define TPIPCR_GT_4b   0x05
#define TPIPCR_GT_2b   0x06
#define TPIPCR_GT_0b   0x07

// TPISR bits
#define TPISR_NVMEN    0x02

/* NVM registers */
#define NVMCSR         0x32
#define NVMCMD         0x33

// NVMCSR bits
#define NVMCSR_BSY     0x80

// NVMCMD values
#define NVMCMD_NOP           0x00
#define NVMCMD_CHIP_ERASE    0x10
#define NVMCMD_SECTION_ERASE 0x14
#define NVMCMD_WORD_WRITE    0x1D





#endif /*__TPI_DEFS_H__*/
