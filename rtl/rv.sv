package rv;

    typedef enum logic [4:0] {
        OPCODE_OP        = 5'b01100,
        OPCODE_OPIMM     = 5'b00100,
        OPCODE_LOAD      = 5'b00000,
        OPCODE_STORE     = 5'b01000,
        OPCODE_BRANCH    = 5'b11000,
        OPCODE_JAL       = 5'b11011,
        OPCODE_JALR      = 5'b11001,
        OPCODE_LUI       = 5'b01101,
        OPCODE_AUIPC     = 5'b00101
    } opcode_t;
    
    typedef logic [4:0] regaddr_t;
    typedef logic [6:0] funct7_t;
    typedef logic [2:0] funct3_t;
    
    typedef struct packed {
      funct7_t funct7;
      regaddr_t rs2;
      regaddr_t rs1;
      funct3_t funct3;
      regaddr_t rd;
      opcode_t opcode;
      logic [1:0] zero;
    } instr_t;
    
    typedef enum logic [2:0] {
        FUNCT3_ADDSUB    = 3'b000,
        FUNCT3_SLL       = 3'b001,
        FUNCT3_SLT       = 3'b010,
        FUNCT3_SLTU      = 3'b011,
        FUNCT3_XOR       = 3'b100,
        FUNCT3_SR_LA     = 3'b101,
        FUNCT3_OR        = 3'b110,
        FUNCT3_AND       = 3'b111
    } funct3r_t;

    typedef enum logic [2:0] {
        FUNCT3_ADDI      = 3'b000,
        FUNCT3_SLLI      = 3'b001,
        FUNCT3_SLTI      = 3'b010,
        FUNCT3_SLTIU     = 3'b011,
        FUNCT3_XORI      = 3'b100,
        FUNCT3_SR_LA_I   = 3'b101,
        FUNCT3_ORI       = 3'b110,
        FUNCT3_ANDI      = 3'b111
    } funct3i_t;

    typedef enum logic [2:0] {
        FUNCT3_BEQ       = 3'b000,
        FUNCT3_BNE       = 3'b001,
        FUNCT3_BLT       = 3'b100,
        FUNCT3_BGE       = 3'b101,
        FUNCT3_BLTU      = 3'b110,
        FUNCT3_BGEU      = 3'b111
    } funct3b_t;

    localparam INSTR_NOP = 32'h00000013;

endpackage