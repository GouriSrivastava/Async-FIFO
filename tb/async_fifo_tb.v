`timescale 1ns/1ps

module async_fifo_tb;

parameter DATA_WIDTH = 8;
parameter DEPTH = 16;

reg wr_clk = 0;
reg rd_clk = 0;

reg wr_rst;
reg rd_rst;

reg wr_en;
reg [DATA_WIDTH-1:0] wr_data;
wire full;

reg rd_en;
wire [DATA_WIDTH-1:0] rd_data;
wire empty;

wire almost_full;
wire almost_empty;

//--------------------------------------
// DUT
//--------------------------------------

async_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) dut (

    .wr_clk(wr_clk),
    .wr_rst(wr_rst),
    .wr_en(wr_en),
    .wr_data(wr_data),

    .rd_clk(rd_clk),
    .rd_rst(rd_rst),
    .rd_en(rd_en),

    .rd_data(rd_data),

    .full(full),
    .empty(empty),
    .almost_full(almost_full),
    .almost_empty(almost_empty)
);

//--------------------------------------
// Clock generation
//--------------------------------------

always #5 wr_clk = ~wr_clk;
always #7 rd_clk = ~rd_clk;

//--------------------------------------
// Dump for GTKWave
//--------------------------------------

initial begin
    $dumpfile("async_fifo.vcd");
    $dumpvars(0, async_fifo_tb);
end

//--------------------------------------
// Simple Scoreboard Memory
//--------------------------------------

reg [DATA_WIDTH-1:0] expected_mem [0:DEPTH-1];

integer exp_wr_ptr = 0;
integer exp_rd_ptr = 0;

//--------------------------------------
// Reset
//--------------------------------------

initial begin

    wr_rst = 1;
    rd_rst = 1;

    wr_en  = 0;
    rd_en  = 0;

    wr_data = 0;

    #40;

    wr_rst = 0;
    rd_rst = 0;

end

//--------------------------------------
// Random Write Logic
//--------------------------------------

always @(posedge wr_clk) begin

    if(!wr_rst) begin

        wr_en <= $random % 2;

        if(wr_en && !full) begin

            wr_data <= $random;

            expected_mem[exp_wr_ptr] = wr_data;
            exp_wr_ptr = (exp_wr_ptr + 1) % DEPTH;

        end

    end

end

//--------------------------------------
// Random Read Logic
//--------------------------------------

always @(posedge rd_clk) begin

    if(!rd_rst)
        rd_en <= $random % 2;

end

//--------------------------------------
// Read latency handling
//--------------------------------------

reg rd_en_d;

always @(posedge rd_clk)
    rd_en_d <= rd_en;

//--------------------------------------
// Scoreboard Check
//--------------------------------------

wire read_fire;
assign read_fire = rd_en && !empty;

reg read_fire_d;

always @(posedge rd_clk)
    read_fire_d <= read_fire;


//--------------------------------------
// Scoreboard Check
//--------------------------------------
initial begin
    repeat(20) begin
        #100;
        $display("Simulation running... time = %0t", $time);
    end
end
always @(posedge rd_clk) begin

    if(read_fire_d) begin

        if(rd_data !== expected_mem[exp_rd_ptr]) begin

            $display("ERROR at time %0t", $time);
            $display("Expected = %h  Got = %h",
                     expected_mem[exp_rd_ptr], rd_data);

            $finish;

        end

        exp_rd_ptr = (exp_rd_ptr + 1) % DEPTH;

    end

end
//--------------------------------------
// End Simulation
//--------------------------------------

initial begin

    #500
    $display("FIFO RANDOM TEST PASSED");

    $finish;

end

endmodule