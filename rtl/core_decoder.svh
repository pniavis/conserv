`ifndef __CORE_DECODER_SVH__
`define __CORE_DECODER_SVH__

    typedef enum logic {
        ASEL_REG,
        ASEL_PC
    } asel_t;

    typedef enum logic {
        BSEL_REG,
        BSEL_IMM
    } bsel_t;

    typedef enum logic [2:0] {
        REG_WSEL_ALU,
        REG_WSEL_IMM,
        REG_WSEL_MEM,
        REG_WSEL_PC,
        REG_WSEL_PC4
    } reg_wsel_t;

    typedef struct packed {
        logic [31:0] imm;
        rv::regaddr_t rs1, rs2, rd;
        logic want_rs1, want_rs2;
        logic reg_wen;
        reg_wsel_t reg_wsel;
        asel_t asel;
        bsel_t bsel;
        alu_op_t aluop;
        logic mem_ren, mem_wen;
        logic [2:0] mem_type;
        logic is_jump;
        logic is_branch;
        rv::funct3b_t branch_cond;
        rv::csr_addr_t csr_addr;
    } dec_t;

`endif