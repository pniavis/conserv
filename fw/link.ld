MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x10000
    ROM (rx) : ORIGIN = 0x10000000, LENGTH = 0x4000
}

ENTRY(_start);
PROVIDE (__stack_top__  = ORIGIN(RAM) + LENGTH(RAM));

SECTIONS
{
    .text : {
        *(.text.crt0)
        *(.text.crt)
        *(.text.* .text)
        *(.rodata .rodata.*)
        . = ALIGN(4);
    } > ROM AT > ROM

    __data_init__ = .;

    .data : {
        __data_start__ = .;
        *(.sdata.* .sdata)
        *(.data.* .data)
        *(.bss.* .bss)
        *(.sbss.* .sbss)
        . = ALIGN(4);
        __data_end__ = .;
    } > RAM AT > ROM
}

