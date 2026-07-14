`timescale 1ns/1ps
module tb_sequence_detector_exercise3;
    logic clk = 0, rst_n, serial_in, detected;
    logic [2:0] history;
    int bit_number;
    sequence_detector dut (.*);
    // 這是 SystemVerilog 的模組實例化寫法。如果測試平台剛好有對應的就會直接寫過去
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
        @(posedge clk);  #1; bit_number++; serial_in = 1'd0;
        assert (detected === expected)
            else $fatal(1, "bit %0d expected=%0b actual=%0b", bit_number, expected, detected);
        history = {history[1:0], value};
    endtask
    initial begin
        $dumpfile("build/sequence_detector_exercise3.vcd"); $dumpvars(0, tb_sequence_detector_exercise3);
        rst_n = 0; serial_in = 0; history = 0; bit_number = 0;
        apply_reset();

        send_bit(1);
        send_bit(0);  // reset 前累積 10

        apply_reset();

        send_bit(1);  // 必須預期 detected == 0
        $display("tb_sequence_detector: PASS"); $finish;
    end
endmodule
