;------------------------------------------------------------------------------
; bios.asm
;  CP/M 2.2 BIOS based on cbios
;
;  Copyright (c) 2021 4sun5bu
;------------------------------------------------------------------------------

	.z280p

IOPAGE	.equ 0x08	; I/O Page Register 

CT1CNF	.equ 0xe8	; C/T1 Configuration Register
CT1CS	.equ 0xe9	; C/T1 Command/Status Register
CT1TC	.equ 0xea	; C/T1 Time Constant Register
CT1CT	.equ 0xeb	; C/T1 Count Time Register

UARTCNF	.equ 0x10	; UART Config Register
UARTTCS	.equ 0x12	; UART Transmiter Control/Status Register
UARTRCS	.equ 0x14	; UART Receiver Control/Status Register
UARTRD	.equ 0x16	; UART Receive Data Register
UARTTD	.equ 0x18	; UART Transmit Data Register

;------------------------------------------------------------------------------
	.area	BIOS

MSIZE	.equ	62
BIAS	.equ	(MSIZE - 20) * 1024
CCP	.equ	0x3400 + BIAS
BDOS	.equ	CCP + 0x0806
BIOS	.equ	CCP + 0x1600
CDISK	.equ	0x0004
IOBYTE	.equ	0x0003
BUFF	.equ	0x0080

NSECTS	.equ	(BIOS - CCP) / 128

NDISKS	.equ	4

	jp	boot
wboote:
	jp	wboot
	jp	const
	jp	conin
	jp	conout
	jp	list
	jp	punch
	jp	reader
	jp	home
	jp	seldsk
	jp	settrk
	jp	setsec
	jp	setdma
	jp	read
	jp	write
	jp	list
	jp	sectran

dpbase:
	.dw	0x0000, 0x0000
	.dw	0x0000, 0x0000
	.dw	dirbf, dpblk
	.dw	chk00, all00

	.dw	0x0000, 0x0000
	.dw	0x0000, 0x0000
	.dw	dirbf, dpblk
	.dw	chk01, all01

	.dw	0x0000, 0x0000
	.dw	0x0000, 0x0000
	.dw	dirbf, dpblk
	.dw	chk02, all02

	.dw	0x0000, 0x0000
	.dw	0x0000, 0x0000
	.dw	dirbf, dpblk
	.dw	chk03, all03

dpblk:
	.dw	128		; SPT : setors per track
	.db	5		; BSH : block shift factor
	.db	31		; BLM : block mask
	.db	1		; EXM : extent mask
	.dw	2039		; DSM : disksize - 1
	.dw	511;		; DRM : directory max
	.db	0xf0		; AL0 : alloc0
	.db	0		; AL1 : alloc1
	.dw	0		; CKS : check vector size
	.dw	2		; OFF : track offset

boot:
	ld	sp, 0x0080
	call	conini
	ld	hl, signon
	call	prmsg
	xor	a, a
	ld	(IOBYTE), a
	ld	(CDISK), a
	call	dskinit
	jp	gocpm

wboot:
	ld	sp, 0x0080
	ld	c, 0x00
	call	seldsk
	call	home
	ld	b, NSECTS
	ld	c, 8
	ld	hl, CCP
load1:
	call	setsec
	call	setdma
	push	hl
	push	bc
	call	read
	cp	a, 0x00
	jr	nz, wboot
	pop	bc
	pop	hl
	ld	de, 128
	add	hl, de
	inc	c
	djnz	load1

gocpm:
	ld	a, 0xc3
	ld	(0x0000), a
	ld	hl, wboote
	ld	(0x0001), hl

	ld	(0x0005), a
	ld	hl, BDOS
	ld	(0x0006), hl

	ld	bc, 0x0080
	call	setdma
	
	ei
	ld	a, (CDISK)
	ld	c, a
	jp	CCP

