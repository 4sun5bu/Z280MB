;-----------------------------------------------------------------------------
; diskrw.asm
;   CF card read and write routines
; 
;   Copyright (c) 4sun5bu
;-----------------------------------------------------------------------------

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

	.z280p

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

dskwrt:
	push	hl
	ld	hl, 0
	ld	bc, IOPAGE
	ldctl	(c), hl
	pop	hl
	call	chkbsy
	xor	a, a		; select DEV #0
	out	(DEVHEAD), a
	call	chkbsy
	xor	a, a		; clear feature
	out	(FEATURE), a
	ld	a, 0b00000010	; disable interrupt
	out	(DEVCTL), a
	ld	a, 1		; one sector read
	out	(SECTCNT), a
	ld	a, (lbahh)	; set LBA
	and	a, 0x0f		; mask high nibble
	or	a, 0x40		; set LBA access
	out	(DEVHEAD), a
	ld	a, (lbahl)
	out	(CYLHIGH), a
	ld	a, (lbalh)
	out	(CYLLOW), a
	ld	a, (lball)
	out	(SECTNO), a
	ld	a, 0x30		; WRITE SECTOR command
	out	(COMND), a
	in	a, (ALTSTAT)
1$:
	in	a, (DEVSTAT)
	and	a, BSYBIT | DREQBIT
	cp	a, DREQBIT
	jr	nz, 1$
	in	a, (DEVSTAT)

	ld	b, 0
	ld	c, WDATA
2$:
	ld	d, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ex	de, hl
	outw	(c), hl
	ex	de, hl
	djnz	2$
	in	a, (ALTSTAT)
	in	a, (DEVSTAT)
	ret

dts2lba:
	ld	hl, (track)	; track * 32
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a, (sector)	; sector / 4
	srl	a
	srl	a
	ld	e, a
	ld	d, 0
	add	hl, de
	ld	a, (dskno)	; dskno << 14
	rrca
	rrca
	ld	d, a
	ld	e, 0
	add	hl, de
	ret

;------------------------------------------------------------------------------

lball:	
	.ds	1
lbalh:	
	.ds	1
lbahl:	
	.ds	1
lbahh:	
	.ds	1

rcdbuf:
	.ds	512
