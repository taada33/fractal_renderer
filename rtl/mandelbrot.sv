module mandelbrot #(
    // Signed Q(M.N) fixed-point format:
    // M = integer bits (including sign)
    // N = fractional bits
    parameter int M = 4,
    parameter int N = 14,
    parameter bit COMBINATIONAL = 1,
    parameter int IMAGE_WIDTH = 320,
    parameter int IMAGE_HEIGHT = 240
)(
    input logic clk,
    input logic rst,

    input logic [$clog2(IMAGE_WIDTH)-1:0] px,
    input logic [$clog2(IMAGE_HEIGHT)-1:0] py,

    output logic escape_detect
);
    localparam BIT_WIDTH = M + N;

    localparam xDELTA = 3/IMAGE_WIDTH;
    localparam yDELTA = 2.25/IMAGE_HEIGHT;

    logic signed [BIT_WIDTH-1:0] x;
    logic signed [BIT_WIDTH-1:0] y;

    logic signed [2*BIT_WIDTH-1:0] x_next;
    logic signed [2*BIT_WIDTH-1:0] y_next;

    logic signed [2*BIT_WIDTH-1:0] x2;
    logic signed [2*BIT_WIDTH-1:0] y2;
    logic signed [2*BIT_WIDTH-1:0] xy;

    logic signed [15:0] a; // Q 2.14
    logic signed [15:0] b; // Q 2.14

    fixed_point_mult #(.BIT_WIDTH(BIT_WIDTH), .COMBINATIONAL(COMBINATIONAL)) fixed_point_mult_x2 (.clk(clk), .x(x), .y(x), .z(x2));
    fixed_point_mult #(.BIT_WIDTH(BIT_WIDTH), .COMBINATIONAL(COMBINATIONAL)) fixed_point_mult_y2 (.clk(clk), .x(y), .y(y), .z(y2));
    fixed_point_mult #(.BIT_WIDTH(BIT_WIDTH), .COMBINATIONAL(COMBINATIONAL)) fixed_point_mult_xy (.clk(clk), .x(x), .y(y), .z(xy));

    always_ff @( posedge clk ) begin
        if(rst) begin
            x_next <= '0;
            y_next <= '0;

            a <= -2 + px*xDELTA;
            b <= 1.125 - py*yDELTA;
        end else if(~escape_detect) begin
            x_next <= x2 - y2 + a;
            y_next <= 2*xy + b;
        end
    end

    assign x = x_next[2*BIT_WIDTH-M-1:BIT_WIDTH-M];
    assign y = y_next[2*BIT_WIDTH-M-1:BIT_WIDTH-M];

    assign escape_detect = x2 + y2 > (2*BIT_WIDTH)'(4) << 2*N ? 1'b1 : 1'b0;

endmodule