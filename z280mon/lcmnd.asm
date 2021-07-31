;------------------------------------------------------------------------------
; lcmnd.asm 
;  Intel hex data load command
;
;  Copyright (c) 2021 4sun5bu
;------------------------------------------------------------------------------

	.z280p

	.area	CODE
	.globl	lcmnd 

lcmnd:
	ldw	(ldad), 0x0000
	call	skipsp
	or 	a, a
	jr	z, lcmnd1	; without load address
	call	strhex16
	jr	c, lerr
	ld	(ldad), de
	ld	(jmpad), de
lcmnd1:
	ld	hl, linebuf
	call	gets
	ld	hl, linebuf
lcmnd2:
	ld	a, (hl)
	cp	a, ':
	jr	nz, herr
	inc	hl
lcmnd3:
	call	strhex8		; Byte count
	jr	c, herr
	ld	b, e
	ld	c, e
	call	strhex16	; Address
	jr	c, herr
	ld	ixh, d
	ld	ixl, e
	ld	a, c
	add	a, d
	add	a, e
	ld	c, a
	call	strhex8		; Type
	jr	c, herr
	ld	a, e
	cp	a, 0x01
	jp	z, loop
	or	a, a
	jr	nz, herr
	add	a, c
	ld	c, a
lcmnd4:
	call	strhex8
	jr	c, herr
	ld	(ix), e
	ld	a, e
	add	a, c
	ld	c, a
	inc	ix
	djnz	lcmnd4
	call	strhex8
	ld	a, c
	neg
	cp	a, e
	jr 	nz, herr
	jr	lcmnd1
	
lerr:
	ld	hl, lerrmsg
	jp	cmnderr
herr:
	ld	hl, herrmsg
	jp	cmnderr

;------------------------------------------------------------------------------
	.area	DATA

lerrmsg:
	.ascii	"Error! l [xxxx]"
	.db 	0x00

herrmsg:
	.ascii	"Illegal HEX File"
	.db	0x00
