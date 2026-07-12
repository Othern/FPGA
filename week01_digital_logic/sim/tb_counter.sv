`timescale 1ns/1ps

module tb_counter;
    logic clk = 1'b0;
    logic rst_n;
    logic enable;
    logic [3:0] count;

    counter dut (
        .clk(clk), .rst_n(rst_n), .enable(enable), .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/counter.vcd");
        $dumpvars(0, tb_counter);

        rst_n  = 1'b0;
        enable = 1'b0;
        @(posedge clk);
        #1 assert (count == 4'd0) else $fatal(1, "reset failed");

        rst_n  = 1'b1;
        enable = 1'b1;
        repeat (3) @(posedge clk);
        #1 assert (count == 4'd3) else $fatal(1, "counting failed: %0d", count);

        enable = 1'b0;
        repeat (2) @(posedge clk);
        #1 assert (count == 4'd3) else $fatal(1, "hold failed: %0d", count);

        enable = 1'b1;
        repeat (13) @(posedge clk);
        #1 assert (count == 4'd0) else $fatal(1, "overflow failed: %0d", count);

        $display("tb_counter: PASS");
        $finish;
    end
endmodule