const:
	push	bc
	push	hl
	ld	l, 0xfe
	ld	c, IOPAGE
	ldctl	(c), hl
	pop	hl
	pop	bc
	in	a, (UARTRCS)
	bit	4, a
	ld	a, 0x00
	ret	z
	ld	a, 0xff
	ret

conin:
	push	hl
	push	bc
	ld	l, 0xfe
	ld	c, IOPAGE
	ldctl	(c), hl
conin1:
	in	a, (UARTRCS)
	bit	4, a
	jr	z, conin1
	in	a, (UARTRD)
	and	a, 0x7f
	pop	bc
	pop	hl
	ret

conout:
	push	hl
	push	bc
	ld	l, 0xfe
	ld	c, IOPAGE
	ldctl	(c), hl
conout1:
	in	a, (UARTTCS)
	bit	0, a
	jr	z, conout1
	pop	bc
	ld	a, c
	out	(UARTTD), a
	pop	hl
	ret

list:
	ret

punch:
	ret

reader:
	ld	a, 26
	ret

seldsk:
	ld	a, c
	ld	(dskno), a
	cp	a, NDISKS
	ld	hl, 0x0000
	ret	nc		; error
	ld	l, a
	ld	h, 0x00
	add	hl, hl		; 16x
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, dpbase
	add	hl, de
	ret

home:
	ld	bc, 0
	
settrk:
	ld	(track), bc
	ret

setsec:
	ld	(sector), bc
	ret

sectran:
	ld	h, b
	ld	l, c
	ret

setdma:
	ld	(dmaad), bc
	ret

read:
	call	dts2lba
	ld	(lball), hl
	ld	(lbahl), 0
	ld	hl, rcdbuf
	call	dskread
	ld	a, (sector)
	and	a, 0x03
	ld	e, 0
	ld	d, a
	srl	d
	rr	e
	ld	hl, rcdbuf
	add	hl, de
	ld	de, (dmaad)
	ld	bc, 128
	ldir
	ld	a, 0
	ret

write:
	call	dts2lba
	ld	(lball), hl
	ld	(lbahl), 0
	ld	hl, rcdbuf
	call	dskread
	ld	a, (sector)
	and	a, 0x03
	ld	e, 0
	ld	d, a
	srl	d
	rr	e
	ld	hl, rcdbuf
	add	hl, de
	ld	de, (dmaad)
	ex	de, hl
	ld	bc, 128
	ldir
	ld	hl, rcdbuf
	call	dskwrt
	xor	a, a
	ret

conini:
	; C/T1 setting for boud rate
	ld	l, 0xfe
	ld	c, IOPAGE
	ldctl	(c), hl
	ld	hl, 20		; 9375bps at 12MHz internal cLock
	ld	c, CT1TC	; 9600bps at 12.288MHz internal clock
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
	ret

;------------------------------------------------------------------------------
	.include "diskrw.asm"
;------------------------------------------------------------------------------
prmsg:
	ld	a, (hl)
	or	a, a
	ret	z
	push	hl
	ld	c, a
	call	conout
	pop	hl
	inc 	hl
	jr	prmsg

signon:
	.db	0x0d
	.db	MSIZE / 10 + '0
	.db	MSIZE % 10 + '0
	.ascii	"K CP/M ver 2.2 on Z80280"
	.db 	0x0d, 0x0a, 0x00

;------------------------------------------------------------------------------
track:
	.ds	2
sector:
	.ds	2
dmaad:
	.ds	2
dskno:
	.ds	1

BEGDAT	.equ	#.

dirbf:
	.ds	128
all00:
	.ds	31
all01:
	.ds	31
all02:
	.ds	31
all03:
	.ds	31
chk00:
	.ds	16
chk01:
	.ds	16
chk02:
	.ds	16
chk03:
	.ds	16

rcdbuf:
	.ds	512

ENDDAT	.equ	#.
DATSIZ	.equ	#. - BEGDAT

