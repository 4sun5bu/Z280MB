.SUFFIXES: .rel .asm

objs = bios.rel 

cpmbin: CPM.SYS bios.bin
	dd if=CPM.SYS of=CPMtr.bin bs=1 count=5632
	cat CPMtr.bin bios.bin > cpm.bin

bios.bin: $(objs) chksum
	aslink -m -b BIOS=0xf200 -i bios.ihx  $(objs)
	../z280mon/ihx2bin bios.ihx biosraw.bin
	dd if=biosraw.bin of=bios.bin bs=1 skip=61952

.asm.rel:
	asz280 -l -g -o $<

chksum: chksum.c
	gcc -o chksum chksum.c

clean:
	rm -f *.rel *.ihx *.lst *.hlr *.map *.bin chksum
