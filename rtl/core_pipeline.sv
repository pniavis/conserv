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
    logic want_rs1, want_rs2;
    rv::regaddr_t rs1, rs2;

    modport master(
        input   valid,
                pc,
                ir,
                stall,
                flush,
        output  ready,
                want_rs1, rs1,
                want_rs2, rs2
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
                want_rs1, rs1,
                want_rs2, rs2,
        output  stall
    );

    modport branch(
        output  flush
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
        input   ready
    );

    modport hazzard(
        input   valid,
                reg_wen,
                rd
    );

    modport branch(
        input   valid,
                pc_new,
                rs1, rs2,
                is_jump,
                is_branch,
                branch_cond
    );
endinterface


interface m_if();
    logic valid;
    logic ready;

    logic [31:0] pc;
    logic [31:0] imm;
    logic [31:0] rs2;
    rv::regaddr_t rd;
    logic reg_wen;
    reg_wsel_t reg_wsel;
    logic [31:0] alu_out;
    logic [31:0] alu_sum;
    logic [2:0] mem_type;
    logic mem_ren, mem_wen;

    modport master(
        input   valid,
                pc,
                imm,
                rs2,
                rd,
                reg_wen,
                reg_wsel,
                alu_out,
                alu_sum,
                mem_type,
                mem_ren, mem_wen,
        output  ready
    );

    modport slave(
        output  valid,
                pc,
                imm,
                rs2,
                rd,
                reg_wen,
                reg_wsel,
                alu_out,
                alu_sum,
                mem_type,
                mem_ren, mem_wen,
        input   ready
    );

    modport hazzard(
        input   valid,
                reg_wen,
                rd
    );
endinterface


interface w_if();
    logic valid;
    logic ready;

    logic [31:0] pc;
    logic [31:0] imm;
    rv::regaddr_t rd;
    logic reg_wen;
    reg_wsel_t reg_wsel;
    logic [31:0] alu_out;
    logic [31:0] alu_sum;
    logic [2:0] mem_type;
    logic [31:0] mem_rdata;

    modport master(
        input   valid,
                pc,
                imm,
                rd,
                reg_wen,
                reg_wsel,
                alu_out,
                alu_sum,
                mem_type,
                mem_rdata,
        output  ready
    );

    modport slave(
        output  valid,
                pc,
                imm,
                rd,
                reg_wen,
                reg_wsel,
                alu_out,
                alu_sum,
                mem_type,
                mem_rdata,
        input   ready
    );

    modport hazzard(
        input   valid,
                reg_wen,
                rd
    );
endinterface
