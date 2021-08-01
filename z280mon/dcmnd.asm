;------------------------------------------------------------------------------
; dcmnd.asm 
;  Memory dump command
;
;  Copyright (c) 2021 4sun5bu
;------------------------------------------------------------------------------

	.z280p

	.area	CODE
	.globl	dcmnd 

dcmnd:
	call	skipsp
	or 	a, a
	ld	de, (dmpsad)
	jr	z, dcmnd1	; without start address
	call	strhex16
	jr	c, derr
	ld	(dmpsad), de
	call	skipsp
	or	a, a
	jr	nz, dcmnd2	
dcmnd1:
	ex	de, hl		; only start address
	add	hl, 255
	jr	nc, dcmnd11
	ld	hl, 0xffff
dcmnd11:
	ld 	(dmpead), hl
	ex	de, hl
	jr	dcmnd3
dcmnd2:
	call	strhex16	; with start and end address
	jr	c, derr
	ld	(dmpead), de	
dcmnd3:
	ld	de, (dmpsad)
	call	puthex16
	ld	hl, adrdel
	call	puts
	ld	hl, (dmpsad)
	call	ldmp
	ld	(dmpsad), hl
	cp 	hl, (dmpead)
	jr	c, dcmnd3
	jr	z, dcmnd3
	jp	loop
derr:
	ld	hl, derrmsg
	call	puts
	jp	cmnderr

ldmp:
	ld	b, 16
	push	hl
ldmp1:
	ld	e, (hl)
	call	puthex8
	ld	a, 0x20 
	call	putc
	inc	hl
	djnz	ldmp1
	ld	a, '|
	call	putc
	ld	a, 0x20
	call	putc
	pop	hl
	ld	b, 16
ldmp2:
	ld	a, (hl)
	cp 	a, 0x20
	jr	c, ldmp3
	cp	a, 0x80
	jr	c, ldmp4
ldmp3:
	ld	a, '.
ldmp4:
	call	putc
	inc	hl
	djnz	ldmp2
	call	putln
	ret

;------------------------------------------------------------------------------
	.area	DATA

derrmsg:
	.ascii	"Error! d [xxxx] [yyyy]"
	.db 	0

