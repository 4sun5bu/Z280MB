/******************************************************************************
 chksum.c
  Print sum every 512 bytes

  Copyright (c) 2021 4sun5bu 
******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>
#include <string.h>

int errno = 0;
FILE *fin = NULL;
int eof;

int main(int argc, char *argv[])
{
    unsigned char bdata;
    unsigned char sum;

    if (argc != 2) {
        errno = 1;
        goto finlz;
    }

    if ((fin = fopen(argv[1], "rb")) == NULL) {
        errno = 2;
        goto finlz;
    }
    
    while (1) {
        sum = 0;
        
        for (int i = 0; i < 512; i++) {
            if ((eof = fread(&bdata, 1, 1, fin)) < 1) 
                break;
            sum += bdata;
        }
        
        printf("%02x,", sum);
       if (eof != 1)
           break;
    } 
    printf("\n");

finlz:
    if (fin != NULL)
        fclose(fin);

    switch (errno) {
        case 0:
            exit(EX_OK);
        case 1:
            fprintf(stderr, "Usage : ihx2bin input-filei output-file\n");
            exit(EX_USAGE);
        case 2:
            fprintf(stderr, "Can't open input file\n");
            exit(EX_NOINPUT);
        case 3:
            fprintf(stderr, "Can't open output file\n");
            exit(EX_CANTCREAT);
        case 4:
            fprintf(stderr, "Illegal hex format\n");
            exit(EX_DATAERR);
    }
}
