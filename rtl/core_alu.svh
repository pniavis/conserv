`ifndef __CORE_ALU_SVH__
`define __CORE_ALU_SVH__

    typedef enum logic [3:0] {
        ALU_ADD,
        ALU_SUB,
        ALU_XOR,
        ALU_OR,
        ALU_AND,
        ALU_SLT,
        ALU_SLTU,
        ALU_SLL,
        ALU_SRL,
        ALU_SRA,
        ALU_OUTB
    } alu_op_t;

`endif