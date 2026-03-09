`timescale 1ns/1ps
module write_ptr #(
    parameter ADDR_WIDTH = 4
)(
    input  wire                 wr_clk,
    input  wire                 wr_rst,
    input  wire                 wr_en,
    input  wire [ADDR_WIDTH:0]  rd_gray_sync,

    output reg  [ADDR_WIDTH:0]  wr_bin,
    output reg  [ADDR_WIDTH:0]  wr_gray,
    output wire                 full
);

localparam PTR_WIDTH = ADDR_WIDTH + 1;

wire [PTR_WIDTH-1:0] wr_bin_next;
wire [PTR_WIDTH-1:0] wr_gray_next;

assign wr_bin_next  = wr_bin + (wr_en & ~full);
assign wr_gray_next = (wr_bin_next >> 1) ^ wr_bin_next;

assign full =
    (wr_gray_next ==
     {~rd_gray_sync[PTR_WIDTH-1:PTR_WIDTH-2],
       rd_gray_sync[PTR_WIDTH-3:0]});

always @(posedge wr_clk or posedge wr_rst) begin
    if (wr_rst) begin
        wr_bin  <= 0;
        wr_gray <= 0;
    end
    else begin
        wr_bin  <= wr_bin_next;
        wr_gray <= wr_gray_next;
    end
end

endmodule