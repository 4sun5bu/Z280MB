/******************************************************************************
 splthx.c
  split HEX file into even/odd address data

  Copyright (c) 2021 4sun5bu 
******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>
#include <string.h>

#define MAXLEN  256

int errno = 0;
FILE *fin = NULL;
char linebuf[MAXLEN];

int main(int argc, char *argv[])
{
    int select;
    int bcount;
    int lnaddr;
    int type;
    int data;
    int obcount;
    int otfaddr;
    unsigned int sum;

    if (argc < 3) {
        errno = 3;
        goto finlz;
    }

    if (argc == 3)
    {
        if (strcmp(argv[1], "-odd") == 0)
            select = 1;
        else if (strcmp(argv[1], "-even") == 0)
            select = 0;
        fin = fopen(argv[2], "r");
    }   
    if (fin == NULL)
    {
        errno = 2;
        goto finlz;
    }
    
    otfaddr = 0;
    while (1) {
        sum = 0;
        
        /* Read one line */
        if (fgets(linebuf, MAXLEN, fin) == NULL) {
            if (feof(fin)) 
                break;
            else {
                errno = 1;
                goto finlz;
            }
        } 

        /* Scan byte count, address and record type */
        if (sscanf(linebuf, ":%2x%4x%2x", &bcount, &lnaddr, &type) != 3)
        {
            errno = 1;
            break;
        }
        
        /* Check the recode type */
        if (type == 0x01)
            break;

        /* Adjust the address */
        otfaddr = lnaddr / 2;

        /* Calcurate the byte count */
        if ((bcount & 0x0001) && ((lnaddr & 0x0001) == select))
            obcount = bcount / 2 + 1;
        else 
            obcount = bcount / 2;
        if (obcount == 0)
            continue;
        
        sum += obcount; 
        sum += (otfaddr / 256 + (otfaddr & 0x00ff)); 

        printf(":%02X%04X%02X", obcount, otfaddr, type);
        for(int n = 0; n < bcount; n++) {
            if (sscanf(&linebuf[n * 2 + 9], "%2x", &data) != 1) {
                errno = 1;
                goto finlz;
            }
            if ((lnaddr & 0x0001) == select) {
                printf("%02X", data);
                sum += data;
                otfaddr++;
            }
            lnaddr++;
        }

        /* Calcurate the checksum */
        sum = -(sum % 256) & 0xff;
        printf("%02X\n", sum);
    }

finlz:
    if (fin != NULL)
        fclose(fin);

    switch (errno) {
        case 0:
            printf(":00000001FF\n");
            exit(EX_OK);
        case 1:
            fprintf(stderr, "Illegal hex format\n");
            exit(EX_DATAERR);
        case 2:
            fprintf(stderr, "No input file\n");
            exit(EX_NOINPUT);
        case 3:
            fprintf(stderr, "Usage : splthx -even/-odd  input-file\n");
            exit(EX_USAGE);
    }
}
