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

    localparam [23:0] xDELTA = {2'b11,{24{1'b0}}}/IMAGE_WIDTH; //fractionally extend 3 (1'b11) by 24 0s; division is done with 32bit int. Q 0.24 is preserved
    localparam [23:0] yDELTA = {4'b1001,{22{1'b0}}}/IMAGE_HEIGHT; //fractionally extend 2.25 (4'b1001) by 22 0s; division is done with 32bit int. Q 0.24 is preserved

    logic signed [BIT_WIDTH-1:0] x; // Q 4.14 or M.N
    logic signed [BIT_WIDTH-1:0] y; // Q 4.14 or M.N

    logic signed [2*BIT_WIDTH-1:0] x_next; // Q 8.28 or 2M.2N
    logic signed [2*BIT_WIDTH-1:0] y_next; // Q 8.28 or 2M.2N

    logic signed [2*BIT_WIDTH-1:0] x2; // Q 8.28 or 2M.2N
    logic signed [2*BIT_WIDTH-1:0] y2; // Q 8.28 or 2M.2N
    logic signed [2*BIT_WIDTH-1:0] xy; // Q 8.28 or 2M.2N

    logic signed [2+N-1:0] a; // Q 2.14 or 2.N
    logic signed [2+N-1:0] b; // Q 2.14 or 2.N

    fixed_point_mult #(.BIT_WIDTH(BIT_WIDTH), .COMBINATIONAL(COMBINATIONAL)) fixed_point_mult_x2 (.clk(clk), .x(x), .y(x), .z(x2));
    fixed_point_mult #(.BIT_WIDTH(BIT_WIDTH), .COMBINATIONAL(COMBINATIONAL)) fixed_point_mult_y2 (.clk(clk), .x(y), .y(y), .z(y2));
    fixed_point_mult #(.BIT_WIDTH(BIT_WIDTH), .COMBINATIONAL(COMBINATIONAL)) fixed_point_mult_xy (.clk(clk), .x(x), .y(y), .z(xy));

    always_ff @( posedge clk ) begin
        if(rst) begin
            x_next <= '0;
            y_next <= '0;

            a <= ({{$clog2(IMAGE_WIDTH){1'b1}},2'b10,{24{1'b0}}} + px*xDELTA) >> (24 - N); // px*xdeltaSIZE = $clog2(image_width)+24; constantSIZE = $clog2(image_width)+24+2;
            b <= ({{$clog2(IMAGE_HEIGHT){1'b0}},4'b1001,{21{1'b0}}} - py*yDELTA) >> (24 - N);

        end else if(~escape_detect) begin
            x_next <= x2 - y2 + {{2*M-2{a[2+N-1]}},a,{N{1'b0}}}; //sign extend a with 6 bits (or 2M-2), add 14 0's (or N 0s) to end to match x2 and y2 width
            y_next <= 2*xy + {{2*M-2{b[2+N-1]}},b,{N{1'b0}}}; //sign extend b with 6 bits (or 2M-2), add 14 0's (or N 0s)to end to match 2xy width
        end
    end

    assign x = x_next[2*BIT_WIDTH-M-1:BIT_WIDTH-M]; //convert from Q 8.28 to 4.14
    assign y = y_next[2*BIT_WIDTH-M-1:BIT_WIDTH-M]; //convert from Q 8.28 to 4.14

    assign escape_detect = x2 + y2 > (2*BIT_WIDTH)'(4) << 2*N ? 1'b1 : 1'b0;

endmodule