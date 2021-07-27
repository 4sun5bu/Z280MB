# z280mon
A Minimum machine Code Monitor for Z80280   

To build z280mon you need asxxxx, and just type "make".
Then three Intel hex files are generated.
- z280mon.ihx :  Single binary not splited
- z280mono.ihx : Splited binary for odd address ROM   
- z280mone.ihx : Splited binary for even address ROM   

This monitor has 4 commands
- d [xxxx] [yyyy] : Memory dump from xxxx to yyyy    
- m [xxxx] : Modify memory value at the address xxxx 
- l : Load hex file    
- g xxxx : Jump to xxxx    
 

