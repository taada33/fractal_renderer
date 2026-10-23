module fixed_point_mult #(
    parameter int BIT_WIDTH = 18,
    parameter bit COMBINATIONAL = 1
)(
    input logic clk,
    // ex Q4.14 for BIT_WIDTH = 18
    input logic signed [BIT_WIDTH-1:0] x,
    input logic signed [BIT_WIDTH-1:0] y,

    // ex Q8.28 for BIT_WIDTH = 18
    output logic signed [2*BIT_WIDTH-1:0] z
);

    generate
        if(COMBINATIONAL) begin
            assign z = x*y;
        end else begin
            always_ff @ (posedge clk) begin
                z <= x*y;
            end
        end
    endgenerate
    
endmodule