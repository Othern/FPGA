`timescale 1ns/1ps
module tb_sequence_detector;
    logic clk = 0, rst_n, serial_in, detected;
    logic [2:0] history;
    int bit_number;
    sequence_detector dut (.*);
    always #5 clk = ~clk;
    task automatic apply_reset;
        @(negedge clk); rst_n = 0; serial_in = 0;
        @(posedge clk); #1;
        assert (detected === 0) else $fatal(1, "reset output failed");
        history = 0;
        @(negedge clk); rst_n = 1;
    endtask
    task automatic send_bit(input logic value);
        logic expected;
        @(negedge clk); serial_in = value;
        expected = (history[1:0] == 2'b10) && value;
        @(posedge clk); #1; bit_number++;
        assert (detected === expected)
            else $fatal(1, "bit %0d expected=%0b actual=%0b", bit_number, expected, detected);
        history = {history[1:0], value};
    endtask
    initial begin
        $dumpfile("build/sequence_detector.vcd"); $dumpvars(0, tb_sequence_detector);
        rst_n = 0; serial_in = 0; history = 0; bit_number = 0;
        apply_reset();
        repeat (4) send_bit(0);
        send_bit(1); send_bit(0); send_bit(1);
        apply_reset();
        send_bit(1); send_bit(0); send_bit(1); send_bit(0); send_bit(1);
        send_bit(1); send_bit(0); apply_reset(); send_bit(1);
        $display("tb_sequence_detector: PASS"); $finish;
    end
endmodule
