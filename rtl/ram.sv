module ram
#(parameter ADDR_WIDTH = 8, IMAGE = "")
(
    input clk,
    bus_if.slave bus
);

    logic [3:0][7:0] mem[0:2**ADDR_WIDTH - 1];
    logic [ADDR_WIDTH-1:0] local_waddr, local_raddr;

    assign local_raddr = bus.raddr[ADDR_WIDTH+1:2];
    assign local_waddr = bus.waddr[ADDR_WIDTH+1:2];

    initial if (IMAGE != 0) $readmemh(IMAGE, mem);
    
    always_ff @(posedge clk) begin
        if (bus.wen) begin
            if (bus.bytemask[0]) mem[local_waddr][0] <= bus.wdata[7:0];
            if (bus.bytemask[1]) mem[local_waddr][1] <= bus.wdata[15:8];
            if (bus.bytemask[2]) mem[local_waddr][2] <= bus.wdata[23:16];
            if (bus.bytemask[3]) mem[local_waddr][3] <= bus.wdata[31:24];
        end

        if (bus.ren) bus.rdata <= mem[local_raddr];
    end
endmodule
