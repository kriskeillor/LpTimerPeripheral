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
                .equ ZERO, 0b0
                .equ BIT0, 0b1
                .equ LOW_NYB, 0xf
                .equ BYTE, 0xff

                /* Low Power Timer (LpTmr)      */
                .equ LPTMR0_PSR, 0x40040004         // LpTmr Pre-Scale Register address
                .equ LPTMR_MASK, 0b111011           // Selects prescaler of 256 & "prescaler/glitch
                                                    // filter clock" to clk 3 (aka OSCERCLK_UNDIV)
                .equ LPTMR0_CSR, 0x40040000         // LpTmr Control Status Register address
                .equ LPTMR0_TCF_BIT, 0b10000000     // LpTmr Timer Compare Flag bit position (in CSR)
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

                ldr r8, =ZERO                   // set LastFreq = 0 to force update on 1st lp
                ldr r7, =SegLedTable            // load display '0' code
                b Write7Seg                     // write '0' to display

                /* Read sw data & write new LpTmrCmr if updated */
SwRead:         ldr r0, =GPIOC_PDIR
                ldr r0, [r0]
                lsr r0, #2
                mvn r0, r0                      // negate active low switches
                and r0, #LOW_NYB
                add r0, #1                      // add 0.1 Hz base freq
                cmp r0, r8                      // compare SwFreq to LastFreq
                beq MainLp
                mov r8, r0                      // store LastFreq
                /* Disable LpTmr to make changes */
                ldr r3, =LPTMR0_CSR
                ldr r4, [r3]
                ldr r5, =ZERO
                and r4, r5
                str r4, [r3]
                /* Set LpTmr Compare value*/
                ldr r2, =DECISECOND
                mul r0, r2
                ldr r1, =LPTMR0_CMR             // Write Compare Value
                str r0, [r1]
                /* Re-enable LpTmr              */
                ldr r1, [r3]
                ldr r2, =BIT0
                orr r1, r2
                str r1, [r3]

                /* Poll LpTmr until TCF set, then update display */
MainLp:         ldr r0, =LPTMR0_CSR
                ldr r1, [r0]
                ldr r2, =LPTMR0_TCF_BIT
                and r1, r2
                cbnz r1, ClearTCF               // Clear timer and fall through to Write7Seg
                b MainLp

ClearTCF:       ldr r1, =BIT0                   // Load timer en
                orr r2, r1                      // Or en & flag clear
                str r2, [r0]

Write7Seg:      ldrb r0, [r7], #1
                mvn r0, r0
                bl LEDWrite
                ldr r0, =EndSegLedTable
                add r0, #1                      // offset to past end of table
                cmp r0, r7
                it eq                           // Are we past '9'?
                ldreq r7, =SegLedTable          // If so, load '0'.
                b SwRead

/* Activates 7SEG display corresponding to LBits control byte.
 * Params:  int8u LBits via R0.
 * Returns: none.
 * Dependencies: K22.                           */
LEDWrite:       push {lr}
                /* Write output to Port D       */
                ldr r3, =GPIOD_PDOR
                ldr r2, [r3]
                bfi r2, r0, 2, 3                // Pins 2-4
                str r2, [r3]
                /* Write output to Port B       */
                ldr r3, =GPIOB_PDOR
                ldr r2, [r3]
                lsr r0, 3
                bfi r2, r0, 0, 2                // Pins 0-1
                lsr r0, 2
                bfi r2, r0, 16, 1               // Pin 16
                lsr r0, 1
                bfi r2, r0, 18, 2               // Pins 18-19
                str r2, [r3]
                pop {pc}

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

/* Stores BCD->7Seg control codes.              */
SegLedTable:    .byte 0b00111111                // Display '0
                .byte 0b00000110                // Display '1
                .byte 0b01011011                // Display '2
                .byte 0b01001111                // Display '3
                .byte 0b01100110                // Display '4
                .byte 0b01101101                // Display '5
                .byte 0b01111101                // Display '6
                .byte 0b00000111                // Display '7
                .byte 0b01111111                // Display '8
EndSegLedTable: .byte 0b01101111                // Display '9

.section .bss
/* place RAM variables here */
