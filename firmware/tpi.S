/**
 * \brief Size-optimized code for TPI
 * \file tpi.s
 * \author S³awomir Fraœ
 */
#include <avr/io.h>
#include "tpi_defs.h"


#define TPI_CLK_PORT PORTB
#define TPI_CLK_DDR DDRB
#define TPI_CLK_BIT 5
#define TPI_DATAOUT_PORT PORTB
#define TPI_DATAOUT_DDR DDRB
#define TPI_DATAOUT_BIT 3
#ifdef TPI_WITH_OPTO
#	define TPI_DATAIN_PIN PINB
#	define TPI_DATAIN_DDR DDRB
#	define TPI_DATAIN_BIT 4
#else
#	define TPI_DATAIN_PIN PINB
#	define TPI_DATAIN_BIT 3
#endif

.comm tpi_dly_cnt, 2


/**
 * TPI init
 */
.global tpi_init
tpi_init:
	/* CLK <= out */
	sbi _SFR_IO_ADDR(TPI_CLK_DDR), TPI_CLK_BIT
#ifdef TPI_WITH_OPTO
	/* DATAIN <= pull-up */
	cbi _SFR_IO_ADDR(TPI_DATAIN_DDR), TPI_DATAIN_BIT
	sbi _SFR_IO_ADDR(TPI_DATAIN_PORT), TPI_DATAIN_BIT
	/* DATAOUT <= high */
	sbi _SFR_IO_ADDR(TPI_DATAOUT_DDR), TPI_DATAOUT_BIT
	sbi _SFR_IO_ADDR(TPI_DATAOUT_PORT), TPI_DATAOUT_BIT
#else
	/* DATA <= pull-up */
	cbi _SFR_IO_ADDR(TPI_DATAOUT_DDR), TPI_DATAOUT_BIT
	sbi _SFR_IO_ADDR(TPI_DATAOUT_PORT), TPI_DATAOUT_BIT
#endif

	/* 32 bits */
	ldi r21, 32
1:
		rcall tpi_bit_h
	dec r21
	brne 1b

	ret


/**
 * Update PR
 * in: r25:r24 <= PR
 * lost: r18-r21,r24,r30-r31
 */
tpi_pr_update:
	movw r20, r24
	ldi r24, TPI_OP_SSTPR(0)
	rcall tpi_send_byte
	mov r24, r20
	rcall tpi_send_byte
	ldi r24, TPI_OP_SSTPR(1)
	rcall tpi_send_byte
	mov r24, r21
//	rjmp tpi_send_byte


/**
 * Send one byte
 * in: r24 <= byte
 * lost: r18-r19,r30-r31
 */
.global tpi_send_byte
tpi_send_byte:
	/* start bit */
	rcall tpi_bit_l
	/* 8 data bits */
	ldi r18, 8
	ldi r19, 0
1:
		// parity
		eor r19, r24
		// get bit, shift
		bst r24, 0
		lsr r24
		// send
		rcall tpi_bit
	dec r18
	brne 1b
	/* parity bit */
	bst r19, 0
	rcall tpi_bit
	/* 2 stop bits */
	rcall tpi_bit_h
//	rjmp tpi_bit_h


/**
 * Exchange of one bit
 * in: T <= bit_in
 * out: T => bit_out
 * lost: r30-r31
 */
tpi_bit_h:
	set
tpi_bit:
	/* TPIDATA = T */
#ifdef TPI_WITH_OPTO
	// DATAOUT = high (opto should allow TPIDATA to be pulled low by external device)
	// if(T == 0)
	//   DATAOUT = low
	sbi _SFR_IO_ADDR(TPI_DATAOUT_PORT), TPI_DATAOUT_BIT
	brts 1f
tpi_bit_l:
		cbi _SFR_IO_ADDR(TPI_DATAOUT_PORT), TPI_DATAOUT_BIT
