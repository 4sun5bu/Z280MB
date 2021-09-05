#!/bin/sh

mkfs.cpm -f cpm8k dsk_a.img
dd if=./ipl/ipl.bin of=dsk_a.img conv=notrunc
dd if=./cpm.bin of=dsk_a.img seek=2 conv=notrunc
cpmcp -f cpm8k dsk_a.img dsk_a/*.* 0:
mkfs.cpm -f cpm8k dsk_b.img
cpmcp -f cpm8k dsk_b.img dsk_b/*.* 0:
mkfs.cpm -f cpm8k dsk_c.img
cpmcp -f cpm8k dsk_c.img dsk_c/*.* 0:
mkfs.cpm -f cpm8k dsk_d.img
cpmcp -f cpm8k dsk_d.img dsk_d/*.* 0:

dd if=dsk_a.img of=cpmdsk.img count=16384 conv=notrunc
dd if=dsk_b.img of=cpmdsk.img count=16384 seek=16384 conv=notrunc
dd if=dsk_c.img of=cpmdsk.img count=16384 seek=32768 conv=notrunc
dd if=dsk_d.img of=cpmdsk.img count=16384 seek=49152 conv=notrunc
