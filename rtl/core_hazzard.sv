module core_hazzard(
    d_if.hazzard d,
    x_if.hazzard x,
    m_if.hazzard m,
    w_if.hazzard w
);

    always_comb begin
        d.stall = 1'b0;
        d.stall |= x.valid & x.reg_wen & (x.rd != 0) & (d.rs1 == x.rd);
        d.stall |= x.valid & x.reg_wen & (x.rd != 0) & (d.rs2 == x.rd);
        d.stall |= m.valid & m.mem_ren & (m.rd != 0) & (d.rs1 == m.rd);
        d.stall |= m.valid & m.mem_ren & (m.rd != 0) & (d.rs2 == m.rd);
        d.stall &= d.valid & ~d.flush;
    end

    always_comb begin
        logic fwd_rs1_w, fwd_rs2_w;
        logic fwd_rs1_m, fwd_rs2_m;

        fwd_rs1_m = m.valid & m.reg_wen & ~m.mem_ren
                        & m.rd != 0 & (m.rd == d.rs1);
        fwd_rs2_m = m.valid & m.reg_wen & ~m.mem_ren
                        & m.rd != 0 & (m.rd == d.rs2);

        fwd_rs1_w = w.valid & w.reg_wen & w.rd != 0 & (w.rd == d.rs1);
        fwd_rs2_w = w.valid & w.reg_wen & w.rd != 0 & (w.rd == d.rs2);

        d.fwd_value1 = 'x;
        d.fwd_rs1en = fwd_rs1_m | fwd_rs1_w;
        if (fwd_rs1_w)
            d.fwd_value1 = w.wdata;
        if (fwd_rs1_m)
            d.fwd_value1 = m.wdata;

        d.fwd_value2 = 'x;
        d.fwd_rs2en = fwd_rs2_m | fwd_rs2_w;
        if (fwd_rs2_w)
            d.fwd_value2 = w.wdata;
        if (fwd_rs2_m)
            d.fwd_value2 = m.wdata;
    end

endmodule