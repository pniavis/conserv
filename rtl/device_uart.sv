module device_uart(
    input clk, rst,
    output TxD,
    bus_if.slave bus
);

    localparam ADDR_WIDTH = 8;

    logic [7:0] uart_data;
    logic uart_start;
    logic uart_busy;
    logic fifo_read, fifo_write;
    logic fifo_full, fifo_empty;
    logic [ADDR_WIDTH-1:0] fifo_addr_r;
    logic [ADDR_WIDTH-1:0] fifo_addr_w;

    fifo_controller #(.ADDR_WIDTH(ADDR_WIDTH)) fifo(
                .clk(clk), .rst(rst),
                .read(fifo_read), .write(fifo_write),
                .full(fifo_full), .empty(fifo_empty),
                .addr_r(fifo_addr_r), .addr_w(fifo_addr_w));
    uart_tx uart(.clk(clk), .rst(rst), .data(uart_data),
                .start(uart_start), .busy(uart_busy), .TxD(TxD));

    logic [7:0] buffer[0:2**ADDR_WIDTH-1];

    always_ff @(posedge clk) begin
        if (rst) begin
        end else begin
            if (|bus.wen) begin
                buffer[fifo_addr_w] <= bus.wdata[7:0];
                fifo_write <= 1'b1;
            end else begin
                fifo_write <= 1'b0;
            end

            if (bus.ren)
                bus.rdata <= { 31'b0, fifo_full };
        end
    end

    always_ff @(posedge clk) begin
        if (~fifo_empty && ~uart_busy && ~uart_start) begin
            uart_data <= buffer[fifo_addr_r];
            uart_start <= 1'b1;
            fifo_read <= 1'b1;
        end else begin
            uart_start <= 1'b0;
            fifo_read <= 1'b0;
        end
    end

endmodule


module uart_tx(
    input logic clk, rst,
    input logic [7:0] data,
    input logic start,
    output logic busy,
    output logic TxD
);

    logic bit_tick;
    baud_generator brgen(
        .clk(clk), .enable(busy), .tick(bit_tick));

    logic [3:0] bit_cnt;
    logic [9:0] sreg;

    always_ff @(posedge clk) begin
        if (rst) begin
            busy <= 0;
            TxD <= 1;
        end else begin
            if (start) begin
                sreg <= { 1'b1, data, 1'b0 };
                bit_cnt <= 0;
                busy <= 1'b1;
            end
            if (busy && bit_tick) begin
                TxD <= sreg[0];
                sreg <= sreg >> 1;
                if (bit_cnt == 9) begin
                    busy <= 1'b0;
                end else begin
                    bit_cnt <= bit_cnt + 1;
                end
            end

        end
    end

endmodule


module baud_generator(
    input clk,
    input enable,
    output tick
);

    logic [20:0] v = 0;
    assign tick = v[20];

    always_ff @(posedge clk)
        if (enable)
            v <= v[19:0] + 20'd201;
        else
            v <= 0;

endmodule


module fifo_controller
#(parameter ADDR_WIDTH = 8)
(
    input  logic clk, rst,
    input  logic read, write,
    output logic full, empty,
    output logic [ADDR_WIDTH-1:0] addr_r,
    output logic [ADDR_WIDTH-1:0] addr_w)
;
     
    always_ff @(posedge clk) begin
        if (rst) begin
            addr_r <= 0;
            addr_w <= 0;
        end else begin
            if (read && !empty)
                addr_r <= addr_r + 1;
            if (write && !full)
                addr_w <= addr_w + 1;
        end
    end

    logic [ADDR_WIDTH-1:0] rminusw;
    assign rminusw = addr_r - addr_w;

    assign full = (rminusw == 1);
    assign empty = (addr_r == addr_w);

endmodule