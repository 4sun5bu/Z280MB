	.z280p

	.area	CODE
	.globl	gcmnd 

gcmnd:
	call	skipsp
	or 	a, a
	jr	z, gcmnd1	; without start address
	call	strhex16
	jr	c, gerr
	ld	(jmpad), de
gcmnd1:
	ld	hl, (jmpad)
	call	(hl)
	jp	loop
	
gerr:
	ld	hl, gerrmsg
	jp	cmnderr

	.area	DATA

gerrmsg:
	.ascii	"Error! G [xxxx]"
	.db 	0
