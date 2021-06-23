module core_csr(
    input  logic clk,
    input  logic rst,
    d_if.csr d,
    w_if.csr w
);

    logic [31:0] cycle;
    logic [31:0] instret;

    always_ff @(posedge clk) begin
        if (rst) begin
            cycle <= '0;
            instret <= 0;
        end else begin
            cycle <= cycle + 32'd1;
            if (w.valid)
                instret <= instret + 1;
        end
    end

    logic [31:0] csr_value;
    always_comb begin
        case (d.csr_addr)
        rv::CSR_CYCLE   : csr_value = cycle;
        rv::CSR_INSTRET : csr_value = instret;
        default         : csr_value = 'x;
        endcase
    end

    assign d.csr_value = csr_value;

endmodule