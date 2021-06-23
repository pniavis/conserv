module core_cpu
#(RESET_ADDR=32'h10000000)
(
    input  logic clk, rst,
    bus_if.master instr_bus,
    bus_if.master data_bus
);

    logic [4:0] rf_raddr1, rf_raddr2, rf_waddr;
    logic [31:0] rf_rdata1, rf_rdata2, rf_wdata;
    logic rf_wen;

    core_regfile rf(
        .clk(clk), .rst(rst),
        .raddr1(rf_raddr1), .raddr2(rf_raddr2),
        .rdata1(rf_rdata1), .rdata2(rf_rdata2),
        .waddr(rf_waddr), .wdata(rf_wdata), .wen(rf_wen)
    );

    f_if f();
    d_if d();
    x_if x();
    m_if m();
    w_if w();

    core_fetch #(.RESET_ADDR(RESET_ADDR)) fetch(
        .clk(clk), .rst(rst),
        .bus(instr_bus),
        .f(f.master), .d(d.slave)
    );

    core_decode decode(
        .clk(clk), .rst(rst),
        .d(d.master), .x(x.slave),
        .rf_raddr1(rf_raddr1), .rf_raddr2(rf_raddr2),
        .rf_rdata1(rf_rdata1), .rf_rdata2(rf_rdata2)
    );

    core_execute execute(
        .clk(clk), .rst(rst),
        .x(x.master), .m(m.slave)
    );

    core_memory memory(
        .clk(clk), .rst(rst),
        .bus(data_bus),
        .m(m.master), .w(w.slave)
    );

    core_wback wback(
        .clk(clk), .rst(rst),
        .w(w.master),
        .rf_waddr(rf_waddr), .rf_wdata(rf_wdata),
        .rf_wen(rf_wen)
    );

    core_branch branch(
        .f(f.branch),
        .d(d.branch),
        .x(x.branch)
    );

    core_hazzard hazzard(
        .d(d.hazzard), .x(x.hazzard),
        .m(m.hazzard), .w(w.hazzard)
    );

    core_csr csr(
        .clk(clk), .rst(rst),
        .d(d.csr), .w(w.csr)
    );

endmodule