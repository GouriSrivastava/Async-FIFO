module sync_2ff #(
    parameter WIDTH = 5
)(
    input  wire clk,
    input  wire rst,
    input  wire [WIDTH-1:0] d_in,
    output reg  [WIDTH-1:0] d_out
);

reg [WIDTH-1:0] sync;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        sync  <= 0;
        d_out <= 0;
    end
    else begin
        sync  <= d_in;
        d_out <= sync;
    end
end

endmodule