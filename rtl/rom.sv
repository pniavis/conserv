module rom
#(parameter ADDR_WIDTH = 8, IMAGE = "")
(
    input clk,
    bus_if.slave bus0,
    bus_if.slave bus1
);

    logic [3:0][7:0] mem[0:2**ADDR_WIDTH - 1];
    logic [ADDR_WIDTH-1:0] local_raddr0, local_raddr1;

    assign local_raddr0 = bus0.raddr[ADDR_WIDTH+1:2];
    assign local_raddr1 = bus1.raddr[ADDR_WIDTH+1:2];
    
    initial $readmemh(IMAGE, mem);

    always_ff @(posedge clk) begin
       if (bus0.ren) bus0.rdata <= mem[local_raddr0];
       if (bus1.ren) bus1.rdata <= mem[local_raddr1];
    end
endmodule
