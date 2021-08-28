	.z280p

IOPAGE	.equ	0x08
WDATA	.equ	0x60
BDATA	.equ	0x61
ERROR	.equ	0x62
FEATURE	.equ	0x62
SECTCNT	.equ	0x65
SECTNO	.equ	0x67
CYLLOW	.equ	0x69
CYLHIGH	.equ	0x6b
DEVHEAD	.equ	0x6d
DEVSTAT	.equ	0x6e
COMND	.equ	0x6e
ALTSTAT	.equ	0x7d
DEVCTL	.equ	0x7d

BSYBIT	.equ	0b10000000
DRDYBIT	.equ	0b01000000
DREQBIT	.equ	0b00001000
ERRBIT	.equ	0b00000001

	.area IPL

	.globl dskinit, dskread, lball, lbalh, lbahl, lbahh
 
chkbsy:
 	in	a, (DEVSTAT)
	and	a, BSYBIT | DREQBIT
	jr	nz, chkbsy
	ret

dskinit:
	ld	hl, 0		; set I/O page register
	ld	c, IOPAGE
	ldctl	(c), hl 
	call	chkbsy
	ld	a, 0x81		; set 16bit PIO mode
	out	(FEATURE), a
	ld	a, 0xef
	out	(COMND), a
	call	chkbsy
	ld	a, 0x04		; set PIO mode 0
	out	(SECTCNT), a
	ld	a, 0x03
	out	(FEATURE), a
	ld	a, 0xef
	out	(COMND), a
	ret

dskread:
	push	hl	
	ld	hl, 0		; set I/O page register
	ld	c, IOPAGE
	ldctl	(c), hl 
	pop	hl	
	call	chkbsy
	xor	a, a		; select DEV #0
	out	(DEVHEAD), a
	call	chkbsy
	xor	a, a		; clear Features
	out	(FEATURE), a
	ld	a, 0b00000010	; disable interrupt
	out	(DEVCTL), a 
	ld	a, 1		; one sector read
	out	(SECTCNT), a
	ld	a, (lbahh)	; set LBA
	and	a, 0x0f		; clear high nibble
	or	a, 0x40		; set LBA access
	out	(DEVHEAD), a
	ld	a, (lbahl)
	out	(CYLHIGH), a
	ld	a, (lbalh)
	out	(CYLLOW), a
	ld	a, (lball)
	out	(SECTNO), a
	ld	a, 0x20		; READ SECTOR command
	out	(COMND), a
	in	a, (ALTSTAT)	;
1$:
	in	a, (DEVSTAT)
	and	a, BSYBIT | DREQBIT
	cp	a, DREQBIT
	jr	nz, 1$

	ld	b, 0
	ld	c, WDATA
2$:
	ex	de, hl
	inw	hl, (c)
	ex	de, hl
	ld	(hl), d
	inc	hl
	ld	(hl), e
	inc	hl
	djnz	2$
	in	a, (ALTSTAT)
	in	a, (DEVSTAT)
	ret

;------------------------------------------------------------------------------
	.area	IPLDATA

lball:
	.db	0
lbalh:
	.db	0
lbahl:
	.db	0
lbahh:
	.db	0
