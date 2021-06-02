`include "core_alu.svh"
module core_alu
(
    input  logic [31:0] a, b,
    output logic [31:0] out,
    output logic [31:0] sum,
    input  alu_op_t op
);

    logic [31:0] result;
    logic lt, ltu;

    assign lt = $signed(a) < $signed(b);
    assign ltu = a < b;

    always_comb begin
        casez (op)
        ALU_ADD:    result = a + b;
        ALU_SUB:    result = a - b;
        ALU_XOR:    result = a ^ b;
        ALU_OR:     result = a | b;
        ALU_AND:    result = a & b;
        ALU_SLT:    result = {31'b0, lt};
        ALU_SLTU:   result = {31'b0, ltu};
        ALU_SLL:    result = a << b[4:0];
        ALU_SRL:    result = a >> b[4:0];
        ALU_SRA:    result = $signed(a) >>> b[4:0];
        ALU_OUTB:   result = b;
        default:    result = 'x;
        endcase
    end

    assign out = result;
    assign sum = a + b;

endmodule