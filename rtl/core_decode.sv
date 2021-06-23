`include "core_decoder.svh"

module core_decode(
    input   logic clk, rst,
    output  rv::regaddr_t rf_raddr1, rf_raddr2,
    input   logic [31:0] rf_rdata1, rf_rdata2,

    d_if.master d,
    x_if.slave x
);

    dec_t dec;
    core_decoder decoder(.ir(d.ir), .dec(dec));

    assign rf_raddr1 = dec.rs1_raw;
    assign rf_raddr2 = dec.rs2_raw;

    assign d.rs1 = dec.rs1;
    assign d.rs2 = dec.rs2;

    assign d.csr_addr = dec.csr_addr;

    assign d.ready = d.flush | (~d.stall & x.ready);
    always_ff @(posedge clk) begin
        casez ({rst, d.flush, d.stall, d.valid, x.ready, 1'b0})
        6'b000110: begin
                x.pc <= d.pc;
                x.imm <= dec.imm;
                x.rs1 <= rf_rdata1;
                x.rs2 <= rf_rdata2;
                x.rd <= dec.rd;
                x.reg_wen <= dec.reg_wen;
                x.reg_wsel <= dec.reg_wsel;
                x.aluop <= dec.aluop;
                x.asel <= dec.asel;
                x.bsel <= dec.bsel;
                x.mem_type <= dec.mem_type;
                x.mem_ren <= dec.mem_ren;
                x.mem_wen <= dec.mem_wen;
                x.is_jump <= dec.is_jump;
                x.is_branch <= dec.is_branch;
                x.branch_cond <= dec.branch_cond;
                x.csr_value <= d.csr_value;
                x.valid <= 1'b1;
            end
        6'b00??0?: begin
            end
        default  : begin
                x.valid <= 0;
            end
        endcase
    end

endmodule
