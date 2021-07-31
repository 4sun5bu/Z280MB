/******************************************************************************
 bin2ihx.c
  make HEX file from binary file with spliting even/odd address data 

  Copyright (c) 2021 4sun5bu 
******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>
#include <string.h>

#define MAXBC  16

int main(int argc, char *argv[])
{
    FILE *fin;
    unsigned int addr;
    unsigned char sum;
    int selct;
 
    int nbytes;
    int bcnt;
    int laddr;
    unsigned char buf[MAXBC];

    if (argc < 2) {
        fprintf(stderr, "usage : b2ihx [option] input-file\n");
        exit(EX_USAGE);
    }

    selct = -1;
    if (argc == 2)
    {
        fin = fopen(argv[1], "rb");
    }
    if (argc == 3)
    {
        if (strcmp(argv[1], "-odd") == 0)
            selct = 1;
        else if (strcmp(argv[1], "-even") == 0)
            selct = 0;
        fin = fopen(argv[2], "rb");
    }   
    if (fin == NULL)
    {
        fprintf(stderr, "Can not open input file\n");
        exit(EX_USAGE);
    }
       
    addr = 0;
    laddr = 0;
    while (1) {
        nbytes = fread(buf, 1, MAXBC, fin);
        if (nbytes == 0)
            break;

        if (selct == 0)
            bcnt = (nbytes + 1) / 2;
        else if (selct == 1)
            bcnt = nbytes / 2;
        else
            bcnt = nbytes;
        printf(":%02x%04x00", bcnt, laddr);
        
        sum = bcnt + (laddr & 0xff) + (laddr >> 8);
        for (int i = 0; i < nbytes; i++, addr++) {
            if ((selct == 1) && ((addr % 2) == 0))
                continue;
            else if ((selct == 0) && ((addr % 2) == 1))
                continue;
            printf("%02x", buf[i]);
            laddr++;
            sum += buf[i];
        }
        
        sum = ~sum + 1;
        printf("%02x\n", sum);
        if (nbytes < MAXBC)
            break;
    }
    printf(":00000001FF\n");
    fclose(fin);
}

