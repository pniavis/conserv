module device_virt_uart(
    input clk, rst,
    output TxD,
    bus_if.slave bus
);

    always_ff @(posedge clk) begin
        if (~rst) begin
            if (bus.wen && bus.waddr[2] == 1'b1)
                $write("%c", bus.wdata[7:0]);
            if (bus.ren && bus.raddr[2] == 1'b0)
                bus.rdata <= {30'h0, 1'b1, 1'b1};
            if (bus.ren && bus.raddr[2] == 1'b1)
                bus.rdata <= 0;
        end
    end

endmodule