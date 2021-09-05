How to make CP/M disk image

 * Download 'CP/M 2.2 BINARY' (cpm22-b.zip) from http://www.cpm.z80.de/binary.html.
 * Unzip the file and copy CPM.SYS in directory.
 * Type 'make'.
 * In the 'ipl' directroy, type 'make'.
 * Copy CP/M files you want to store in dsk_a, b, c ,d directories.
 * Install cpmtools, and append 'cpm8k.def' to '/etc/cpmtools/diskdefs' as super user.
 * In the cpm directory type './mkdskimg'
 * Write 'cpmdsk.img' to a drive with dd command.
