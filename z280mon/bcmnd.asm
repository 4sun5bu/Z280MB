;------------------------------------------------------------------------------
; bcmnd.asm 
;  Load master boot record and jump
;
;  Copyright (c) 2021 4sun5bu
;------------------------------------------------------------------------------

	.z280p

	.area	CODE
	.globl	bcmnd 

bcmnd:
	call	dskinit
	ld	hl, dskbuf
	call	dskread
	ld	(lball), 1
	call	dskread
	ld	de, (dskbuf + 2)
	ld	hl, dskbuf
	ld	bc, 1024
	ldir
	jp	(dskbuf + 2)
berr:
	ld	hl, berrmsg
	jp	cmnderr

;------------------------------------------------------------------------------
	.area	DATA

berrmsg:
	.ascii	"Error! b"
	.db	0

