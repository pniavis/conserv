.section .text.crt0
_start:
.global _start
    la sp, __stack_top__
    call crt
    j .





