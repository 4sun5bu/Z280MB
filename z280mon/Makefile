.SUFFIXES: .rel .asm

objs = z280mon.rel ide.rel dcmnd.rel mcmnd.rel gcmnd.rel lcmnd.rel bcmnd.rel

all: splthx z280mon

z280mon: $(objs) splthx
	aslink -m -b CODE=0x0000 -b RAM=0xf000 -i z280mon.ihx  $(objs)
	./splthx -odd z280mon.ihx > z280mono.ihx
	./splthx -even z280mon.ihx > z280mone.ihx 

.asm.rel:
	asz280 -l -g -o $<

splthx: splthx.c
	gcc -o splthx splthx.c

clean:
	rm -f *.rel *.ihx *.lst *.hlr *.map *.bin splthx
