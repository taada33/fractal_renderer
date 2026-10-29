module mandelbrot_tb #(
    parameter int M = 4,
    parameter int N = 14,
    parameter bit COMBINATIONAL = 1,
    parameter int IMAGE_WIDTH = 320,
    parameter int IMAGE_HEIGHT = 240
);

    logic clk = 1'b0;
    logic rst;

    logic [$clog2(IMAGE_WIDTH)-1:0] px;
    logic [$clog2(IMAGE_HEIGHT)-1:0] py;

    logic escape_detect;

    always #5 clk = ~clk;

    mandelbrot # (
    .M(M),
    .N(N),
    .COMBINATIONAL(COMBINATIONAL),
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IMAGE_HEIGHT(IMAGE_HEIGHT)
    ) mandelbrot_inst (
        .clk(clk),
        .rst(rst),
        .px(px),
        .py(py),
        .escape_detect(escape_detect)
    );


    initial begin
        px = 0;
        py = 0;
        
        rst = 1;

        #10;

        rst = 0; //set a and b

        //check x and y = 0;
        assert(mandelbrot_inst.y == 0)
            $display("y reset correctly");
        else
            $display("y not reset correctly.");

        assert(mandelbrot_inst.x == 0)
            $display("x reset correctly");
        else
            $display("x not reset correctly.");
        //check a and b;
        $display("a = %f",$itor(mandelbrot_inst.a)/(2.0 ** N));
        $display("b = %f",$itor(mandelbrot_inst.b)/(2.0 ** N));

        // px = 0;
        // py = 0;
        // rst = 1; #10; rst = 0;
        // //comfirm c = -2 + 1.125i

        // px = 160;
        // py = 120;
        // rst = 1; #10; rst = 0;
        // //confirm c = -0.5 + 0i;
        
        // px = 0;
        // py = 120;
        // rst = 1; #10; rst = 0;
        // //confirm c = -2 + 0i;

        $finish;
    end


endmodule