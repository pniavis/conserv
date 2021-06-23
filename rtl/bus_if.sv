`ifndef __BUS_IF__
`define __BUS_IF__

interface bus_if();

    logic [31:0] raddr, rdata;
    logic [31:0] waddr, wdata;
    logic [3:0] bytemask;
    logic ren, wen;

    modport master(
        input  rdata,
        output raddr, waddr,
               wdata,
               ren, wen,
               bytemask
    );
    
    modport master_rdonly(
        input  rdata,
        output raddr, ren
    );
    
    modport master_wronly(
        output waddr,
               wdata,
               wen,
               bytemask
    );

    modport slave(
        output rdata,
        input  raddr, waddr,
               wdata,
               ren, wen,
               bytemask
    );

endinterface

`endif