#ifndef __CONSERV_H__
#define __CONSERV_H__

struct uart {
    volatile uint32_t data;
};

#define uart ((struct uart *) 0x20000000)

static inline void _putchar(char c)
{
    while (uart->data);
    uart->data = c;
}

#endif

