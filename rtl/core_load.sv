module core_load(
    input logic [2:0] access_type,
    input logic [1:0] offset,
    input  logic [31:0] bus_in,
    output logic [31:0] reg_out
);
    always_comb begin
        case ({access_type[1:0], offset})
        4'b00_00: reg_out = { 24'b0, bus_in[7:0] };
        4'b00_01: reg_out = { 24'b0, bus_in[15:8] };
        4'b00_10: reg_out = { 24'b0, bus_in[23:16] };
        4'b00_11: reg_out = { 24'b0, bus_in[31:24] };
        4'b01_00: reg_out = { 16'b0, bus_in[15:0] };
        4'b01_10: reg_out = { 16'b0, bus_in[31:16] };
        4'b10_00: reg_out = { bus_in[31:0] };
        default : reg_out = 'x;
        endcase

        case (access_type)
        3'b000 : reg_out[31:8]  = { 24{reg_out[7]} };
        3'b001 : reg_out[31:16] = { 16{reg_out[15]} };
        default: begin end
        endcase
    end
endmodule