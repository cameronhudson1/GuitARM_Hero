      TTL Low Power Timer Driver
;**********************************************************************
;Implements a driver for the LPTMR0 (Low Power Timer) to make it run 
; the function tick() in SpaceGame.c every millisecond.
;In order for this to function properly, the MCGIRCLK must be set up
; to use the fast internal reference clock (See KL46 Sub-Family 
; Reference Manual, Rev 3 page 386) and the fast internal reference
; clock should run at 4 MHz.
;Name:  Koen Komeya 
;Date:  November 21, 2017~
;----------------------------------------------------------------------
;Keil Template for KL46 Assembly with Keil C startup
;R. W. Melton
;November 13, 2017
;**********************************************************************
;Assembler directives
            THUMB
            GBLL  MIXED_ASM_C
MIXED_ASM_C SETL  {TRUE}
            OPT   64  ;Turn on listing macro expansions
;**********************************************************************
;Include files
            GET  MKL46Z4.s     ;Included by start.s
            OPT  1   ;Turn on listing
;**********************************************************************
;EQUates
;Clock Gating Mask
; SCGC5
;  VAL->BIT
;   1 -> 0  :LPTMR: Enable clock to the Low Power Timer
; Using SIM_SCGC5_LPTMR_MASK

;LPTMR0 Interrupt Priority
; Priority of the LPTMR0. Set to lowest, since there are more important
;  things to process.
LPTMR0_PRI    EQU 3
    
;LPTMR0 Interrupt Priority Mask
; NVIC_IPRx
;  VAL->BIT
;   3 ->7-6 :LPTMR0: Priority mask for LPTMR0.
LPTMR0_PRI_MASK EQU (3 << LPTMR0_PRI_POS)
    
;LPTMR0 Interrupt Priority Set
;See above
LPTMR0_PRI_SET  EQU (LPTMR0_PRI << LPTMR0_PRI_POS)

;LPTMR0 NVIC Register Mask
; NVIC_IXXR
;  VAL->BIT
;   1 -> 28 :LPTMR0: Mask for the NVIC's IXXR registers for LPTMR0.
; Using LPTMR0_IRQ_MASK

;LPTMR0 Base and offsets
;From KL46 Sub-Family Reference Manual, Rev 3 page 601
LPTMR0_BASE EQU 0x40040000
LPTMR0_CSR_OFFSET   EQU 0x00
LPTMR0_PSR_OFFSET   EQU 0x04
LPTMR0_CMR_OFFSET   EQU 0x08
;LPTMR0_CNR_OFFSET    EQU 0x0C ;We don't use the counter

;LPTMR0 Field Masks
;From KL46 Sub-Family Reference Manual, Rev 3 page 601-604

LPTMR0_CSR_TCF_MASK     EQU 0x80
LPTMR0_CSR_TCF_SHIFT    EQU 7
LPTMR0_CSR_TCF_S2C      EQU (LPTMR0_CSR_TCF_SHIFT + 1) ;Shift to carry

;LPTMR0 Main Control Register Config
; LPTMR0_PSR
;  VAL->BIT
;   0 -> 6 :TIE: Disable Interrupts for timer
;   X ->5-3:---: Related to Pulse Counter Mode
;   0 -> 2 :TFC: Reset on Timer Compare Flag
;   0 -> 1 :TMS: Use Time Counter Mode
;   1 -> 0 :TEN: Enable the Timer
LPTMR0_CSR_P_TC_EN  EQU 0x00000001
    
;LPTMR0 Main Control Register Config + Clear Timer Compare Flag
; LPTMR0_PSR
;  VAL->BIT
;   1 -> 7 :TCF: Clear Timer Compare Flag
;   0 -> 6 :TIE: Disable Interrupts for timer
;   X ->5-3:---: Related to Pulse Counter Mode
;   0 -> 2 :TFC: Reset on Timer Compare Flag
;   0 -> 1 :TMS: Use Time Counter Mode
;   1 -> 0 :TEN: Enable the Timer
LPTMR0_CSR_P_TC_EN_CLEARTCF EQU (LPTMR0_CSR_P_TC_EN :OR: LPTMR0_CSR_TCF_MASK)

; We need to get the prescaler to run every 0.001 second.
; Therefore we need to ensure an interrupt happens every (4MHz*0.001s/2=2000)
; cycles of the MCGIRCLK. 2000 = 16 * 125
;LPTMR0 Prescaler Mask
; LPTMR0_PSR
;  VAL ->BIT
;  0011->6-3:PRESCALE: Prescale by a factor of 16
;    0 -> 2 :  PBYP  : Use Prescaler
;   00 ->1-0:  PCS   : Use MCGIRCLK (see page 93 of above ref manual)
LPTMR0_PSR_MCGIRC_PRE16     EQU 0x00000018

;LPTMR0 Compare Value
; LPTMR0_CMR
;  VAL->BIT
;  125->15-0:COMPARE: Compare Value; trigger interrupt after 125 prescaled edges
LPTMR0_CMR_COMPARE125   EQU 125

;**********************************************************************
;MACROs
;**********************************************************************
;Program
            AREA    MyCode,CODE,READONLY
; LPTMR0 Driver
            EXPORT  EnableClock  
            EXPORT  WaitForTick
;Subroutine EnableClock
; Initializes the LPTMR (Low Power Timer) for poll-based 
;  timing at 1000Hz.
; If the clock is already enabled, undefined behavior ensues.
; Inputs
;  NONE
; Outputs
;  NONE
; Modified: APSR
EnableClock  PROC {R0-R14}
            PUSH    {R0-R2}
            ;Enable Clock gating
            LDR     R0,=SIM_SCGC5
            LDR     R1,[R0]
            MOVS    R2,#SIM_SCGC5_LPTMR_MASK
            ORRS    R1,R1,R2
            STR     R1,[R0]
            ;Force fast internal reference clock
            LDR     R0,=MCG_C2
            MOVS    R1,#MCG_C2_IRCS_MASK
            LDRB    R2,[R0]
            ORRS    R2,R2,R1
            STRB    R2,[R0]
            ;config & Enable Module
            LDR     R0,=LPTMR0_BASE
            MOVS    R1,#LPTMR0_PSR_MCGIRC_PRE32
            STR     R1,[R0,#LPTMR0_PSR_OFFSET]
            LDR     R1,=LPTMR0_CMR_COMPARE625
            STR     R1,[R0,#LPTMR0_CMR_OFFSET]
            MOVS    R1,#LPTMR0_CSR_P_TC_EN
            STR     R1,[R0,#LPTMR0_CSR_OFFSET]
            POP     {R0-R2}
            BX      LR
            ENDP

;Subroutine WaitForTick
; Blocks until the next tick interval.
; Inputs
;  NONE
; Outputs
;  NONE
; Modified: APSR
WaitForTick PROC {R0-R14}
            PUSH    {R0-R1}
            LDR     R0,=LPTMR0_BASE
W4T_PollLoop ;Wait for TCF to be set. (That signals a tick interval has passed)
            LDR     R1,[R0,#LPTMR0_CSR_OFFSET]
            LSRS    R1,R1,#LPTMR0_CSR_TCF_S2C
            BCC     W4T_PollLoop
            ;Clear TCF flag
            MOVS    R1,#LPTMR0_CSR_P_TC_EN_CLEARTCF
            STR     R1,[R0,#LPTMR0_CSR_OFFSET]
            POP     {R0-R1}
            BX      LR
            ENDP

;**********************************************************************
;Constants
            AREA    MyConst,DATA,READONLY
;**********************************************************************
;Variables
            AREA    MyData,DATA,READWRITE
            END
