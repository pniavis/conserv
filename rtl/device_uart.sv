module device_uart(
    input  logic clk, rst,
    input  logic RxD,
    output logic TxD,
    bus_if.slave bus,
    output logic [7:0] rx_data,
    output logic rx_tick
);

    localparam ADDR_WIDTH = 8;

    logic [7:0] txbuffer[0:2**ADDR_WIDTH-1];
    logic [7:0] txuart_data;
    logic txuart_start, txuart_busy;
    logic txfifo_read, txfifo_write;
    logic txfifo_full, txfifo_empty;
    logic [ADDR_WIDTH-1:0] txfifo_addr_r;
    logic [ADDR_WIDTH-1:0] txfifo_addr_w;

    logic [7:0] rxbuffer[0:2**ADDR_WIDTH-1];
    logic [7:0] rxuart_data;
    logic rxuart_tick;
    logic rxfifo_read, rxfifo_write;
    logic rxfifo_full, rxfifo_empty;
    logic [ADDR_WIDTH-1:0] rxfifo_addr_r;
    logic [ADDR_WIDTH-1:0] rxfifo_addr_w;
    

    fifo_controller #(.ADDR_WIDTH(ADDR_WIDTH)) txfifo(
                .clk(clk), .rst(rst),
                .read(txfifo_read), .write(txfifo_write),
                .full(txfifo_full), .empty(txfifo_empty),
                .addr_r(txfifo_addr_r), .addr_w(txfifo_addr_w));
    uart_tx txuart(.clk(clk), .rst(rst), .data(txuart_data),
                .start(txuart_start), .busy(txuart_busy), .TxD(TxD));

    fifo_controller #(.ADDR_WIDTH(ADDR_WIDTH)) rxfifo(
                .clk(clk), .rst(rst),
                .read(rxfifo_read), .write(rxfifo_write),
                .full(rxfifo_full), .empty(rxfifo_empty),
                .addr_r(rxfifo_addr_r), .addr_w(rxfifo_addr_w));
    uart_rx rxuart(.clk(clk), .rst(rst), .data(rxuart_data),
                .rx_tick(rxuart_tick), .RxD(RxD));
    assign rx_data = rxuart_data;
    assign rx_tick = rxuart_tick;


    always_ff @(posedge clk) begin
        if (rst) begin
            rxfifo_read <= 1'b0;
            txfifo_write <= 1'b0;
        end else begin
            txfifo_write <= 1'b0;
            if (bus.wen & (bus.waddr[2] == 1'b1)) begin
                txbuffer[txfifo_addr_w] <= bus.wdata[7:0];
                txfifo_write <= 1'b1;
            end

            if (bus.ren & (bus.raddr[2] == 1'b0)) begin
                bus.rdata <= {24'h0, ~rxfifo_empty, ~txfifo_full};
            end
            
            rxfifo_read <= 1'b0;
            if (bus.ren & (bus.raddr[2] == 1'b1)) begin
                bus.rdata <= {24'bx, rxbuffer[rxfifo_addr_r]};
                rxfifo_read <= 1'b1;
            end
        end
    end


    always_ff @(posedge clk) begin
        if (rst) begin
            txuart_start <= 1'b0;
            txfifo_read <= 1'b0;
        end else if (~txfifo_empty && ~txuart_busy && ~txuart_start) begin
            txuart_data <= txbuffer[txfifo_addr_r];
            txuart_start <= 1'b1;
            txfifo_read <= 1'b1;
        end else begin
            txuart_start <= 1'b0;
            txfifo_read <= 1'b0;
        end
    end

    
    always_ff @(posedge clk) begin
        if (rst) begin
            rxfifo_write <= 1'b0;
        end else if (~rxfifo_full && rxuart_tick) begin
            rxbuffer[rxfifo_addr_w] <= rxuart_data;
            rxfifo_write <= 1'b1;
        end else begin
            rxfifo_write <= 1'b0;
        end
    end

endmodule


module baud_generator
#(parameter logic [19:0] INC)
(
    input clk,
    input enable,
    output tick
);

    logic [20:0] v = 0;
    assign tick = v[20];

    always_ff @(posedge clk)
        if (enable)
            v <= v[19:0] + INC;
        else
            v <= 0;

endmodule


module uart_tx(
    input logic clk, rst,
    input logic [7:0] data,
    input logic start,
    output logic busy,
    output logic TxD
);

    logic bit_tick;
    baud_generator #(.INC(20'd2416)) brgen(
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


module uart_rx(
    input  logic clk, rst,
    input  logic RxD,
    output logic [7:0] data,
    output logic rx_tick,
    output logic debug
);
    enum logic [1:0] {
        STATE_IDLE,
        STATE_DATA,
        STATE_END
    } state;

    logic bit_tick8;
    logic [5:0] counter;

    logic [1:0] RxD_sync;
    logic rx;
    always_ff @(posedge clk)
        RxD_sync <= {RxD_sync[0], RxD};
    assign rx = RxD_sync[1];
    
    baud_generator #(.INC(20'd19327)) brgen(
        .clk(clk), .enable(1'b1), .tick(bit_tick8));
    assign debug = bit_tick8;

    always_ff @(posedge clk) begin
        rx_tick <= 0;
        
        if (rst) begin
            state <= STATE_IDLE;
            counter <= 0;
        end else if (bit_tick8) begin
            case (state)
            STATE_IDLE: begin
                    if (rx) begin
                        counter <= 0;
                    end else begin
                        counter <= counter + 1;
                        if (&counter[1:0]) begin
                            counter <= 0;
                            state <= STATE_DATA;
                        end
                    end
                end
            STATE_DATA: begin
                    counter <= counter + 1;
                    if (&counter[2:0]) begin
                        data <= {RxD, data[7:1]};
                    end
                    if (&counter) begin
                        rx_tick <= 1'b1;
                        counter <= 0;
                        state <= STATE_END;
                    end
                end
            STATE_END: begin
                    counter <= counter + 1;
                    if (&counter[2:0])
                        state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule


module fifo_controller
#(parameter ADDR_WIDTH = 8)
(
    input  logic clk, rst,
    input  logic read, write,
    output logic full, empty,
    output logic [ADDR_WIDTH-1:0] addr_r,
    output logic [ADDR_WIDTH-1:0] addr_w);
     
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