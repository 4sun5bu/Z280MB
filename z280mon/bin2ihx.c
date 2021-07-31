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
    int order;

    if (argc < 2) {
        fprintf(stderr, "usage : b2ihx [option] input-file\n");
        exit(EX_USAGE);
    }

    order = -1;
    if (argc == 2)
    {
        fin = fopen(argv[1], "rb");
    }
    if (argc == 3)
    {
        if (strcmp(argv[1], "-odd") == 0)
            order = 1;
        else if (strcmp(argv[1], "-even") == 0)
            order = 0;
        fin = fopen(argv[2], "rb");
    }   
    if (fin == NULL)
    {
        fprintf(stderr, "can not open file\n");
        exit(EX_USAGE);
    }
    
    int n;
    int bc;
    int oc;
    unsigned char buf[MAXBC];
    
    addr = 0;
    oc = 0;
    while (1) {
        n = fread(buf, 1, MAXBC, fin);
        if (n == 0)
            break;

        if (order == 0)
            bc = (n + 1) / 2;
        else if (order == 1)
            bc = n / 2;
        else
            bc = n;
        printf(":%02x%04x00", bc, oc);
        sum = bc + (oc & 0xff) + (oc >> 8);
        for (int i = 0; i < n; i++, addr++) {
            if ((order == 1) && ((addr % 2) == 0))
                continue;
            else if ((order == 0) && ((addr % 2) == 1))
                continue;
            printf("%02x", buf[i]);
            oc++;
            sum += buf[i];
        }
        sum = ~sum + 1;
        printf("%02x\n", sum);
        if (n < MAXBC)
            break;
    }
    printf(":00000001FF\n");
    fclose(fin);
}

