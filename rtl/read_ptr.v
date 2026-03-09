`timescale 1ns/1ps
module read_ptr #(
    parameter ADDR_WIDTH = 4
)(
    input  wire                 rd_clk,
    input  wire                 rd_rst,
    input  wire                 rd_en,
    input  wire [ADDR_WIDTH:0]  wr_gray_sync,

    output reg  [ADDR_WIDTH:0]  rd_bin,
    output reg  [ADDR_WIDTH:0]  rd_gray,
    output wire                 empty
);

localparam PTR_WIDTH = ADDR_WIDTH + 1;

wire [PTR_WIDTH-1:0] rd_bin_next;
wire [PTR_WIDTH-1:0] rd_gray_next;

// empty flag
assign empty = (rd_gray == wr_gray_sync);

// next pointer
assign rd_bin_next  = rd_bin + (rd_en & ~empty);
assign rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next;

always @(posedge rd_clk or posedge rd_rst) begin
    if (rd_rst) begin
        rd_bin  <= 0;
        rd_gray <= 0;
    end
    else begin
        rd_bin  <= rd_bin_next;
        rd_gray <= rd_gray_next;
    end
end

endmodule