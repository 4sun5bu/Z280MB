;------------------------------------------------------------------------------
; mcmnd.asm 
;  Memory modify command
;
;  Copyright (c) 2021 4sun5bu
;------------------------------------------------------------------------------

	.z280p

	.area	CODE
	.globl	mcmnd 

mcmnd:
	call	skipsp
	or 	a, a
	jr	z, mcmnd1	; without start address
	call	strhex16
	jr	c, merr
	ld	(memad), de
mcmnd1:
	ld	ix, (memad)
	ld	de, (memad)
	call	puthex16
	ld	hl, adrdel
	call	puts
	ld	a, (ix)
	ld	e, a
	call	puthex8
	ld	hl, memeq
	call	puts
	ld	hl, linebuf
	call	gets
	ld	hl, linebuf
	call	skipsp		; check empty
	or	a, a
	jr	nz, mcmnd2
	incw	(memad)
	jr	mcmnd1
mcmnd2:	
	call	strhex8
	jp	c, loop
	ld	(ix), e
	inc	ix
	ld	(memad), ix
	call	skipsp		; check line end
	or	a, a
	jr	z, mcmnd1
	jr	mcmnd2

merr:
	ld	hl, merrmsg
	jp	cmnderr
;------------------------------------------------------------------------------
	.area	DATA
memeq:
	.ascii	" = "
	.db	0x00

merrmsg:
	.ascii	"Error! m [xxxx]"
	.db 	0
