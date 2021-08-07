.SUFFIXES: .rel .asm

objs = ipl.rel ide.rel

ipl: $(objs)
	aslink -m  -i ipl.ihx  $(objs)
	../ihx2bin ipl.ihx iplraw.bin
	dd if=iplraw.bin of=ipl.bin bs=1 skip=8192

.asm.rel:
	asz280 -l -g -o $<

clean:
	rm -f *.rel *.ihx *.lst *.hlr *.map *.bin splthx
