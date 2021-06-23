module core_hazzard(
    d_if.hazzard d,
    x_if.hazzard x,
    m_if.hazzard m,
    w_if.hazzard w
);

    always_comb begin
        d.stall = 1'b0;
        d.stall |= (d.rs1 != 0) & x.valid & x.reg_wen & (d.rs1 == x.rd);
        d.stall |= (d.rs2 != 0) & x.valid & x.reg_wen & (d.rs2 == x.rd);
        d.stall |= (d.rs1 != 0) & m.valid & m.reg_wen & (d.rs1 == m.rd);
        d.stall |= (d.rs2 != 0) & m.valid & m.reg_wen & (d.rs2 == m.rd);
        d.stall |= (d.rs1 != 0) & w.valid & w.reg_wen & (d.rs1 == w.rd);
        d.stall |= (d.rs2 != 0) & w.valid & w.reg_wen & (d.rs2 == w.rd);
        d.stall &= d.valid & ~d.flush;
    end

endmodule