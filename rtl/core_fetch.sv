module core_fetch
#(logic [31:0] RESET_ADDR = 32'h0)
(
    input  logic clk, rst,
    f_if.master f,
    d_if.slave d,
    bus_if.master bus
);
    logic [31:0] pc, pc_next;

    assign bus.raddr = pc_next;
    assign bus.ren = d.ready;

    always_comb begin
        if (f.pc_load)
            pc_next = f.pc_new;
        else
            pc_next = pc + 32'd4;
    end

    always_ff @(posedge clk) begin
        if (rst)
            pc <= RESET_ADDR - 32'd4;
        else if (d.ready)
            pc <= pc_next;
    end

    assign d.ir = bus.rdata;
    always_ff @(posedge clk) begin
        if (rst) begin
            d.valid <= 0;
        end else if (d.ready) begin
            d.valid <= 1'b1;
            d.pc <= pc_next;
        end
    end

endmodule