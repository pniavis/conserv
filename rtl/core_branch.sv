module core_branch(
    f_if.branch f,
    d_if.branch d,
    x_if.branch x
);
    logic is_brj;
    logic fire;

    logic lt, ltu, eq;
    logic satisfied;

    assign lt = $signed(x.rs1) < $signed(x.rs2);
    assign ltu = x.rs1 < x.rs2;
    assign eq = x.rs1 == x.rs2;

    always_comb begin
        unique case (x.branch_cond)
        rv::FUNCT3_BEQ : satisfied = eq;
        rv::FUNCT3_BNE : satisfied = ~eq;
        rv::FUNCT3_BLT : satisfied = lt;
        rv::FUNCT3_BGE : satisfied = ~lt;
        rv::FUNCT3_BLTU: satisfied = ltu;
        rv::FUNCT3_BGEU: satisfied = ~ltu;
        default        : satisfied = 1'bx;
        endcase
    end

    always_comb begin
        is_brj = x.valid & (x.is_branch | x.is_jump);
        fire = x.is_jump | (x.is_branch & satisfied);
    end

    always_comb begin
        d.flush = 1'b0;
        d.predicted_taken = 1'b0;
        f.pc_load = 1'b0;
        f.pc_new = 'x;

        if (is_brj) begin
            if(fire & !x.predicted_taken) begin
                d.flush = 1'b1;
                f.pc_load = 1'b1;
                f.pc_new = x.pc_new;
            end else if(!fire & x.predicted_taken) begin
                d.flush = 1'b1;
                f.pc_load = 1'b1;
                f.pc_new = x.pc + 32'd4;
            end
        end else if (d.valid & d.is_branch & d.imm[31]) begin
            f.pc_load = 1'b1;
            f.pc_new = d.pc + d.imm;
            d.predicted_taken = 1'b1;
        end
    end
endmodule