1:
#else
	// DATAOUT = pull-up
	// if(T == 0)
	//   DATAOUT = low
	cbi _SFR_IO_ADDR(TPI_DATAOUT_DDR), TPI_DATAOUT_BIT
	sbi _SFR_IO_ADDR(TPI_DATAOUT_PORT), TPI_DATAOUT_BIT
	brts 1f
tpi_bit_l:
		cbi _SFR_IO_ADDR(TPI_DATAOUT_PORT), TPI_DATAOUT_BIT
		sbi _SFR_IO_ADDR(TPI_DATAOUT_DDR), TPI_DATAOUT_BIT
1:
#endif
	/* delay(); */
	lds r30, tpi_dly_cnt
	lds r31, tpi_dly_cnt+1
1:
		sbiw r30, 1
	brsh 1b
	/* TPICLK = 1 */
	sbi _SFR_IO_ADDR(TPI_CLK_PORT), TPI_CLK_BIT
	/* T = TPIDATA */
	in r30, _SFR_IO_ADDR(TPI_DATAIN_PIN)
	bst r30, TPI_DATAIN_BIT
	/* delay(); */
	lds r30, tpi_dly_cnt
	lds r31, tpi_dly_cnt+1
1:
		sbiw r30, 1
	brsh 1b

	/* TPICLK = 0 */
	cbi _SFR_IO_ADDR(TPI_CLK_PORT), TPI_CLK_BIT
	ret


/**
 * Receive one byte
 * out: r24 => byte
 * lost: r18-r19,r30-r31
 */
.global tpi_recv_byte
tpi_recv_byte:
	/* waitfor(start_bit, 192); */
	ldi r18, 192
1:
		rcall tpi_bit_h
		brtc .tpi_recv_found_start
	dec r18
	brne 1b
	/* no start bit: set return value */
.tpi_break_ret0:
	ldi r24, 0
	/* send 2 breaks (24++ bits) */
	ldi r18, 26
1:
		rcall tpi_bit_l
	dec r18
	brne 1b
	/* send hi */
	rjmp tpi_bit_h
	
// ----
.tpi_recv_found_start:
	/* recv 8bits(+calc.parity) */
	ldi r18, 8
	ldi r19, 0
1:
		rcall tpi_bit_h
		lsr r24
		bld r24, 7
		eor r19, r24
	dec r18
	brne 1b
	/* recv parity */
	rcall tpi_bit_h
	bld r18, 7
	eor r19, r18
	brmi .tpi_break_ret0
	/* recv stop bits */
	rcall tpi_bit_h
	rjmp tpi_bit_h


/**
 * Read Block
 */
.global tpi_read_block
tpi_read_block:
	// X <= dptr
	movw XL, r22
	// r23 <= len
	mov r23, r20
	/* set PR */
	rcall tpi_pr_update
	/* read data */	
.tpi_read_loop:
		ldi r24, TPI_OP_SLD_INC
		rcall tpi_send_byte
		rcall tpi_recv_byte
		st X+, r24
	dec r23
	brne .tpi_read_loop
	ret


/**
 * Write block
 */
.global tpi_write_block
tpi_write_block:
	// X <= sptr
	movw XL, r22
	// r23 <= len
	mov r23, r20
	/* set PR */
	rcall tpi_pr_update
	/* write data */
.tpi_write_loop:
		ldi r24, TPI_OP_SOUT(NVMCMD)
		rcall tpi_send_byte
		ldi r24, NVMCMD_WORD_WRITE
		rcall tpi_send_byte
		ldi r24, TPI_OP_SST_INC
		rcall tpi_send_byte
		ld r24, X+
		rcall tpi_send_byte
.tpi_nvmbsy_wait:
			ldi r24, TPI_OP_SIN(NVMCSR)
			rcall tpi_send_byte
			rcall tpi_recv_byte
			andi r24, NVMCSR_BSY
		brne .tpi_nvmbsy_wait
	dec r23
	brne .tpi_write_loop
	ret
