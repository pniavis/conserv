module programmer(
    input  logic clk, rst_in,
    input  logic data_tick,
    input  logic [7:0] data,
    output logic rst_out,
    bus_if.master_wronly rom_bus);

    localparam logic [7:0] START_SYM = "s";
    localparam logic [7:0] END_SYM = "e";
    localparam logic [7:0] ESC_SYM = "q";

    enum logic [1:0] {
        STATE_START,
        STATE_DATA,
        STATE_DATA_ESC,
        STATE_END
    } state = STATE_START;
    
    logic [29:0] prog_addr;
    logic [31:0] prog_data;
    logic [2:0] counter;

    always_ff @(posedge clk) begin
        rom_bus.wen <= 1'b0;
        if (rom_bus.wen)
            prog_addr <= prog_addr + 1;

        if (rst_in) begin
            state <= STATE_START;
            counter <= 0;
            prog_addr <= 0;
        end else begin
            if (data_tick) case (state)
            STATE_START: begin
                    if (data == START_SYM) begin
                        if (counter != 3'd4)
                            counter <= counter + 1;
                    end else begin
                        if (counter == 3'd4) begin
                            state <= STATE_DATA;
                            prog_addr <= 0;
                        end
                        counter <= 0;
                    end
                end
            STATE_DATA: begin
                    if (data == ESC_SYM) begin
                        state <= STATE_DATA_ESC;
                    end else if (data == START_SYM) begin
                        state <= STATE_START;
                    end else if (data == END_SYM) begin
                        state <= STATE_END;
                    end else begin
                        counter <= counter[1:0] + 2'b1;
                        prog_data <= {data, prog_data[31:8]};
                        rom_bus.wen <= counter[1:0] == 2'b11;
                    end
                end
            STATE_DATA_ESC: begin
                    counter <= counter[1:0] + 2'b1;
                    prog_data <= {data, prog_data[31:8]};
                    rom_bus.wen <= counter[1:0] == 2'b11;
                    state <= STATE_DATA;
                end
            STATE_END: begin
                    state <= STATE_START;
                    counter <= 0;
                end
            endcase
        end
    end

    assign rom_bus.waddr = {prog_addr, 2'b00};
    assign rom_bus.wdata = prog_data;
    assign rst_out = state != STATE_START;

endmodule