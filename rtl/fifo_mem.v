`timescale 1ns/1ps
module fifo_mem #(
 
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter DEPTH = 16

)(
    input  wire wr_clk,
    input  wire wr_en,
    input  wire [ADDR_WIDTH-1:0] wr_addr,
    input  wire [DATA_WIDTH-1:0] wr_data,

    input  wire rd_clk,
    input  wire rd_en,
    input  wire [ADDR_WIDTH-1:0] rd_addr,
    output reg  [DATA_WIDTH-1:0] rd_data
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

always @(posedge wr_clk)
    if (wr_en)
        mem[wr_addr] <= wr_data;

always @(posedge rd_clk)
    if (rd_en)
        rd_data <= mem[rd_addr];

endmodule