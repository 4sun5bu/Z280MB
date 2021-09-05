.SUFFIXES: .rel .asm

objs = ipl.rel ide.rel

ipl: $(objs)
	aslink -m -b IPL=0x2000 -i ipl.ihx  $(objs)
	../../z280mon/ihx2bin ipl.ihx iplraw.bin
	dd if=iplraw.bin of=ipl.bin bs=1 skip=8192

.asm.rel:
	asz280 -l -g -o $<

clean:
	rm -f *.rel *.ihx *.lst *.hlr *.map *.bin splthx
