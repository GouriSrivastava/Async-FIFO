`timescale 1ns/1ps

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
   
)(
    input  wire                     wr_clk,
    input  wire                     wr_rst,
    input  wire                     wr_en,
    input  wire [DATA_WIDTH-1:0]    wr_data,
    output wire                     full,
    output wire                     almost_full, 

    input  wire                     rd_clk,
    input  wire                     rd_rst,
    input  wire                     rd_en,
    output wire [DATA_WIDTH-1:0]    rd_data,
    output wire                     empty,
    output wire                     almost_empty
);

    
     localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam PTR_WIDTH  = ADDR_WIDTH + 1;
    wire [PTR_WIDTH-1:0] wr_bin, wr_gray;
    wire [PTR_WIDTH-1:0] rd_bin, rd_gray;
    wire [PTR_WIDTH-1:0] fifo_level;
    

    wire [PTR_WIDTH-1:0] wr_gray_sync;
    wire [PTR_WIDTH-1:0] rd_gray_sync;

    assign fifo_level= wr_bin - rd_gray_sync;
    assign almost_full  = (fifo_level >= DEPTH-2);
    assign almost_empty = (fifo_level <= 2);

    // Synchronizers
    sync_2ff #(PTR_WIDTH) sync_rd_to_wr (
        .clk(wr_clk),
        .rst(wr_rst),
        .d_in(rd_gray),
        .d_out(rd_gray_sync)
    );

    sync_2ff #(PTR_WIDTH) sync_wr_to_rd (
        .clk(rd_clk),
        .rst(rd_rst),
        .d_in(wr_gray),
        .d_out(wr_gray_sync)
    );

    // Write pointer
    write_ptr #(ADDR_WIDTH) wp (
        .wr_clk(wr_clk),
        .wr_rst(wr_rst),
        .wr_en(wr_en),
        .rd_gray_sync(rd_gray_sync),
        .wr_bin(wr_bin),
        .wr_gray(wr_gray),
        .full(full)
    );

    // Read pointer
    read_ptr #(ADDR_WIDTH) rp (
        .rd_clk(rd_clk),
        .rd_rst(rd_rst),
        .rd_en(rd_en),
        .wr_gray_sync(wr_gray_sync),
        .rd_bin(rd_bin),
        .rd_gray(rd_gray),
        .empty(empty)
    );

    // Memory
    fifo_mem #(DATA_WIDTH, ADDR_WIDTH, DEPTH) mem_inst (
        .wr_clk(wr_clk),
        .wr_en(wr_en & ~full),
        .wr_addr(wr_bin[ADDR_WIDTH-1:0]),
        .wr_data(wr_data),

        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .rd_addr(rd_bin[ADDR_WIDTH-1:0]),
        .rd_data(rd_data)
    );

endmodule