/*
 * clock.c - part of USBasp
 *
 * Autor..........: Thomas Fischl <tfischl@gmx.de>
 * Description....: Provides functions for timing/waiting
 * Licence........: GNU GPL v2 (see Readme.txt)
 * Creation Date..: 2005-02-23
 * Last change....: 2005-04-20
 */

#include <inttypes.h>
#include <avr/io.h>
#include "clock.h"

/* wait time * 320 us */
void clockWait(uint8_t time) {

	uint8_t i;
	for (i = 0; i < time; i++) {
		uint8_t starttime = TIMERVALUE;
		while ((uint8_t) (TIMERVALUE - starttime) < CLOCK_T_320us) {
		}
	}
}
