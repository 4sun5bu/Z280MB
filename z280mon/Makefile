.SUFFIXES: .rel .asm

objs = z280mon.rel ide.rel dcmnd.rel mcmnd.rel gcmnd.rel lcmnd.rel bcmnd.rel

all: z280mon

z280mon: $(objs) ihx2bin bin2ihx
	aslink -m -b CODE=0x2000 -b RAM=0xf000 -i z280mon.ihx  $(objs)
	./ihx2bin z280mon.ihx  z280mon.bin
	./bin2ihx -even z280mon.bin > z280mone.ihx
	./bin2ihx -odd z280mon.bin > z280mono.ihx

.asm.rel:
	asz280 -l -g -o $<

ihx2bin: ihx2bin.c
	gcc -o ihx2bin ihx2bin.c

bin2ihx: bin2ihx.c
	gcc -o bin2ihx bin2ihx.c

clean:
	rm -f *.rel *.ihx *.lst *.hlr *.map *.bin ihx2bin bin2ihx
