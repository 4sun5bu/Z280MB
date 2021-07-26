;------------------------------------------------------------------------------
; z280mon.asm
;  Machine code monitor for Zilog Z80280
;
;  Copyright (c) 2021 4sun5bu
;------------------------------------------------------------------------------

	.z280p

MSTR	.equ 0x00	; Master Status Register
BUSTCR	.equ 0x02	; Bus Timing and Control Register
STKLR	.equ 0x04	; Stack Linit Register
INTVTP	.equ 0x06	; Interrupt / Trap Vector Table Pointer 
IOPGR	.equ 0x08	; I/O Page Register 
TRPCR	.equ 0x10	; Trap Cntrol Register
CSHCR	.equ 0x12	; Cache Contrl Register
LADRR	.equ 0x14	; Local Address Register
INTSR	.equ 0x16	; Interrupt Status Register
BTINITR	.equ 0xff	; Bus Timing and Initialization Register

MMUMCTL	.equ 0xf0	; MMU Master Control Regiser
MMUPDR	.equ 0xf1	; MMU Page Discrepter Register
MMUDSP	.equ 0xf5	; MMU Discrepter Select Port
MMUBMP	.equ 0xf4	; MMU Block Move Port

CT1CNF	.equ 0xe8	; C/T1 Configuration Register
CT1CS	.equ 0xe9	; C/T1 Command/Status Register
CT1TC	.equ 0xea	; C/T1 Time Constant Register
CT1CT	.equ 0xeb	; C/T1 Count Time Register

UARTCNF	.equ 0x10	; UART Config Register
UARTTCS	.equ 0x12	; UART Transmiter Control/Status Register
UARTRCS	.equ 0x14	; UART Receiver Control/Status Register
UARTRD	.equ 0x16	; UART Receive Data Register
UARTTD	.equ 0x18	; UART Transmit Data Register
	
CR	.equ 0x0d
LF	.equ 0x0a
BS	.equ 0x08
SPC	.equ 0x20

	.area	CODE

	.globl	loop, cmnderr, dcmnd, gcmnd
	.globl  putc, puts, putln, getc, gets
	.globl	skipsp, puthex8, puthex16, strhex8, strhex16
	.globl	adddel

	; MMU setting
	ld	l, 0xff
	ld	c, IOPGR
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

	; C/T1 setting for boud rate
	ld	l, 0xfe
	ld	c, IOPGR
	ldctl	(c), hl
	ld	hl, 38		; 4800 bps at 12MHz CPU cLock
	ld	c, CT1TC
	out	(c), hl
	ld	a, 0b10001000
	out	(CT1CNF), a
	ld	a, 0b11110000
	out	(CT1CS), a

	; UART
	ld	a, 0xca
	out	(UARTCNF), a
	ld	a, 0x80
	out	(UARTTCS), a
	ld	a, 0x80
	out	(UARTRCS), a

	ld	sp, 0x0000
	ldw	(dmpsad), 0x0000
	ldW	(dmpead), 0x0000
	ldw	(memad), 0x0000
	ldw	(jmpad), 0x0000
	ld	hl, mesg
	call 	puts
loop:
	ld	hl, prmpt
	call	puts
	ld	hl, linebuf
	call	gets
	ld	hl, linebuf
	call	skipsp
	or	a, a
	jr	z, loop
	inc	hl
	cp	a, 'd
	jp	z, dcmnd
	cp	a, 'g
	jp	z, gcmnd
	cp	a, 'm
	jp	z, mcmnd
	cp	a, 'l
	jp	z, lcmnd
	cp	a, 'b
	jp	z, bcmnd
	ld	hl, errmsg
cmnderr:
	call	puts
	call	putln
	jr	loop

putc:
	push	hl
	push	bc
	ld	b, a
	ld	l, 0x0fe
	ld	c, IOPGR
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

getc:
	push	hl
	push	bc
	ld	l, 0xfe
	ld	c, IOPGR
	ldctl	(c), hl
getc1:
	in	a, (UARTRCS)
	and	a, 0b00010000
	jr	z, getc1
	in 	a, (UARTRD)
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

gets:
	push	bc
	ld	c, 0
gets1:
	call	getc
	cp	a, BS		; Back Spase
	jr	nz, gets3
	ld	a, c
	or	a, a
	jr	z, gets1
	dec 	c		; Check line top
	ld	a, BS
	call	putc
	dec	hl
	jr	gets1
gets3:
	cp	a, CR
	jr	z, gets4
	cp	a, LF
	jr	z, gets4
	call	putc
	ld	(hl), a
	inc	hl
	inc	c
	jr	gets1
gets4:
	call	putln
	ld	(hl), 0
	pop	bc
	ret

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

putln:
	ld	a, CR
	call	putc
	ld	a, LF
	jp	putc

skipsp:
	ld	a, (hl)
	cp	a, SPC
	ret	nz
	inc	hl
	jr	skipsp

ishex:
	cp	a, '0
	ret	c
	cp	a, '9 + 1
	jr	nc, ishex1
	sub	a, '0
	ret
ishex1:
	cp	a, 'A
	ret	c
	cp	a, 'F + 1
	jr	nc, ishex2
	sub	a, 'A - 0x0a
	ret
ishex2:
	cp	a, 'a
	ret	c
	cp	a, 'f + 1
	jr	nc, ishex3
	sub	a, 'a - 0x0a
	ret
ishex3:
	scf
	ret

strhex8::
	ld	a, (hl)
	call	ishex
	ret	c
	ld	e, a
	inc	hl
	ld	a, (hl)
	call	ishex
	ret	c
	sla	e
	sla	e
	sla	e
	sla	e
	add	a, e
	ld	e, a
	inc	hl
	ret

strhex16::
	call	strhex8
	ret	c
	ld	d, e
	call	strhex8
	ret

	.area	DATA 
mesg:
	.db	0x0d
	.ascii	"Z80280 Mini Monitor"
	.db 	CR, LF, 0x00
errmsg:
	.ascii	"Error"
	.db	0x00

prmpt:
	.ascii	"> "
	.db	0x00

adddel:
	.ascii	" : "
	.db	0x00

pgdtbl:
	.dw	0x000a
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

;------------------------------------------------------------------------------
	.area	RAM
	.globl	dmpsad, dmpead, memad, jmpad, ldadd, linebuf

dmpsad:
	.ds	2
dmpead:
	.ds	2
memad:
	.ds	2

jmpad:
	.ds	2

ldadd:
	.ds	2

linebuf:
	.ds	256
	.ds	256
stkbtm:
