/******************************************************************************
 * Kris Keillor
 * Lab 5 Timer Peripheral
 * Prof. Sandelin
 * EE 220
 * Based on Proj5Template
******************************************************************************/
                .syntax unified        /* define Syntax */
                .cpu cortex-m4
                .fpu fpv4-sp-d16

                .globl main            /* make main() global so outside file */
                                       /* can see it. Required for startup   */
                .section .text         /* the following is program code      */

main:           bl K22FRDM_BootClock // initialize the clock @20.9Mhz
                b main


/* place defined constants here */

.section .bss
/* place RAM variables here */
