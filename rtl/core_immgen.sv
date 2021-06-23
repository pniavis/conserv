module core_immgen(
    input  logic [31:0] ir,
    output logic [31:0] out
);
    logic [31:0] immi, imms, immb, immu, immj;

    assign immi = { {20{ir[31]}}, ir[31:20] };
    assign imms = { {20{ir[31]}}, ir[31:25], ir[11:7] };
    assign immb = { {19{ir[31]}}, ir[31], ir[7], ir[30:25], ir[11:8], 1'b0 };
    assign immu = { ir[31:12], 12'b0 };
    assign immj = { {11{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21], 1'b0 };


    always_comb begin
        case (ir[6:2])
        rv::OPCODE_OPIMM : out = immi;
        rv::OPCODE_LOAD  : out = immi;
        rv::OPCODE_STORE : out = imms;
        rv::OPCODE_BRANCH: out = immb;
        rv::OPCODE_LUI   : out = immu;
        rv::OPCODE_AUIPC : out = immu;
        rv::OPCODE_JALR  : out = immi;
        rv::OPCODE_JAL   : out = immj;
        rv::OPCODE_SYSTEM: out = immi;
        default          : out = 'x;
        endcase
    end

endmodule
