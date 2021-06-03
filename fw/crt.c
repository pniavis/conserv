extern unsigned int __data_init__;
extern unsigned int __data_start__, __data_end__;

int main(void);

void crt(void) __attribute__((section(".text.crt")));
void crt(void)
{
    unsigned int *src = &__data_init__;
    unsigned int *dst;

    asm volatile("la %0, %1\n" : "=r" (dst) : "i" (&__data_start__));

    while (dst < &__data_end__)
        *dst++ = *src++;

    (void) main();
    while (1);
}

