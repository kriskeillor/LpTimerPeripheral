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

                /* Clocking                     */
                .equ SIMSCG5, 0x40048038
                .equ SIMSCG5_MASK, 0b1110000000001  // Setting bit 0 enables the LpTmr

                /* Utility Consts               */
                .equ BIT1, 0b1
                .equ ZERO, 0b0

                /* Low Power Timer (LpTmr)      */
                .equ LPTMR0_PSR, 0x40040004         // LpTmr Pre-Scale Register address
                .equ LPTMR_MASK, 0b111011           // Selects prescaler of 256 & "prescaler/glitch
                                                    // filter clock" to clk 3 (aka OSCERCLK_UNDIV)
                .equ LPTMR0_CSR, 0x40040000         // LpTmr Control Status Register address
                .equ LPTMR0_TCF_BIT, 0b10000000         // LpTmr Timer Compare Flag bit position (in CSR)
                .equ LPTMR0_CMR, 0x40040008         // LpTmr Compare Register address
                .equ DECISECOND, 3125               // One-tenth of a second (at 31.25 kHz)

                /* LpTmr test - toggle registers for diodes */
                .equ GPIOB_PTOR, 0x400FF04C

                /* Pin Control Registers        */
                .equ PCR_MASK, 0b100000011

                .equ PORTC_GPCLR, 0x4004B080
                .equ PORTC_PINS_LO, 0b1111111100

                .equ PORTD_GPCLR, 0x4004C080
                .equ PORTD_PINS_LO, 0b11100

                .equ PORTB_GPCLR, 0x4004A080
                .equ PORTB_PINS_LO, 0b11
                .equ PORTB_GPCHR, 0x4004A084
                .equ PORTB_PINS_HI, 0b1101

                /* GPIO Data Direction          */
                .equ GPIOD_PDDR, 0x400FF0D4
                .equ GPIOD_PDDR_MASK, 0x1C
                .equ GPIOB_PDDR, 0x400FF054
                .equ GPIOB_PDDR_MASK, 0xd0003

                /* GPIO I/O Registers           */
                .equ GPIOC_PDIR, 0x400FF090
                .equ GPIOD_PDOR, 0x400FF0C0
                .equ GPIOB_PDOR, 0x400FF040

                .globl main                     // export main for visibility
                .section .text

main:           bl K22FRDM_BootClock            // initialize the clock @20.9Mhz
                bl ClkInit
                bl IOShieldInit
                /* LpTmr test - Set Compare*/
                ldr r0, =LPTMR0_CMR
                ldr r1, [r0]
                orr r1, #DECISECOND<<4
                str r1, [r0]
                /* LpTmr test - Enable */
                ldr r0, =LPTMR0_CSR
                ldr r1, [r0]
                ldr r2, =BIT1
                orr r1, r2
                str r1, [r0]

LpTmrTest:      ldr r0, =LPTMR0_CSR
                ldr r1, [r0]
                ldr r2, =LPTMR0_TCF_BIT
                and r1, r2
                cbnz r1, LpTmrTestTog
                b LpTmrTest

LpTmrTestTog:   ldr r2, =GPIOB_PTOR
                ldr r3, =0b11
                str r3, [r2]                    // !!! magic numbers !!!
                ldr r0, =LPTMR0_CSR
                ldr r1, =ZERO
                str r1, [r0]
                ldr r1, =BIT1
                str r1, [r0]
                b LpTmrTest

/* Enables port clocking and LpTmr.
 * Params:  None.
 * Returns: None.
 * Dependencies: K22.                           */
ClkInit:        push {lr}
                /* Enable clocking on Ports C/D/B */
                ldr r0, =SIMSCG5
                ldr r1, [r0]
                orr r1, #SIMSCG5_MASK
                str r1, [r0]
                /* Set Low Power Timer prescale & source clk */
                ldr r0, =LPTMR0_PSR
                ldr r1, [r0]
                orr r1, #LPTMR_MASK
                str r1, [r0]
                pop {pc}

/* Initialize Diode & Switch GPIO ports.
 * Params:  None.                               *
 * Returns: None.                               *
 * Dependencies: K22.                           */
IOShieldInit:   push {lr}
                /* PCR                          */
                ldr r2, =PCR_MASK
                /* Port C                       */
                ldr r0, =PORTC_GPCLR
                ldr r1, =PORTC_PINS_LO
                lsl r1, #16
                orr r1, r2
                str r1, [r0]
                /* Port D                       */
                ldr r0, =PORTD_GPCLR
                ldr r1, =PORTD_PINS_LO
                lsl r1, #16
                orr r1, r2
                str r1, [r0]
                /* Port B                       */
                ldr r0, =PORTB_GPCLR
                ldr r1, =PORTB_PINS_LO
                lsl r1, #16
                orr r1, r2
                str r1, [r0]
                ldr r0, =PORTB_GPCHR
                ldr r1, =PORTB_PINS_HI
                lsl r1, #16
                orr r1, r2
                str r1, [r0]
                /* DDR                          */
                /* Port D                       */
                ldr r0, =GPIOD_PDDR
                ldr r2, =GPIOD_PDDR_MASK
                ldr r1, [r0]
                orr r1, r2
                str r1, [r0]
                /* Port B                       */
                ldr r0, =GPIOB_PDDR
                ldr r2, =GPIOB_PDDR_MASK
                ldr r1, [r0]
                orr r1, r2
                str r1, [r0]
                pop {pc}

/* place defined constants here */

.section .bss
/* place RAM variables here */
