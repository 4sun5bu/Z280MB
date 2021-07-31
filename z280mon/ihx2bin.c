/******************************************************************************
 ihx2bin.c
  make binary file from HEX file

  Copyright (c) 2021 4sun5bu 
******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>
#include <string.h>

#define MAXLEN  256

int errno = 0;
FILE *fin = NULL;
FILE *fout = NULL;
char linebuf[MAXLEN];
unsigned char binbuf[MAXLEN];

int main(int argc, char *argv[])
{
    int bcount;
    int lnaddr;
    int type;
    int data;
    int lsum;

    unsigned int sum;

    if (argc != 3) {
        errno = 1;
        goto finlz;
    }

    if ((fin = fopen(argv[1], "r")) == NULL) {
        errno = 2;
        goto finlz;
    }
    if ((fout = fopen(argv[2], "wb")) == NULL) {
        errno = 3;
        goto finlz;
    }   
    
    while (1) {
        sum = 0;
        
        /* Read one line */
        if (fgets(linebuf, MAXLEN, fin) == NULL) {
            if (feof(fin)) 
                break;
            else {
                errno = 4;
                goto finlz;
            }
        } 

        /* Scan byte count, address and record type */
        if (sscanf(linebuf, ":%2x%4x%2x", &bcount, &lnaddr, &type) != 3)
        {
            errno = 4;
            break;
        }
        
        /* Check the recode type */
        if (type == 0x01)
            break;

        fseek(fout, lnaddr, SEEK_SET);

        sum += bcount; 
        sum += (lnaddr / 256 + (lnaddr & 0x00ff)); 

        for(int n = 0; n < bcount; n++) {
            if (sscanf(&linebuf[n * 2 + 9], "%2x", &data) != 1) {
                errno = 4;
                goto finlz;
            }
            binbuf[n] = data;
            sum += data;
            lnaddr++;
        }

        /* Calcurate the checksum */
        if ((sscanf(&linebuf[bcount * 2 + 9], "%2x", &lsum) != 1) ||
           ((-(sum % 256) & 0xff) != lsum)) {
            errno = 4;
            goto finlz;
        }
        
        fwrite(binbuf, 1, bcount, fout);
    }

finlz:
    if (fin != NULL)
        fclose(fin);
	if (fout != NULL)
        fclose(fout);

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
