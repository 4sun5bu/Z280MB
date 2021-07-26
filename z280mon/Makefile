.SUFFIXES: .rel .asm

objs = z280mon.rel ide.rel dcmnd.rel mcmnd.rel gcmnd.rel lcmnd.rel bcmnd.rel

z280mon: $(objs)
	aslink -b CODE=0x0000 -b RAM=0xf000 -i z280mon.ihx  $(objs)
	makebin -p z280mon.ihx z280mon.bin
	b2ihx -odd z280mon.bin > z280mono.ihx
	b2ihx -even z280mon.bin > z280mone.ihx 

.asm.rel:
	asz280 -l -g -o $<

clean:
	rm -f *.rel *.ihx *.lst *.hlr *.bin
