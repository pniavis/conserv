#ifndef __CONSERV_H__
#define __CONSERV_H__

struct uart {
    volatile struct {

        int can_write:1;
        int can_read:1;
        int unused:30;
    } status;
    unsigned int data;
};

#define uart (*((volatile struct uart *) 0x20000000))

static inline void _putchar(char c)
{
    while (!uart.status.can_write);
    uart.data = c;
}

static inline char getchar()
{
    while (!uart.status.can_read);
    return (char) uart.data;
}

#endif

