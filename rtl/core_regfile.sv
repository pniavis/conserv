module core_regfile(
    input  logic clk, rst,
    input  logic [4:0] raddr1, raddr2, waddr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata1, rdata2,
    input  logic wen
);

    logic [31:0] file[0:31];

    always_ff @(posedge clk) begin
        if (wen) file[waddr] <= wdata;
    end
    
    assign rdata1 = (raddr1 == 0) ? 32'h0 : file[raddr1];
    assign rdata2 = (raddr2 == 0) ? 32'h0 : file[raddr2];

endmodule
