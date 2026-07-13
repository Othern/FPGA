`timescale 1ns/1ps
module tb_uart_tx;
    localparam int CLKS_PER_BIT = 10;
    logic clk = 0, rst_n, start;
    logic [7:0] data;
    logic tx, busy;

    uart_tx #(.CLK_HZ(1_000_000), .BAUD(100_000)) dut (.*);
    always #5 clk = ~clk;

    task automatic expect_level(input logic expected, input string name);
        assert (tx === expected)
            else $fatal(1, "%s: expected tx=%0b actual=%0b at %0t", name, expected, tx, $time);
    endtask

    task automatic send_and_check(input logic [7:0] value);
        int i;
        @(negedge clk); data = value; start = 1'b1;
        @(posedge clk); #1;
        assert (busy === 1'b1) else $fatal(1, "busy did not assert");
        @(negedge clk); start = 1'b0;

        repeat (CLKS_PER_BIT / 2) @(posedge clk); #1;
        expect_level(1'b0, "start bit middle");
        for (i = 0; i < 8; i++) begin
            repeat (CLKS_PER_BIT) @(posedge clk); #1;
            expect_level(value[i], $sformatf("data bit %0d", i));
        end
        repeat (CLKS_PER_BIT) @(posedge clk); #1;
        expect_level(1'b1, "stop bit middle");
        repeat (CLKS_PER_BIT / 2) @(posedge clk); #1;
        assert (busy === 1'b0) else $fatal(1, "busy did not deassert");
    endtask

    initial begin
        $dumpfile("build/uart_tx.vcd"); $dumpvars(0, tb_uart_tx);
        rst_n = 0; start = 0; data = 0;
        repeat (2) @(posedge clk);
        #1; expect_level(1'b1, "reset idle");
        @(negedge clk); rst_n = 1;
        send_and_check(8'hA5);

        // start while busy must not replace the byte currently being sent.
        @(negedge clk); data = 8'h02; start = 1;
        @(posedge clk); #1;
        @(negedge clk); start = 0;
        repeat (2 * CLKS_PER_BIT) @(posedge clk);
        @(negedge clk); data = 8'h00; start = 1;
        @(posedge clk); #1;
        @(negedge clk); start = 0;
        repeat (CLKS_PER_BIT / 2) @(posedge clk); #1;
        expect_level(1'b1, "original frame kept while busy");
        repeat (8 * CLKS_PER_BIT) @(posedge clk);
        #1; assert (busy === 1'b0) else $fatal(1, "second frame did not finish");
        $display("tb_uart_tx: PASS");
        $finish;
    end
endmodule
