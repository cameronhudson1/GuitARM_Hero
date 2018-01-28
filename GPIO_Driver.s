            TTL Program Title for Listing Header Goes Here
;****************************************************************
;Descriptive comment header goes here.
;(What does the program do?)
;Name:  <Your name here>
;Date:  <Date completed here>
;Class:  CMPE-250
;Section:  <Your lab section, day, and time here>
;---------------------------------------------------------------
;Keil Template for KL46 Assembly with Keil C startup
;R. W. Melton
;November 13, 2017
;****************************************************************
;Assembler directives
            THUMB
            GBLL  MIXED_ASM_C
MIXED_ASM_C SETL  {TRUE}
            OPT   64  ;Turn on listing macro expansions
;****************************************************************
;Include files
            GET  MKL46Z4.s     ;Included by start.s
            OPT  1   ;Turn on listing
;****************************************************************
;EQUates
;---------------------------------------------------------------
;NVIC_ICER
;31-00:CLRENA=masks for HW IRQ sources;
;             read:   0 = unmasked;   1 = masked
;             write:  0 = no effect;  1 = mask
;22:PIT IRQ mask
;12:UART0 IRQ mask
NVIC_ICER_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ICER_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;NVIC_ICPR
;31-00:CLRPEND=pending status for HW IRQ sources;
;             read:   0 = not pending;  1 = pending
;             write:  0 = no effect;
;                     1 = change status to not pending
;22:PIT IRQ pending status
;12:UART0 IRQ pending status
NVIC_ICPR_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ICPR_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;NVIC_IPR0-NVIC_IPR7
;2-bit priority:  00 = highest; 11 = lowest
;--PIT
PIT_IRQ_PRIORITY    EQU  0
NVIC_IPR_PIT_MASK   EQU  (3 << PIT_PRI_POS)
NVIC_IPR_PIT_PRI_0  EQU  (PIT_IRQ_PRIORITY << UART0_PRI_POS)
;--UART0
UART0_IRQ_PRIORITY    EQU  3
NVIC_IPR_UART0_MASK   EQU  (3 << UART0_PRI_POS)
NVIC_IPR_UART0_PRI_3  EQU  (UART0_IRQ_PRIORITY << UART0_PRI_POS)
;---------------------------------------------------------------
;NVIC_ISER
;31-00:SETENA=masks for HW IRQ sources;
;             read:   0 = masked;     1 = unmasked
;             write:  0 = no effect;  1 = unmask
;22:PIT IRQ mask
;12:UART0 IRQ mask
NVIC_ISER_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ISER_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;PIT_LDVALn:  PIT load value register n
;31-00:TSV=timer start value (period in clock cycles - 1)
;Clock ticks for 0.01 s at 24 MHz count rate
;0.01 s * 24,000,000 Hz = 240,000
;TSV = 240,000 - 1
PIT_LDVAL_10ms  EQU  239999
PIT_LDVAL_1ms	EQU		23999
;---------------------------------------------------------------
;PIT_MCR:  PIT module control register
;1-->    0:FRZ=freeze (continue'/stop in debug mode)
;0-->    1:MDIS=module disable (PIT section)
;               RTI timer not affected
;               must be enabled before any other PIT setup
PIT_MCR_EN_FRZ  EQU  PIT_MCR_FRZ_MASK
;---------------------------------------------------------------
;PIT_TCTRLn:  PIT timer control register n
;0-->   2:CHN=chain mode (enable)
;1-->   1:TIE=timer interrupt enable
;1-->   0:TEN=timer enable
PIT_TCTRL_CH_IE  EQU  (PIT_TCTRL_TEN_MASK :OR: PIT_TCTRL_TIE_MASK)
;---------------------------------------------------------------
;UART0_S2
;1-->7:LBKDIF=LIN break detect interrupt flag (clear)
;             write 1 to clear
;1-->6:RXEDGIF=RxD pin active edge interrupt flag (clear)
;              write 1 to clear
;0-->5:(reserved); read-only; always 0
;0-->4:RXINV=receive data inversion (disabled)
;0-->3:RWUID=receive wake-up idle detect
;0-->2:BR213=break character generation length (10)
;0-->1:LBKDE=LIN break detect enable (disabled)
;0-->0:RAF=receiver active flag; read-only
UART0_S2_NO_RXINV_BR210_NO_LBKDETECT_CLEAR_FLAGS  EQU  0xC0
;---------------------------------------------------------------
;PORTx_PCRn (Port x pin control register n [for pin n])
;___->10-08:Pin mux control (select 0 to 8)
;Use provided PORT_PCR_MUX_SELECT_2_MASK
;---------------------------------------------------------------
;Port A
PORT_PCR_SET_PTA1_UART0_RX  EQU  (PORT_PCR_ISF_MASK :OR: \
                                  PORT_PCR_MUX_SELECT_2_MASK)
PORT_PCR_SET_PTA2_UART0_TX  EQU  (PORT_PCR_ISF_MASK :OR: \
                                  PORT_PCR_MUX_SELECT_2_MASK)
;---------------------------------------------------------------
;SIM_SCGC4
;1->10:UART0 clock gate control (enabled)
;Use provided SIM_SCGC4_UART0_MASK
;---------------------------------------------------------------
;SIM_SCGC5
;1->09:Port A clock gate control (enabled)
;Use provided SIM_SCGC5_PORTA_MASK
;---------------------------------------------------------------
;SIM_SOPT2
;01=27-26:UART0SRC=UART0 clock source select
;         (PLLFLLSEL determines MCGFLLCLK' or MCGPLLCLK/2)
; 1=   16:PLLFLLSEL=PLL/FLL clock select (MCGPLLCLK/2)
SIM_SOPT2_UART0SRC_MCGPLLCLK  EQU  \
                                 (1 << SIM_SOPT2_UART0SRC_SHIFT)
SIM_SOPT2_UART0_MCGPLLCLK_DIV2 EQU \
    (SIM_SOPT2_UART0SRC_MCGPLLCLK :OR: SIM_SOPT2_PLLFLLSEL_MASK)
;---------------------------------------------------------------
;SIM_SOPT5
; 0->   16:UART0 open drain enable (disabled)
; 0->   02:UART0 receive data select (UART0_RX)
;00->01-00:UART0 transmit data select source (UART0_TX)
SIM_SOPT5_UART0_EXTERN_MASK_CLEAR  EQU  \
                               (SIM_SOPT5_UART0ODE_MASK :OR: \
                                SIM_SOPT5_UART0RXSRC_MASK :OR: \
                                SIM_SOPT5_UART0TXSRC_MASK)
;---------------------------------------------------------------
;UART0_BDH
;    0->  7:LIN break detect IE (disabled)
;    0->  6:RxD input active edge IE (disabled)
;    0->  5:Stop bit number select (1)
;00001->4-0:SBR[12:0] (UART0CLK / [9600 * (OSR + 1)]) 
;UART0CLK is MCGPLLCLK/2
;MCGPLLCLK is 96 MHz
;MCGPLLCLK/2 is 48 MHz
;SBR = 48 MHz / (9600 * 16) = 312.5 --> 312 = 0x138
UART0_BDH_9600  EQU  0x01
;---------------------------------------------------------------
;UART0_BDL
;26->7-0:SBR[7:0] (UART0CLK / [9600 * (OSR + 1)])
;UART0CLK is MCGPLLCLK/2
;MCGPLLCLK is 96 MHz
;MCGPLLCLK/2 is 48 MHz
;SBR = 48 MHz / (9600 * 16) = 312.5 --> 312 = 0x138
UART0_BDL_9600  EQU  0x38
;---------------------------------------------------------------
;UART0_C1
;0-->7:LOOPS=loops select (normal)
;0-->6:DOZEEN=doze enable (disabled)
;0-->5:RSRC=receiver source select (internal--no effect LOOPS=0)
;0-->4:M=9- or 8-bit mode select 
;        (1 start, 8 data [lsb first], 1 stop)
;0-->3:WAKE=receiver wakeup method select (idle)
;0-->2:IDLE=idle line type select (idle begins after start bit)
;0-->1:PE=parity enable (disabled)
;0-->0:PT=parity type (even parity--no effect PE=0)
UART0_C1_8N1  EQU  0x00
;---------------------------------------------------------------
;UART0_C2
;0-->7:TIE=transmit IE for TDRE (disabled)
;0-->6:TCIE=transmission complete IE for TC (disabled)
;0-->5:RIE=receiver IE for RDRF (disabled)
;0-->4:ILIE=idle line IE for IDLE (disabled)
;1-->3:TE=transmitter enable (enabled)
;1-->2:RE=receiver enable (enabled)
;0-->1:RWU=receiver wakeup control (normal)
;0-->0:SBK=send break (disabled, normal)
UART0_C2_T_R    EQU  (UART0_C2_TE_MASK :OR: UART0_C2_RE_MASK)
UART0_C2_T_RI   EQU  (UART0_C2_RIE_MASK :OR: UART0_C2_T_R)
UART0_C2_TI_RI  EQU  (UART0_C2_TIE_MASK :OR: UART0_C2_T_RI)
;---------------------------------------------------------------
;UART0_C3
;0-->7:R8T9=9th data bit for receiver (not used M=0)
;           10th data bit for transmitter (not used M10=0)
;0-->6:R9T8=9th data bit for transmitter (not used M=0)
;           10th data bit for receiver (not used M10=0)
;0-->5:TXDIR=UART_TX pin direction in single-wire mode
;            (no effect LOOPS=0)
;0-->4:TXINV=transmit data inversion (not inverted)
;0-->3:ORIE=overrun IE for OR (disabled)
;0-->2:NEIE=noise error IE for NF (disabled)
;0-->1:FEIE=framing error IE for FE (disabled)
;0-->0:PEIE=parity error IE for PF (disabled)
UART0_C3_NO_TXINV  EQU  0x00
;---------------------------------------------------------------
;UART0_C4
;    0-->  7:MAEN1=match address mode enable 1 (disabled)
;    0-->  6:MAEN2=match address mode enable 2 (disabled)
;    0-->  5:M10=10-bit mode select (not selected)
;01111-->4-0:OSR=over sampling ratio (16)
;               = 1 + OSR for 3 <= OSR <= 31
;               = 16 for 0 <= OSR <= 2 (invalid values)
UART0_C4_OSR_16           EQU  0x0F
UART0_C4_NO_MATCH_OSR_16  EQU  UART0_C4_OSR_16
;---------------------------------------------------------------
;UART0_C5
;  0-->  7:TDMAE=transmitter DMA enable (disabled)
;  0-->  6:Reserved; read-only; always 0
;  0-->  5:RDMAE=receiver full DMA enable (disabled)
;000-->4-2:Reserved; read-only; always 0
;  0-->  1:BOTHEDGE=both edge sampling (rising edge only)
;  0-->  0:RESYNCDIS=resynchronization disable (enabled)
UART0_C5_NO_DMA_SSR_SYNC  EQU  0x00
;---------------------------------------------------------------
;UART0_S1
;0-->7:TDRE=transmit data register empty flag; read-only
;0-->6:TC=transmission complete flag; read-only
;0-->5:RDRF=receive data register full flag; read-only
;1-->4:IDLE=idle line flag; write 1 to clear (clear)
;1-->3:OR=receiver overrun flag; write 1 to clear (clear)
;1-->2:NF=noise flag; write 1 to clear (clear)
;1-->1:FE=framing error flag; write 1 to clear (clear)
;1-->0:PF=parity error flag; write 1 to clear (clear)
UART0_S1_CLEAR_FLAGS  EQU  0x1F
;---------------------------------------------------------------
;UART0_S2
;1-->7:LBKDIF=LIN break detect interrupt flag (clear)
;             write 1 to clear
;1-->6:RXEDGIF=RxD pin active edge interrupt flag (clear)
;              write 1 to clear
;0-->5:(reserved); read-only; always 0
;0-->4:RXINV=receive data inversion (disabled)
;0-->3:RWUID=receive wake-up idle detect
;0-->2:BRK13=break character generation length (10)
;0-->1:LBKDE=LIN break detect enable (disabled)
;0-->0:RAF=receiver active flag; read-only
UART0_S2_NO_RXINV_BRK10_NO_LBKDETECT_CLEAR_FLAGS  EQU  0xC0
;--------------------------------------------------------------


;Blue LED
BLUE_LED_CHAR			EQU	'B'
BLUE_BUTT_SET_MASK		EQU	2_00000000000000010000000000000000;

;GREEN LED
GREEN_LED_CHAR			EQU	'G'
GREEN_BUTT_SET_MASK		EQU	2_00000000000000001000000000000000;
	
;Yellow LED
YELLOW_LED_CHAR			EQU	'Y'
YELLOW_BUTT_SET_MASK	EQU	2_00000000000000000100000000000000;
	
;Red LED
RED_LED_CHAR			EQU	'R'
RED_BUTT_SET_MASK		EQU	2_00000000000000000000000010000000;
	
;WHITE LED
WHITE_LED_CHAR			EQU	'W'
WHITE_BUTT_SET_MASK		EQU	2_00000000000000000000000001000000;


MAX_STRING	EQU		79			;max size of string + null termination
IN_PTR		EQU 	0			;pointer to where to enqueue
OUT_PTR		EQU 	4			;pointer to where to dequeue
BUF_STRT	EQU 	8			;start of buffer
BUF_PAST	EQU 	12			;first byte past buffer
BUF_SIZE	EQU 	16			;size of buffer
NUM_ENQD	EQU 	17			;number of elements enqueued
NIB_SHFT	EQU		4			;bits to shift to get next nibble
TXRX_BUF_SIZE	EQU		80
BUFFER_SIZE	EQU		4
carRet      EQU     0x0D
newLine     EQU     0x0A
PTA_IRQ_PRI	EQU 0x00000000	;Mask to give priority of 1 (just below PIT)

PTA_PRI_POS	EQU 0x1E		;Port A Priority position
PTA_MASK	EQU (1 << PTA_PRI_POS)	;Port A IRQ Enable mask


;pins 6 (White), 7 (Red), 14 (Yellow), 15 (Green), 16 (Blue) 
GPIOA_BUTT	EQU		2_00000000000000011100000011000000
	
;pins 7 (White), 10 (Red), 11 (Yellow), 13 (Green), 16 (Blue) 
GPIOC_LED	EQU		2_00000000000000010010110010000000	

;1001 in bits 19-16 means interrupts enabled
PORTA_PIN_INT_EN		EQU	0x01090112	;Stored to Control Register for Pin
;****************************************************************
;MACROs
;****************************************************************
;Program
;C source will contain main ()
;Only subroutines and ISRs in this assembly source
            AREA    MyCode,CODE,READONLY
			EXPORT	GetChar
			EXPORT	GetStringSB
			EXPORT	Init_UART0_IRQ
			EXPORT	PutChar
			EXPORT	PutNumHex
			EXPORT	PutNumUB
			EXPORT	PutStringSB
			EXPORT 	Init_PIT_IRQ
			EXPORT	GPIO_BopIt_Init
			EXPORT	GPIO_Write_LED
			EXPORT	GetCount
			EXPORT	ResetStopwatch
			EXPORT 	UART0_IRQHandler
			EXPORT	PIT_IRQHandler
			EXPORT 	PORTA_IRQHandler
			EXPORT	ButtChange
			EXPORT	WaitForCount
			EXPORT ButtTime
;>>>>> begin subroutine code <<<<<

;------------------------------------------------------------------------------  
;InitQueue
;FUNCTION: initializes the queue
;INPUTS: R0 - address of beginning of queue buffer; R1 - address of beginning 
;of queue record; R2 - size of queue buffer
;OUTPUTS: none
;CHANGED: none
;------------------------------------------------------------------------------
InitQueue	PROC 	{R0-R14}
			PUSH 	{R0}
			
			STR		R0,[R1,#IN_PTR]		;define the head of the queue
			STR		R0,[R1,#OUT_PTR]	;define the tail of the queue
			STR		R0,[R1,#BUF_STRT]	;define the start of the buffer
			ADDS	R0,R0,R2			;R0 = buffer start + buffer size
			STR		R0,[R1,#BUF_PAST]	;define the first byte past the buffer
			STRB 	R2,[R1,#BUF_SIZE]	;set the buffer size
			MOVS	R0,#0				;R0 = 0
			STRB	R0,[R1,#NUM_ENQD]	;initialize the number enqueued to 0
			
			POP 	{R0}
			BX 		LR
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;Dequeue
;FUNCTION: dequeues and returns the next element stored in the queue. C flag 
;if cannot dequeue
;INPUTS: R1 - address of beginning of queue record
;OUTPUTS: R0 - dequeued element; PSR C flag, success (0) or failure (1)
;CHANGED: R0, APSR
;SUBROUTINES USED: none
;------------------------------------------------------------------------------
Dequeue		PROC 	{R1-R14}
			PUSH 	{R2-R3}
			
			LDRB	R2,[R1,#NUM_ENQD]	;load R2 with number enqueued
			CMP		R2, #0				;check if current number enqueued is 0
			BEQ		emptyDQ
			LDR		R0,[R1,#OUT_PTR]	
			LDRB	R0,[R0,#0]			;get next element to be dequeued
			SUBS	R2,R2,#1			;decrement number enqueued
			STRB	R2,[R1,#NUM_ENQD]	;store new number enqueued
			LDR		R2,[R1,#OUT_PTR]	;load R2 with out pointer
			ADDS	R2,R2,#1			;increment out pointer by one byte
			LDR		R3,[R1,#BUF_PAST]	;load R3 with past buffer pointer
			CMP 	R2,R3				;check if out pointer is past buffer
			BLO		clearCDQ
			LDR		R2,[R1,#BUF_STRT]	;load new out pointer as start of buffer
			
clearCDQ	STR		R2,[R1,#OUT_PTR]	;store new out pointer
			MOVS	R2,#0x20			;load R2 with mask to clear C flag
			LSLS	R2,R2,#24			;shift mask 24 bits left
			MRS		R3,APSR				;load APSR into R3
			BICS	R3,R3,R2			;clear using mask
			MSR		APSR,R3				;store R3 in APSR
			B		endDQ
			
emptyDQ		MOVS	R2,#0x20			;load R2 with mask to set C flag
			LSLS	R2,R2,#24			;shift mask 24 bits left
			MRS		R3,APSR				;load APSR into R3
			ORRS	R3,R3,R2			;set using mask
			MSR		APSR,R3				;store R3 in APSR
			
endDQ		POP 	{R2-R3}
			BX		LR
			ENDP
;-----------------------------end subroutine-----------------------------------
;------------------------------------------------------------------------------  
;Enqueue
;FUNCTION: prompts the user for a character and enqueues it. C flag set if 
;cannot enqueue
;INPUTS: R0 - element to enqueue; R1 - address of beginning of queue record
;OUTPUTS: PSR C flag, success (0) or failure (1)
;CHANGED: APSR
;------------------------------------------------------------------------------
Enqueue		PROC 	{R0-R14}
			PUSH	{R2-R3,LR}
	
			LDRB	R2,[R1,#NUM_ENQD]	;load R2 with number enqueued
			LDRB	R3,[R1,#BUF_SIZE]	;load R3 with buffer size
			CMP 	R2,R3				;check if R2 is greater than R3
			BHS		fullNQ
			
			LDR		R3,[R1,#IN_PTR]		
			STRB	R0,[R3,#0]			;enqueue element at in pointer
			ADDS	R2,R2,#1			;increment number enqueued
			STRB	R2,[R1,#NUM_ENQD]	;store new number enqueued
			LDR		R0,[R1,#IN_PTR]		;load R0 with in pointer
			ADDS	R0,R0,#1			;increment in pointer
			LDR		R2,[R1,#BUF_PAST]	;load R2 with first byte past buffer
			CMP		R0,R2				;check if R0 is less than past buffer
			BLO		clearCNQ
			LDR		R0,[R1,#BUF_STRT]	;load R0 with buffer start pointer
			
clearCNQ	STR		R0,[R1,#IN_PTR]		;store new in pointer
			MOVS	R2,#0x20			;load R2 with mask to clear C flag
			LSLS	R2,R2,#24			;shift mask 24 bits left
			MRS		R3,APSR				;load APSR into R3
			BICS	R3,R3,R2			;clear using mask
			MSR		APSR,R3				;store R3 in APSR
			B		endNQ
			
fullNQ		MOVS	R2,#0x20			;load R2 with mask to set C flag
			LSLS	R2,R2,#24			;shift mask 24 bits left
			MRS		R3,APSR				;load APSR into R3
			ORRS	R3,R3,R2			;set using mask
			MSR		APSR,R3				;store R3 in APSR
	
endNQ		POP		{R2-R3,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;---------------------------------------------------------------
;divu
;FUNCTION: Divides two numbers and returns the quotient and remainder
;INPUTS: R0 - divisor; R1 - dividend
;OUTPUTS: R0 - quotient; R1 - remainder
;MODIFIED: R0, R1
;---------------------------------------------------------------
divu 		PROC 	{R0-R14}			
			PUSH 	{R2-R4}
			MOVS 	R2,#0				;Reset R2 to 0
			MRS 	R3,APSR				;set C flag {
			MOVS 	R4,#0x20
			LSLS 	R4,R1,#24
			ORRS 	R3,R3,R4
			MSR 	APSR,R3				;}
			CMP 	R0,#0				;if(divisor == 0)
			BEQ 	div_by_0
			
while		CMP 	R1,R0				;while(dividend >= divisor) {
			BLO 	good_div
			SUBS 	R1,R1,R0			;dividend -= divisor
			ADDS 	R2,#1				;quotient ++
			B 		while
					
good_div	MOVS 	R0,R2
			BICS 	R3,R3,R4			;Clears C flag
			MSR 	APSR,R3				;}

div_by_0	POP		{R2-R4}
			BX 		LR
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;Init_PIT_IRQ
;FUNCTION: initializes the NVIC for PIT use
;INPUTS: none
;OUTPUTS: none
;CHANGED: none
;------------------------------------------------------------------------------
Init_PIT_IRQ	PROC	{R0-R14}
			PUSH	{R0-R3,LR}
			
			LDR		R0,=SIM_SCGC6	;set SIM_SCGC6 for PIT clock enabled
			LDR		R1,=SIM_SCGC6_PIT_MASK
			LDR		R2,[R0,#0]
			ORRS	R2,R2,R1
			STR		R2,[R0,#0]
			
			LDR		R0,=PIT_CH0_BASE	;disable PIT0 timer
			LDR		R1,=PIT_TCTRL_TEN_MASK
			LDRB	R2,[R0,#PIT_TCTRL_OFFSET]
			;BICS	R1,R1,R2
			;STR	R1,[R0,#PIT_TCTRL_OFFSET]
			BICS	R2,R2,R1
			STR		R2,[R0,#PIT_TCTRL_OFFSET]
			
			
			;LDR		R0,=PIT_IPR		;set PIT interrupt priority
			;LDR		R1,=NVIC_IPR_PIT_MASK
			;LDR		R2,[R0,#0]
			;BICS	R2,R2,R1
			;STR		R2,[R0,#0]
			LDR		R0,=PIT_IPR		;set PIT interrupt priority
			LDR		R1,=NVIC_IPR_PIT_MASK
			LDR		R3,[R0,#0]
			BICS	R3,R3,R1
			STR		R3,[R0,#0]
			
			LDR		R0,=NVIC_ICPR	;clear any pending PIT interrupts
			LDR		R1,=NVIC_ICPR_PIT_MASK
			STR		R1,[R0,#0]

			LDR		R0,=NVIC_ISER	;unmask PIT interrutps
			LDR		R1,=NVIC_ISER_PIT_MASK
			STR		R1,[R0,#0]
			
			LDR		R0,=PIT_BASE	;enable PIT interrupts
			LDR		R1,=PIT_MCR_EN_FRZ
			STRB	R1,[R0,#PIT_MCR_OFFSET]
			
			;LDR		R0,=PIT_CH0_BASE	;set interrupt period
			;LDR		R1,=PIT_LDVAL_10ms
			;STR		R1,[R0,#PIT_LDVAL_OFFSET]
			LDR		R2,=PIT_CH0_BASE	;set interrupt period
			LDR		R3,=PIT_LDVAL_1ms
			STR		R3,[R2,#PIT_LDVAL_OFFSET]
			
			
			;LDR		R0,=PIT_CH0_BASE	;enable timer channel 0 for interrupts
			;MOVS	R1,#PIT_TCTRL_CH_IE
			;STRB	R1,[R0,#PIT_TCTRL_OFFSET]
			LDR		R0,=PIT_TCTRL_CH_IE
			STR	R0,[R2,#PIT_TCTRL_OFFSET]
			
			POP		{R0-R3,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------
;PIT_ISR
;FUNCTION: handles pit triggers by incrementing a counter
;INPUTS: none
;OUTPUTS: none
;CHANGED: none
;SUBROUTINES USED: none
;------------------------------------------------------------------------------
PIT_IRQHandler
PIT_ISR		PROC 	{R0-R14}
			CPSID	I
			PUSH	{R0-R3,LR}
			
			LDR		R0,=RandCount
			LDR		R1,[R0,#0]
			ADDS	R1,R1,#1
			STR		R1,[R0,#0]
			
			LDR		R0,=RunStopWatch	;get RunStopWatch variable
			LDRB	R1,[R0,#0]
			CMP		R1,#0			;exit if equals 0
			BEQ		pit_isr_end
			LDR		R2,=Count		;get count variable
			LDR		R3,[R2,#0]
			ADDS	R3,R3,#1		;increment count
			STR		R3,[R2,#0]		;store new count
			
pit_isr_end	LDR		R0,=PIT_TFLG0	;get pit flag register
			MOVS	R1,#PIT_TFLG_TIF_MASK	;get pit flag mask
			STRB	R1,[R0,#0]	;store new tflg register
			
			POP		{R0-R3,PC}
			CPSIE	I
			ENDP
;-----------------------------end ISR------------------------------------------

;------------------------------------------------------------------------------
;GetCount
;FUNCTION: get the current counter value
;INPUTS: none
;OUTPUTS: R0 - counter value
;CHANGED: R0
;SUBROUTINES USED: none
;------------------------------------------------------------------------------
GetCount	PROC 	{R0-R14}
			PUSH	{LR}
			
			LDR		R0,=Count
			LDR		R0,[R0,#0]
			
			POP		{PC}
			ENDP

;------------------------------------------------------------------------------
;GetRandCount
;FUNCTION: get the current counter value
;INPUTS: none
;OUTPUTS: R0 - counter value
;CHANGED: R0
;SUBROUTINES USED: none
;------------------------------------------------------------------------------
			EXPORT	GetRandCount
GetRandCount	PROC 	{R0-R14}
			PUSH	{LR}
			
			LDR		R0,=RandCount
			LDR		R0,[R0,#0]
			
			POP		{PC}
			ENDP
				
;------------------------------------------------------------------------------
;ResetStopwatch
;FUNCTION: reset the timer
;INPUTS: none
;OUTPUTS: none
;CHANGED: none
;SUBROUTINES USED: none
;------------------------------------------------------------------------------
ResetStopwatch	PROC	{R0-R14}
			PUSH	{R0-R1,LR}
			
			LDR		R0,=RunStopWatch
			MOVS	R1,#0
			STRB	R1,[R0,#0]
			
			LDR		R0,=Count
			CPSID	I
			STR		R1,[R0,#0]
			CPSIE	I
			
			LDR		R0,=RunStopWatch
			MOVS	R1,#1
			STRB	R1,[R0,#0]
			
			POP		{R0-R1,PC}
			ENDP
;------------------------------------------------------------------------------
;GPIO_BopIt_Init
;FUNCTION: initializes gpio pins for led output and buttons input
;INPUTS: none
;OUTPUTS: none
;CHANGED: none
;SUBROUTINES USED: none
;------------------------------------------------------------------------------
GPIO_BopIt_Init	PROC 	{R0-R14}
			PUSH	{R0-R2,LR}
			
			LDR		R0,=SIM_SCGC5
			LDR		R1,=SIM_SCGC5_PORTA_MASK :OR: SIM_SCGC5_PORTC_MASK
			LDR		R2,[R0,#0]
			ORRS	R1,R1,R2
			STR		R1,[R0,#0]
			
			;initialize GPIOA pins for buttons
			LDR		R0,=GPIOA_PDDR
			LDR 	R1,[R0,#0]
			LDR		R2,=GPIOA_BUTT
			BICS	R1,R1,R2
			STR		R1,[R0,#0]
			
			;initialize GPIOC pins for LEDs
			LDR		R0,=GPIOC_PDDR		
			LDR		R1,[R0,#0]
			LDR		R2,=GPIOC_LED
			ORRS	R1,R1,R2
			STR		R1,[R0,#0]
			
			;Set PORTA priority
			
			;Enable interrupts within the NVIC
			LDR		R0,=NVIC_BASE
			LDR		R1,=PTA_MASK
			LDR		R2,[R0,#0]
			ORRS	R2,R2,R1
			STR		R2,[R0,#0]

			;Set priority to 1
			LDR		R2,=NVIC_IPR7_OFFSET
			LDR		R1,=PTA_IRQ_PRI
			STR		R1,[R0,R2]
			
			;Initialize PORTA for interrupts
			;pins 6 (White), 7 (Red), 14 (Yellow), 15 (Green), 16 (Blue) 
			LDR		R0,=PORTA_BASE
			LDR		R2,=PORTA_PIN_INT_EN	;Mask to enable interrupts for the specified pin
			
			;Enable Interrupts for White Button
			STR		R2,[R0,#PORTA_PCR6_OFFSET]		;PortA Pin 6 Control Register (White)
			
			;Enable Interrupts for Red Button
			STR		R2,[R0,#PORTA_PCR7_OFFSET]		;PortA Pin 7 Control Register (Red)
			
			;Enable Interrupts for Yellow Button
			STR		R2,[R0,#PORTA_PCR14_OFFSET]		;PortA Pin 14 Control Register (Yellow)
			
			;Enable Interrupts for Green Button
			STR		R2,[R0,#PORTA_PCR15_OFFSET]		;PortA Pin 15 Control Register (Green)
			
			;Enable Interrupts for Blue Button
			STR		R2,[R0,#PORTA_PCR16_OFFSET]		;PortA Pin 16 Control Register (Blue)
			
			
			POP		{R0-R2,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------
;GPIO_Write_LED
;FUNCTION: initializes gpio pins for led output and buttons input
;INPUTS: R0 - mask to set an led in PORTC; R1 - boolean for set/clear 
;(true = set, false = clear)
;OUTPUTS: none
;CHANGED: none
;SUBROUTINES USED: none
;------------------------------------------------------------------------------
GPIO_Write_LED	PROC	{R0-R14}
			PUSH	{R2,LR}
			
			LDR		R2,=PORTC_BASE
			CMP		R1,#0
			BEQ		LEDSet
			STR		R0,[R2,#GPIO_PCOR_OFFSET]	;clear led (off)
			B		WriteLEDEnd
LEDSet		STR		R0,[R2,#GPIO_PSOR_OFFSET]	;set led (on)

WriteLEDEnd	POP		{R2,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------
;	PORTA_IRQHandler
;		Handles an IRQ from any Port A Pins (Containing 5 LED Buttons)
;		Checks each one to see what was clicked, updates a variable to a
;		charcter of whcih was pressed with the button's corresponding number
;		(white = 0, red = 1, yellow = 2, green = 3, blue = 4).  Clears the 
;		Interrupt and sets the input to 0.
;------------------------------------------------------------------------------
PORTA_IRQHandler  PROC	{R0-R14}
			CPSID	I
			PUSH	{LR}
			
			LDR		R0,=PORTA_BASE				;
			MOVS	R1,#PORTA_ISFR_OFFSET
			ADDS	R0,R0,R1
			LDR		R1,[R0,#0]					;R1 <- PortA Interrupt Status Flag Register
			
CheckWhite	LDR		R2,=WHITE_BUTT_SET_MASK		;R2 <- White Button Set Mask
			CMP		R1,R2						;
			BNE		CheckRed					;Branch if White Button is not set
			
			LDR		R2,=ButtTouch				;
			MOVS	R3,#0						;
			STR		R3,[R2,#0]					;White Led (0) ->ButtTouch

			;NOT WORKING
CheckRed	LDR		R2,=RED_BUTT_SET_MASK		;R2 <- White Button Set Mask
			CMP		R1,R2						;
			BNE		CheckYellow					;Branch if Red Button is not set
			
			LDR		R2,=ButtTouch				;
			MOVS	R3,#RED_LED_CHAR			;
			STR		R3,[R2,#0]					;Red Led (NONE) ->ButtTouch

CheckYellow	LDR		R2,=YELLOW_BUTT_SET_MASK	;R2 <- Yellow Button Set Mask
			CMP		R1,R2						;
			BNE		CheckGreen					;Branch if Yellow Button is not set
			
			LDR		R2,=ButtTouch				;
			MOVS	R3,#2						;
			STR		R3,[R2,#0]					;Yellow Led (2) ->ButtTouch

CheckGreen	LDR		R2,=GREEN_BUTT_SET_MASK		;R2 <- GREEN Button Set Mask
			CMP		R1,R2						;
			BNE		CheckBlue					;Branch if Green Button is not set
			
			LDR		R2,=ButtTouch				;
			MOVS	R3,#3						;
			STR		R3,[R2,#0]					;Green Led (3) ->ButtTouch

			;ACTUALLY RED BUTTON IDK WHY
CheckBlue	LDR		R2,=RED_BUTT_SET_MASK		;R2 <- Red Button Set Mask
			CMP		R1,R2						;
			BNE		NoMore						;Branch if Blue Button is not set
			
			LDR		R2,=ButtTouch				;
			MOVS	R3,#1						;
			STR		R3,[R2,#0]					;Red Led (1) ->ButtTouch

NoMore		;Clear OUTterrupts
			STR		R1,[R0,#0]					;Storing 1's to pin bit values clears them

			POP		{PC}
			CPSIE	I
			ENDP
				

;--------------------BUTT CHANGE-------------------------------------------
;ButtChange waits for a button to be pressed and returns which one was pressed
ButtChange	PROC	{R0-R14}
			PUSH	{R1-R2,LR}
			
			LDR		R0,=ButtTouch
			LDR		R1,[R0,#0]
			LDR		R2,[R0,#0]
buttPoll	CMP		R1,R2
			BNE		bPollDone
			CPSID 	I
			LDR		R1,[R0,#0]
			CPSIE	I
			B		buttPoll
bPollDone	MOVS	R0,R1

			
			POP		{R1-R2,PC}
			ENDP


			
;--------------------BUTT CHANGE-------------------------------------------
;ButtChange waits for a button to be pressed and returns which one was pressed
ButtTime	PROC	{R0-R14}
			PUSH	{R1-R3,LR}
			
			MOVS	R3,R0			;MAXTIME = R3
			LDR		R0,=ButtTouch
			LDR		R1,[R0,#0]
			LDR		R2,[R0,#0]
			
dbuttPoll	CMP		R1,R2
			BNE		dPollDone		;Button Has Changed
			LDR		R1,=Count
			LDR		R1,[R1,#0]
			CMP		R1,R3
			BHS		dTimeOut		;Count Exceeds Max Time
			CPSID 	I
			LDR		R1,[R0,#0]
			CPSIE	I
			B		dbuttPoll
			
dPollDone	MOVS	R0,R1
			B	 	dDone

dTimeOut	MOVS	R0,#6			;Passes Gas if Button not pressed in time
			
dDone		POP		{R1-R3,PC}
			ENDP

			EXPORT	ResetButt
;-----------------------RESET BUTT--------------------------------------
ResetButt	PROC	{R0-R14}
			PUSH	{R0-R1}
			
			MOVS	R0,#5
			LDR		R1,=ButtTouch
			STR		R0,[R1,#0]
			
			POP		{R0-R1}
			BX		LR
			ENDP

;-----------------------WAIT FOR COUNT-----------------------------------
WaitForCount	PROC 	{R0-R14}
			PUSH	{R1-R2,LR}
			
			LDR		R1,=Count
waitLoop	CPSID	I
			LDR		R2,[R1,#0]
			CPSIE	I
			CMP		R2,R0
			BLO		waitLoop
			
			POP		{R1-R2,PC}
			ENDP

;>>>>>   end subroutine code <<<<<
            ALIGN
;**********************************************************************
;Constants
            AREA    MyConst,DATA,READONLY
;>>>>> begin constants here <<<<<
;>>>>>   end constants here <<<<<
;**********************************************************************
;Variables
            AREA    MyData,DATA,READWRITE
			EXPORT	ButtTouch
;>>>>> begin variables here <<<<<
			ALIGN
RxQRef		SPACE 	18
			ALIGN
TxQRef		SPACE	18
			ALIGN
RxQBuffer	SPACE	TXRX_BUF_SIZE
			ALIGN
TxQBuffer	SPACE	TXRX_BUF_SIZE
			ALIGN
Count		SPACE	4
			ALIGN
RandCount	SPACE	4
			ALIGN
RunStopWatch	SPACE	1
			ALIGN
ButtTouch	SPACE	4					;Stores int of the last button pressed (WHITE = 0, RED = 1, YELLOW = 2, GREEN = 3)
			ALIGN
;>>>>>   end variables here <<<<<
            END
