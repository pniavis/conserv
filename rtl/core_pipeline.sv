`include "core_alu.svh"
`include "core_decoder.svh"

interface f_if();
    logic [31:0] pc_new;
    logic pc_load;

    modport master(
        input   pc_new,
                pc_load
    );

    modport branch(
        output  pc_new,
                pc_load
    );
endinterface


interface d_if();
    logic valid;
    logic ready;
    logic [31:0] pc;
    logic stall;
    logic flush;
    rv::instr_t ir;
    logic [31:0] imm;
    logic [31:0] fwd_value1, fwd_value2;
    logic fwd_rs1en, fwd_rs2en;
    rv::regaddr_t rs1, rs2;
    logic is_branch;
    logic predicted_taken;
    rv::csr_addr_t csr_addr;
    logic [31:0] csr_value;

    modport master(
        input   valid,
                pc,
                ir,
                csr_value,
                fwd_value1, fwd_value2,
                fwd_rs1en, fwd_rs2en,
                predicted_taken,
                stall,
                flush,
        output  ready,
                rs1, rs2,
                is_branch,
                imm,
                csr_addr
    );

    modport slave(
        output  valid,
                pc,
                ir,
        input   ready
    );

    modport hazzard(
        input   valid,
                flush,
                rs1, rs2,
        output  fwd_value1, fwd_value2,
                fwd_rs1en, fwd_rs2en,
                stall
    );

    modport branch(
        input   valid,
                ready,
                pc,
                is_branch,
                imm,
        output  flush,
                predicted_taken
    );

    modport csr(
        input   csr_addr,
        output  csr_value
    );
endinterface


interface x_if();
    logic valid;
    logic ready;
    logic [31:0] pc;
    logic [31:0] pc_new;
    logic [31:0] imm;
    logic [31:0] rs1, rs2;
    rv::regaddr_t rd;
    logic reg_wen;
    reg_wsel_t reg_wsel;
    alu_op_t aluop;
    asel_t asel;
    bsel_t bsel;
    logic [2:0] mem_type;
    logic mem_ren, mem_wen;
    logic is_jump;
    logic is_branch;
    rv::funct3b_t branch_cond;
    logic predicted_taken;
    logic [31:0] csr_value;

    modport master(
        input   valid,
                pc,
                imm,
                rs1, rs2,
                rd,
                reg_wen,
                reg_wsel,
                aluop,
                asel, bsel,
                mem_type,
                mem_ren, mem_wen,
                is_jump,
                is_branch,
                branch_cond,
                csr_value,
        output  ready,
                pc_new
    );

    modport slave(
        output  valid,
                pc,
                imm,
                rs1, rs2,
                rd,
                reg_wen,
                reg_wsel,
                aluop,
                asel, bsel,
                mem_type,
                mem_ren, mem_wen,
                is_jump,
                is_branch,
                branch_cond,
                predicted_taken,
                csr_value,
        input   ready
    );

    modport hazzard(
        input   valid,
                reg_wen,
                rd
    );

    modport branch(
        input   valid,
                pc,
                pc_new,
                rs1, rs2,
                is_jump,
                is_branch,
                branch_cond,
                predicted_taken
    );
endinterface


interface m_if();
    logic valid;
    logic ready;

    logic [31:0] pc;
    logic [31:0] pc4;
    logic [31:0] imm;
    logic [31:0] rs2;
    rv::regaddr_t rd;
    logic reg_wen;
    reg_wsel_t reg_wsel;
    logic [31:0] wdata;
    logic [31:0] alu_out;
    logic [31:0] alu_sum;
    logic [2:0] mem_type;
    logic mem_ren, mem_wen;
    logic [31:0] csr_value;

    modport master(
        input   valid,
                pc,
                pc4,
                imm,
                rs2,
                rd,
                reg_wen,
                reg_wsel,
                alu_out,
                alu_sum,
                mem_type,
                mem_ren, mem_wen,
                csr_value,
        output  ready,
                wdata
    );

    modport slave(
        output  valid,
                pc,
                pc4,
                imm,
                rs2,
                rd,
                reg_wen,
                reg_wsel,
                alu_out,
                alu_sum,
                mem_type,
                mem_ren, mem_wen,
                csr_value,
        input   ready
    );

    modport hazzard(
        input   valid,
                reg_wen,
                rd,
                wdata,
                mem_ren
    );
endinterface


interface w_if();
    logic valid;
    logic ready;

    logic [31:0] pc;
    logic [31:0] pc4;
    logic [31:0] imm;
    rv::regaddr_t rd;
    logic reg_wen;
    reg_wsel_t reg_wsel;
    logic [31:0] alu_out;
    logic [31:0] alu_sum;
    logic [2:0] mem_type;
    logic [31:0] mem_rdata;
    logic [31:0] wdata;
    logic [31:0] csr_value;

    modport master(
        input   valid,
                pc,
                pc4,
                imm,
                rd,
                reg_wen,
                reg_wsel,
                alu_out,
                alu_sum,
                mem_type,
                mem_rdata,
                csr_value,
        output  wdata,
                ready
    );

    modport slave(
        output  valid,
                pc,
                pc4,
                imm,
                rd,
                reg_wen,
                reg_wsel,
                alu_out,
                alu_sum,
                mem_type,
                mem_rdata,
                csr_value,
        input   ready
    );

    modport hazzard(
        input   valid,
                reg_wen,
                rd,
                wdata
    );

    modport csr(
        input   valid
    );
endinterface
