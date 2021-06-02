module bus_controller(
    input clk,
    bus_if.slave cpu,
    bus_if.master ram,
    bus_if.master rom,
    bus_if.master uart
);

    localparam [3:0] RAM_ID     = 0;
    localparam [3:0] ROM_ID     = 1;
    localparam [3:0] UART_ID    = 2;

    logic [31:0] raddr, waddr;
    logic [31:0] raddr_prev;
    logic [31:0] rdata, wdata;
    logic [3:0] bytemask;
    logic ren, wen;
    logic [3:0] rid, wid;

    always_comb begin
        ren = cpu.ren;
        raddr = cpu.raddr;
        wen = cpu.wen;
        waddr = cpu.waddr;
        bytemask = cpu.bytemask;
        wdata = cpu.wdata;

        rid = raddr[31:28];
        wid = waddr[31:28];

        ram.raddr = raddr;
        ram.ren = ren & (rid == RAM_ID);
        ram.waddr = waddr;
        ram.wen = wen & (wid == RAM_ID);
        ram.bytemask = bytemask;
        ram.wdata = wdata;

        rom.raddr = raddr;
        rom.ren = ren & (rid == ROM_ID);

        uart.raddr = raddr;
        uart.ren = ren & (rid == UART_ID);
        uart.waddr = waddr;
        uart.wen = wen & (wid == UART_ID);
        uart.bytemask = bytemask;
        uart.wdata = wdata;

        case (raddr_prev[31:28])
        RAM_ID  : rdata = ram.rdata;
        ROM_ID  : rdata = rom.rdata;
        UART_ID : rdata = uart.rdata;
        default : rdata = 'x;
        endcase

        cpu.rdata = rdata;
    end

    always_ff @(posedge clk)
        raddr_prev <= raddr;

endmodule