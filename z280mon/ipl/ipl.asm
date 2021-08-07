;------------------------------------------------------------------------------
; ipl.asm
;  Initial Program Loader
;
;  Copyright (c) 2021 4sun5bu
;------------------------------------------------------------------------------

	.z280p

IPLADDR	.equ 0x2000

IOPAGE	.equ 0x08	; I/O Page Register 

MMUMCTL	.equ 0xf0	; MMU Master Control Regiser
MMUPDR	.equ 0xf1	; MMU Page Discrepter Register
MMUDSP	.equ 0xf5	; MMU Discrepter Select Port
MMUBMP	.equ 0xf4	; MMU Block Move Port

UARTCNF	.equ 0x10	; UART Config Register
UARTTCS	.equ 0x12	; UART Transmiter Control/Status Register
UARTRCS	.equ 0x14	; UART Receiver Control/Status Register
UARTRD	.equ 0x16	; UART Receive Data Register
UARTTD	.equ 0x18	; UART Transmit Data Register

;------------------------------------------------------------------------------
	.area	IPL (ABS)

	.org	IPLADDR

	jr	start
iplorg:
	.dw	IPLADDR

ldaddr:
	.dw	0x8000
nsect:
	.db	4	; number of sectors

start:
	ld	hl, mesg
	call	puts
	jr	.

	; Map SRAM at the first page
	ld	l, 0xff
	ld	c, IOPAGE
	ldctl	(c), hl 
	ld	a, 0x10
	out	(MMUPDR), a
	ld	hl, pgdtbl
	ld	b, 16
	ld	c, MMUBMP
	otirw
	ld	hl, 0b0011101111100000
	ld	c, MMUMCTL
	out	(c), hl
	
	; Disk read
	call	dskinit
	ldw	(lball), 0x0000
	ldw	(lbahl), 0x0000
	ld	hl, (ldaddr)
1$:	
	call	dskread
	ld	a, '.
	call	putc
	incw	(lball)
	ld	a, (nsect)
	dec	a
	ld	(nsect), a
	jr	nz, 1$
2$:	
	ret
	jr	2$
	jp	(ldaddr)

putc:
	push	hl
	push	bc
	ld	b, a
	ld	l, 0x0fe
	ld	c, IOPAGE
	ldctl	(c), hl
putc1:
	in	a, (UARTTCS)
	and	a, 0x01
	jr	z, putc1
	ld	a, b
	out     (UARTTD), a
	pop	bc
	pop	hl
	ret

puts:
	ld	a, (hl)
	or	a, a
	ret	z
	call	putc
	inc 	hl
	jr	puts

mesg:
	.db	0x0d
	.ascii	"Loading CP/M "
	.db 	0x00

pgdtbl:
	.dw	0x100a
	.dw	0x101a
	.dw	0x102a
	.dw	0x103a
	.dw	0x104a
	.dw	0x105a
	.dw	0x106a
	.dw	0x107a
	.dw	0x108a
	.dw	0x109a
	.dw	0x10aa
	.dw	0x10ba
	.dw	0x10ca
	.dw	0x10da
	.dw	0x10ea
	.dw	0x10fa
