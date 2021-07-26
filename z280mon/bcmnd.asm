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
	ld	(baddr), 0xdc00
	call	skipsp
	or 	a, a
	jr	z, bcmnd1	; without load address
	call	strhex16
	jr	c, berr
	ld	(baddr), de
bcmnd1:
	ld	hl, 0
	ld	(lbahl), hl
	ld	(lball), hl
	ld	hl, (baddr)
	call	dskread
	jp	(baddr)
berr:
	ld	hl, berrmsg
	jp	cmnderr

;------------------------------------------------------------------------------
	.area	DATA

berrmsg:
	.ascii	"Error! b [xxxx]"
	.db	0

;------------------------------------------------------------------------------
	.area	RAM

baddr:
	.ds	2

