`include "core_alu.svh"
`include "core_decoder.svh"

module core_decoder(
    input rv::instr_t ir,
    output dec_t dec
);
    logic [31:0] imm;
    alu_op_t aluop_op, aluop_opimm;

    core_immgen immgen(.ir(ir), .out(imm));

    always_comb begin
        casez ({ir.funct3, ir.funct7[5]})
        {rv::FUNCT3_ADDSUB, 1'b0} : aluop_op = ALU_ADD;
        {rv::FUNCT3_ADDSUB, 1'b1} : aluop_op = ALU_SUB;
        {rv::FUNCT3_SLL,    1'b?} : aluop_op = ALU_SLL;
        {rv::FUNCT3_SLT,    1'b?} : aluop_op = ALU_SLT;
        {rv::FUNCT3_SLTU,   1'b?} : aluop_op = ALU_SLTU;
        {rv::FUNCT3_XOR,    1'b?} : aluop_op = ALU_XOR;
        {rv::FUNCT3_SR_LA,  1'b0} : aluop_op = ALU_SRL;
        {rv::FUNCT3_SR_LA,  1'b1} : aluop_op = ALU_SRA;
        {rv::FUNCT3_OR,     1'b?} : aluop_op = ALU_OR;
        {rv::FUNCT3_AND,    1'b?} : aluop_op = ALU_AND;
        default                   : aluop_op = alu_op_t'('x);
        endcase

        casez ({ir.funct3, ir.funct7[5]})
        {rv::FUNCT3_ADDSUB, 1'b?} : aluop_opimm = ALU_ADD;
        {rv::FUNCT3_SLL,    1'b?} : aluop_opimm = ALU_SLL;
        {rv::FUNCT3_SLT,    1'b?} : aluop_opimm = ALU_SLT;
        {rv::FUNCT3_SLTU,   1'b?} : aluop_opimm = ALU_SLTU;
        {rv::FUNCT3_XOR,    1'b?} : aluop_opimm = ALU_XOR;
        {rv::FUNCT3_SR_LA,  1'b0} : aluop_opimm = ALU_SRL;
        {rv::FUNCT3_SR_LA,  1'b1} : aluop_opimm = ALU_SRA;
        {rv::FUNCT3_OR,     1'b?} : aluop_opimm = ALU_OR;
        {rv::FUNCT3_AND,    1'b?} : aluop_opimm = ALU_AND;
        default                   : aluop_opimm = alu_op_t'('x);
        endcase
    end

    always_comb begin
        dec = 'x;

        unique case (ir.opcode)
        rv::OPCODE_OP:
            begin
                {dec.want_rs1, dec.want_rs2} = 2'b11;
                dec.reg_wen = 1'b1;
                dec.reg_wsel = REG_WSEL_ALU;
                dec.aluop = aluop_op;
                {dec.asel, dec.bsel} = {ASEL_REG, BSEL_REG};
                {dec.mem_ren, dec.mem_wen} = 2'b00;
                dec.is_jump = 1'b0;
                dec.is_branch = 1'b0;
            end
        rv::OPCODE_OPIMM:
            begin
                {dec.want_rs1, dec.want_rs2} = 2'b10;
                dec.reg_wen = 1'b1;
                dec.reg_wsel = REG_WSEL_ALU;
                dec.aluop = aluop_opimm;
                {dec.asel, dec.bsel} = {ASEL_REG, BSEL_IMM};
                {dec.mem_ren, dec.mem_wen} = 2'b00;
                dec.is_jump = 1'b0;
                dec.is_branch = 1'b0;
            end
        rv::OPCODE_LOAD:
            begin
                {dec.want_rs1, dec.want_rs2} = 2'b10;
                dec.reg_wen = 1'b1;
                dec.reg_wsel = REG_WSEL_MEM;
                {dec.asel, dec.bsel} = {ASEL_REG, BSEL_IMM};
                {dec.mem_ren, dec.mem_wen} = 2'b10;
                dec.is_jump = 1'b0;
                dec.is_branch = 1'b0;
            end
        rv::OPCODE_STORE:
            begin
                {dec.want_rs1, dec.want_rs2} = 2'b11;
                dec.reg_wen = 1'b0;
                {dec.asel, dec.bsel} = {ASEL_REG, BSEL_IMM};
                {dec.mem_ren, dec.mem_wen} = 2'b01;
                dec.is_jump = 1'b0;
                dec.is_branch = 1'b0;
            end
        rv::OPCODE_LUI:
            begin
                {dec.want_rs1, dec.want_rs2} = 2'b00;
                dec.reg_wen = 1'b1;
                dec.reg_wsel = REG_WSEL_IMM;
                {dec.mem_ren, dec.mem_wen} = 2'b00;
                dec.is_jump = 1'b0;
                dec.is_branch = 1'b0;
            end
        rv::OPCODE_AUIPC:
            begin
                {dec.want_rs1, dec.want_rs2} = 2'b00;
                dec.reg_wen = 1'b1;
                dec.reg_wsel = REG_WSEL_ALU;
                dec.aluop = ALU_ADD;
                {dec.asel, dec.bsel} = {ASEL_PC, BSEL_IMM};
                {dec.mem_ren, dec.mem_wen} = 2'b00;
                dec.is_jump = 1'b0;
                dec.is_branch = 1'b0;
            end
        rv::OPCODE_JAL:
            begin
                {dec.want_rs1, dec.want_rs2} = 2'b00;
                dec.reg_wen = 1'b1;
                dec.reg_wsel = REG_WSEL_PC4;
                {dec.asel, dec.bsel} = {ASEL_PC, BSEL_IMM};
                {dec.mem_ren, dec.mem_wen} = 2'b00;
                dec.is_jump = 1'b1;
                dec.is_branch = 1'b0;
            end
        rv::OPCODE_JALR:
            begin
                {dec.want_rs1, dec.want_rs2} = 2'b10;
                dec.reg_wen = 1'b1;
                dec.reg_wsel = REG_WSEL_PC4;
                {dec.asel, dec.bsel} = {ASEL_REG, BSEL_IMM};
                {dec.mem_ren, dec.mem_wen} = 2'b00;
                dec.is_jump = 1'b1;
                dec.is_branch = 1'b0;
            end
        rv::OPCODE_BRANCH:
            begin
                {dec.want_rs1, dec.want_rs2} = 2'b11;
                dec.reg_wen = 1'b0;
                {dec.asel, dec.bsel} = {ASEL_PC, BSEL_IMM};
                {dec.mem_ren, dec.mem_wen} = 2'b00;
                dec.is_jump = 1'b0;
                dec.is_branch = 1'b1;
                dec.branch_cond = rv::funct3b_t'(ir.funct3);
            end
        default:
            begin
                //FIXME invalid op
            end
        endcase

        {dec.rs1, dec.rs2, dec.rd} = {ir.rs1, ir.rs2, ir.rd};
        dec.imm = imm;
        dec.mem_type = ir.funct3;
    end

endmodule
