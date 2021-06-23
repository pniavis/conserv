module core_memory(
    input  logic clk, rst,
    bus_if.master bus,
    m_if.master m,
    w_if.slave w
);

    assign bus.ren = m.valid & m.mem_ren;
    assign bus.wen = m.valid & m.mem_wen;
    assign bus.raddr = m.alu_sum;
    assign bus.waddr = m.alu_sum;

    core_store su(
        .bus_out(bus.wdata), .reg_in(m.rs2),
        .bytemask(bus.bytemask),
        .access_type(m.mem_type),
        .offset(m.alu_sum[1:0])
    );

    logic [31:0] wdata;
    always_comb begin
        case (m.reg_wsel)
        REG_WSEL_ALU: wdata = m.alu_out;
        REG_WSEL_IMM: wdata = m.imm;
        REG_WSEL_PC : wdata = m.pc;
        REG_WSEL_PC4: wdata = m.pc4;
        REG_WSEL_CSR: wdata = m.csr_value;
        default     : wdata = 'x;
        endcase
    end

    assign m.ready = w.ready & 1'b1;
    assign m.wdata = wdata;
    assign w.mem_rdata = bus.rdata;
    always_ff @(posedge clk) begin
        casez ({rst, 1'b0, 1'b0, m.valid, w.ready, 1'b0})
        6'b000110: begin
                w.pc <= m.pc;
                w.pc4 <= m.pc4;
                w.imm <= m.imm;
                w.rd <= m.rd;
                w.reg_wen <= m.reg_wen;
                w.reg_wsel <= m.reg_wsel;
                w.alu_out <= m.alu_out;
                w.alu_sum <= m.alu_sum;
                w.mem_type <= m.mem_type;
                w.csr_value <= m.csr_value;
                w.valid <= 1;
            end
        6'b00??0?: begin
            end
        default  : begin
                w.valid <= 0;
            end
        endcase
    end

endmodule

