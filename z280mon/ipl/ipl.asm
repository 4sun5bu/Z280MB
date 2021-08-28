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
	.area	IPL 

	jr	start

iplorg:
	.dw	IPLADDR

ldaddr:
	.dw	0xdc00		; load address
entry:
	.dw	0xf200		; entry address
nsect:
	.db	16		; number of sectors to read

start:
	ld	sp, stkbtm

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
	
	ld	hl, mesg
	call	puts
	
	; Disk read
	call	dskinit
	ldw	(lball), 0x0002
	ldw	(lbahl), 0x0000
	ld	hl, (ldaddr)
1$:	
	push	hl
	call	dskread
	pop	hl
	ld	b, 256
	xor	a, a
2$:
	add	a, (hl)
	inc	hl
	add	a, (hl)
	inc	hl
	djnz	2$
	ld	e, a
	call	puthex8
	ld	a, ',
	call	putc
	incw	(lball)
	ld	a, (nsect)
	dec	a
	ld	(nsect), a
	jr	nz, 1$
	ld	a, 0x0d
	call	putc
	ld	a, 0x0a
	call	putc
	ld	hl, (entry)
	jp	(hl)

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

puthex4:
	and	a, 0x0f
	add	a, '0
	cp	a, '0 + 10
	jr	c, putc
	add	a, 'A - '0 - 10
	jr	putc

puthex8:
	push	de
	srl	e
	srl	e
	srl	e
	srl	e
	ld	a, e
	call	puthex4
	pop	de
	ld	a, e
	jr	puthex4

puthex16:
	push	de
	ld	e, d
	call	puthex8
	pop	de
	jr	puthex8


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

	.ds	128
stkbtm:
