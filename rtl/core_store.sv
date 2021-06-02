module core_store(
    input logic [2:0] access_type,
    input logic [1:0] offset,
    input  logic [31:0] reg_in,
    output logic [31:0] bus_out,
    output logic [3:0] bytemask
);
    always_comb begin
        unique case ({access_type[1:0], offset})
        4'b00_00: bytemask = 4'b0001;
        4'b00_01: bytemask = 4'b0010;
        4'b00_10: bytemask = 4'b0100;
        4'b00_11: bytemask = 4'b1000;
        4'b01_00: bytemask = 4'b0011;
        4'b01_10: bytemask = 4'b1100;
        4'b10_00: bytemask = 4'b1111;
        default : bytemask = 'x;
        endcase

        unique case ({access_type[1:0], offset})
        4'b00_00: bus_out = { 24'bx, reg_in[7:0] };
        4'b00_01: bus_out = { 16'bx, reg_in[7:0], 8'bx };
        4'b00_10: bus_out = { 8'bx, reg_in[7:0], 16'bx };
        4'b00_11: bus_out = { reg_in[7:0], 24'bx };
        4'b01_00: bus_out = { 16'bx, reg_in[15:0] };
        4'b01_10: bus_out = { reg_in[15:0], 16'bx };
        4'b10_00: bus_out = { reg_in[31:0] };
        default : bus_out = 'x;
        endcase
    end
endmodule