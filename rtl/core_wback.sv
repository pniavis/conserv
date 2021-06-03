module core_wback(
    input  logic clk, rst,
    output rv::regaddr_t rf_waddr,
    output logic [31:0] rf_wdata,
    output logic rf_wen,
    w_if.master w
);

    logic [31:0] lu_out;
    core_load lu(
        .bus_in(w.mem_rdata), .reg_out(lu_out),
        .access_type(w.mem_type),
        .offset(w.alu_sum[1:0])
    );


    logic [31:0] wdata;
    always_comb begin
        case (w.reg_wsel)
        REG_WSEL_ALU: wdata = w.alu_out;
        REG_WSEL_IMM: wdata = w.imm;
        REG_WSEL_MEM: wdata = lu_out;
        REG_WSEL_PC : wdata = w.pc;
        REG_WSEL_PC4: wdata = w.pc + 32'h4;
        default     : wdata = 'x;
        endcase
    end

    assign rf_wen = w.valid && w.reg_wen;
    assign rf_waddr = w.rd;
    assign rf_wdata = wdata;

    assign w.ready = 1'b1;

endmodule