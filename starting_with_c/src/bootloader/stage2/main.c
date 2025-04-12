#include "bios.h"

extern void puts(const char *str); // Declared in puts.asm

void main()
{
    puts("Hello from stage 2 in C!\r\n");

    for (;;)
        ; // Hang forever
}
