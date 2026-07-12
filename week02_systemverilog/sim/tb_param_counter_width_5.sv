`timescale 1ns/1ps

module tb_param_counter;
    logic clk = 1'b0;
    logic rst_n;
    logic enable;
    logic [4:0] count;

    param_counter #(.WIDTH(5)) dut (
        .clk(clk), .rst_n(rst_n), .enable(enable), .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/param_counter.vcd");
        $dumpvars(0, tb_param_counter);
        rst_n = 1'b0;
        enable = 1'b0;
        @(posedge clk); #1;
        assert (count == 5'd0) else $fatal(1, "reset failed");

        rst_n = 1'b1;
        enable = 1'b1;
        repeat (31) @(posedge clk);
        #1 assert (count == 5'd31) else $fatal(1, "count failed: %0d", count);

        @(posedge clk); #1;
        assert (count == 5'd0) else $fatal(1, "wrap failed: %0d", count);

        enable = 1'b0;
        repeat (2) @(posedge clk);
        #1 assert (count == 5'd0) else $fatal(1, "hold failed");
        $display("tb_param_counter: PASS");
        $finish;
    end
endmodule
