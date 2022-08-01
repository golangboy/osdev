#include "types.h"
unsigned char inb(unsigned short port);
void outb(unsigned short port, unsigned char value);
unsigned short inw(unsigned short port);
int waitIde();
void readIde();
#define STAT_ERR (1 << 0) // Indicates an error occurred. Send a new command to clear it
#define STAT_DRQ (1 << 3) // Set when the drive has PIO data to transfer, or is ready to accept PIO data.
#define STAT_SRV (1 << 4) // Overlapped Mode Service Request.
#define STAT_DF (1 << 5)  // Drive Fault Error (does not set ERR).
#define STAT_RDY (1 << 6) // Bit is clear when drive is spun down, or after an error. Set otherwise.
#define STAT_BSY (1 << 7) // Indicates the drive is preparing to send/receive data (wait for it to clear).
int main()
{
    while (1)
        ;
    return 0;
}

inline unsigned char inb(unsigned short port)
{
    unsigned char ret;

    asm volatile("inb %1, %0"
                 : "=a"(ret)
                 : "dN"(port));

    return ret;
}

inline void outb(unsigned short port, unsigned char value)
{
    asm volatile("outb %1, %0"
                 :
                 : "dN"(port), "a"(value));
}

inline unsigned short inw(unsigned short port)
{
    unsigned short ret;

    asm volatile("inw %1, %0"
                 : "=a"(ret)
                 : "dN"(port));

    return ret;
}