module top(
`ifdef SYNTHESIS
    input  logic clk,
    input  logic [0:0] sw,
    input  logic [0:0] key,
    input  logic RxD,
    output logic TxD,
    output logic led
`else
    input  logic clk,
    input  logic rst,
    output logic TxD
`endif
);

`ifdef SYNTHESIS
    logic [2:0] rst_sync = 3'b111;
    always_ff @(posedge clk)
    rst_sync = {rst_sync[1:0], ~sw[0]};

    logic master_rst;
    logic prog_rst;
    logic rst;

    assign master_rst = rst_sync[2];
    assign rst = master_rst | prog_rst;

    assign led = prog_rst;
`endif

    bus_if rom_bus_data();
    bus_if rom_bus_instr();
    rom #(.IMAGE("imem.ram"), .ADDR_WIDTH(14)) rom0(
        .clk(clk),
        .bus1(rom_bus_instr.slave),
        .bus0(rom_bus_data.slave)
    );

    bus_if ram_bus();
    ram #(.ADDR_WIDTH(14)) ram0(
        .clk(clk), .bus(ram_bus.slave)
    );

    bus_if uart_bus();
`ifdef SYNTHESIS
    logic [7:0] uart_rx_data;
    logic uart_rx_tick;
    device_uart uart(
        .clk(clk), .rst(master_rst),
        .TxD(TxD), .RxD(RxD),
        .rx_data(uart_rx_data),
        .rx_tick(uart_rx_tick),
        .bus(uart_bus.slave)
    );
`else
    device_virt_uart uart(
        .clk(clk), .rst(rst),
        .TxD(), .bus(uart_bus.slave)
    );
`endif

    bus_if core_data_bus();
    core_cpu cpu(
        .clk(clk), .rst(rst),
        .instr_bus(rom_bus_instr.master_rdonly),
        .data_bus(core_data_bus.master)
    );

    bus_controller bus_ctrl(
        .clk(clk),
        .cpu(core_data_bus.slave),
        .ram(ram_bus.master),
        .rom(rom_bus_data.master_rdonly),
        .uart(uart_bus)
    );

`ifdef SYNTHESIS
    programmer rom_prog(
        .clk(clk), .enable(key[0]),
        .rst_in(master_rst), .rst_out(prog_rst),
        .data(uart_rx_data), .data_tick(uart_rx_tick),
        .rom_bus(rom_bus_data.master_wronly)
    );
`else
    assign rom_bus_data.wen = 1'b0;
`endif


`ifndef SYNTHESIS
    logic [15:0] cycle = '0;
    always_ff @(posedge clk) begin
        if (0 && ~rst) begin
            $display("=============%04d================", cycle);
            $display("F:\t",
                        "pc=%08x\n\t",
                        cpu.fetch.pc,
                        "pc_load=%d pc_new=%08x",
                        cpu.f.pc_load, cpu.f.pc_new
                        );
            $display("D:%b%b\t", cpu.d.valid, cpu.d.ready,
                        "pc=%08x ir=%08x stall=%b flush=%b\n\t",
                        cpu.d.pc, cpu.d.ir, cpu.d.stall, cpu.d.flush,
                        "rs1=%02x rs2=%02x rd=%02x imm=%08x",
                        cpu.decode.dec.rs1, cpu.decode.dec.rs2,
                        cpu.decode.dec.rd, cpu.decode.dec.imm);
            $display("X:%b%b\t", cpu.x.valid, cpu.x.ready,
                        "pc=%08x, aluop=%0x a=%08x(%0x) b=%08x(%0x)\n\t",
                        cpu.x.pc, cpu.x.aluop, cpu.execute.a,
                        cpu.x.asel, cpu.execute.b, cpu.x.bsel,
                        "jb=%b%b brcond=%0x op=%08x,%08x",
                        cpu.x.is_jump, cpu.x.is_branch,
                        cpu.x.branch_cond, cpu.x.rs1, cpu.x.rs2);
            $display("M:%b%b\t", cpu.m.valid, cpu.m.ready,
                        "rw=%b%b addr=%08x wdata=%08x type=%0x",
                        cpu.m.mem_ren, cpu.m.mem_wen, cpu.m.alu_out,
                        cpu.m.rs2, cpu.m.mem_type);
            $display("W:%b%b\t", cpu.w.valid, cpu.w.ready,
                        "w=%b rd=%02x wdata=%08x(%0x)",
                        cpu.w.reg_wen, cpu.w.rd, cpu.wback.wdata, cpu.w.reg_wsel);
                        
            $display("===REG===");
            if (1) for (integer i = 0; i < 32; i += 1) begin
                $write("x%02d=%08x", i, cpu.rf.file[i]);
                if (i % 4 == 3)
                    $write("\n");
                else
                    $write(" ");
            end
            $display();

            cycle <= cycle + 1;
        end
    end

    final begin
        integer i;

        $display("\n============RESULT===============");
        for (i = 0; i < 32; i += 1) begin
            $write("x%02d=%08x", i, cpu.rf.file[i]);
            if (i % 4 == 3)
                $write("\n");
            else
                $write(" ");
        end
        $display();
        for (i = 0; i < 32; i += 1) begin
            $write("m%02d=%08x", i, ram0.mem[i]);
            if (i % 4 == 3)
                $write("\n");
            else
                $write(" ");
        end
    end
`endif

endmodule
