module rom
#(parameter ADDR_WIDTH = 8, IMAGE = "")
(
    input clk,
    bus_if.slave bus0,
    bus_if.slave bus1
);

    logic [31:0] mem[0:2**ADDR_WIDTH - 1];

    logic [ADDR_WIDTH-1:0] local_addr1;
    assign local_addr1 = bus1.raddr[ADDR_WIDTH+1:2];

    logic [ADDR_WIDTH-1:0] local_raddr0, local_waddr0;
    logic [ADDR_WIDTH-1:0] local_addr0;
    assign local_raddr0 = bus0.raddr[ADDR_WIDTH+1:2];
    assign local_waddr0 = bus0.waddr[ADDR_WIDTH+1:2];
    assign local_addr0 = bus0.wen ? local_waddr0 : local_raddr0;
    
    initial $readmemh(IMAGE, mem);

    always_ff @(posedge clk) begin
        bus1.rdata <= mem[local_addr1];
       
        if (bus0.wen) begin
            mem[local_addr0] <= bus0.wdata;
            bus0.rdata <= bus0.wdata;
        end else begin
            bus0.rdata <= mem[local_addr0];
        end
    end
endmodule
