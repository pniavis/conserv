`include "core_alu.svh"
module core_execute(
    input  logic clk, rst,

    x_if.master x,
    m_if.slave m
);

    logic busy = 1'b0;

    logic [31:0] a, b;
    logic [31:0] alu_out;
    logic [31:0] alu_sum;

    always_comb begin : alu_select_a
        case (x.asel)
        ASEL_REG: a = x.rs1;
        ASEL_PC : a = x.pc;
        endcase
    end

    always_comb begin : alu_select_b
        case (x.bsel)
        BSEL_REG: b = x.rs2;
        BSEL_IMM: b = x.imm;
        endcase
    end

    core_alu alu(
        .a(a), .b(b), .op(x.aluop),
        .out(alu_out), .sum(alu_sum)
    );

    assign x.pc_new = alu_sum;

    assign x.ready = m.ready & ~busy;
    always_ff @(posedge clk) begin
        casez ({rst, 1'b0, 1'b0, x.valid, m.ready, busy})
        6'b000110: begin
                m.pc <= x.pc;
                m.imm <= x.imm;
                m.rs2 <= x.rs2;
                m.rd <= x.rd;
                m.reg_wen <= x.reg_wen;
                m.reg_wsel <= x.reg_wsel;
                m.alu_out <= alu_out;
                m.mem_type <= x.mem_type;
                m.mem_ren <= x.mem_ren;
                m.mem_wen <= x.mem_wen;
                m.valid <= 1;
            end
        6'b00??0?: begin
            end
        default  : begin
                m.valid <= 0;
            end
        endcase
    end

endmodule