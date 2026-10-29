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

    function automatic real absvalue(input real value);
        return value > 0.0 ? value : -value;
    endfunction

    task automatic check_value(input string name,input real inst_value, input real test_value);
        assert(absvalue(inst_value - test_value) < 1.0/(2.0 ** N))
            $display("%s calculated correctly as: %f", name, inst_value);
            else
            $error("INCORRECT. %s_inst = %f; %s =%f", name, inst_value, name, test_value);       
    endtask

    task automatic pixel_test(input [$clog2(IMAGE_WIDTH)-1:0] px_test, input [$clog2(IMAGE_HEIGHT)-1:0] py_test);
        logic [31:0] counter;
        real x;
        real y;
        real a;
        real b;
        real x_next;
        real y_next;

        x = 0;
        y = 0;
        a = -2 + px_test*(3.0/IMAGE_WIDTH);
        b = 1.125 - py_test*(2.25/IMAGE_HEIGHT);

        //setup
        px = px_test;
        py = py_test;
        rst = 1; @(negedge clk); rst = 0;
        counter = 0;

        check_value("a",$itor(mandelbrot_inst.a)/(2.0 ** N), a);
        check_value("b",$itor(mandelbrot_inst.b)/(2.0 ** N), b);

        while(escape_detect == 1'b0 && counter < 64) begin
            $display("ITERATION %d", counter);

            x_next = x**2 - y**2 + a;
            y_next = 2*x*y + b;
            x = x_next;
            y = y_next;

            @(negedge clk);

            check_value("x",$itor(mandelbrot_inst.x)/(2.0 ** N), x);
            check_value("y",$itor(mandelbrot_inst.y)/(2.0 ** N), y);

            counter++;
        end

        if(counter == 64 && escape_detect == 1'b0) begin
            $display("Pixel reached maximum iteration limit.");
        end else begin
            $display("Pixel escapes after %d iterations", counter);
        end
    endtask


    initial begin
        pixel_test(114, 94);
        pixel_test(160, 120);
        $finish;
    end


endmodule