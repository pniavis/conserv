module device_virt_uart(
    input clk, rst,
    output TxD,
    bus_if.slave bus
);

    always_ff @(posedge clk) begin
        if (~rst) begin
            if (|bus.wen)
                $write("%c", bus.wdata[7:0]);
            if (bus.ren)
                bus.rdata <= '0;
        end
    end

endmodule