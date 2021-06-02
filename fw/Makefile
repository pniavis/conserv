TOOLCHAIN = /home/pn/mmc/riscv/bin/
PROJECT = bootrom
OBJECTS = crt0.o crt.o printf.o aes.o test_aes.o
CC_FLAGS = -march=rv32i -mabi=ilp32 -mstrict-align -Wall -nostartfiles -fno-zero-initialized-in-bss -ffunction-sections -fdata-sections -Os
LD_FLAGS = --gc-sections --static 
LD_SCRIPT = link.ld

AS      = $(TOOLCHAIN)riscv32-unknown-elf-as
CC      = $(TOOLCHAIN)riscv32-unknown-elf-gcc
LD      = $(TOOLCHAIN)riscv32-unknown-elf-ld
OBJCOPY = $(TOOLCHAIN)riscv32-unknown-elf-objcopy
SIZE    = $(TOOLCHAIN)riscv32-unknown-elf-size

all: $(PROJECT).bin

clean:
	rm -f $(OBJECTS) $(PROJECT).elf $(PROJECT).bin

crt.o: crt.c
	$(CC) $(CC_FLAGS) $(CC_SYMBOLS) $(INCLUDE_PATHS) -Os -o crt.o -c crt.c

.c.o .s.o:
	$(CC) $(CC_FLAGS) $(CC_SYMBOLS) $(INCLUDE_PATHS) -o $@ -c $<

$(PROJECT).elf: $(OBJECTS)
	$(CC) $(CC_FLAGS) -T$(LD_SCRIPT) -Xlinker $(LD_FLAGS) -o $@ $^

$(PROJECT).bin: $(PROJECT).elf
	$(OBJCOPY) -O binary $< $@
	$(SIZE) $<
