`timescale 1ns/1ps
module tb_sequence_detector_1101;
    logic clk = 0, rst_n, serial_in, detected;
    logic [3:0] history;
    int bit_number;
    sequence_detector_1101 dut (.*);
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
        expected = (history[2:0] == 3'b110) && value;
        @(posedge clk); bit_number++;
        assert (detected === expected)
            else $fatal(1, "bit %0d expected=%0b actual=%0b", bit_number, expected, detected);
        history = {history[1:0], value};
    endtask
    initial begin
        $dumpfile("build/sequence_detector_1101.vcd"); $dumpvars(0, tb_sequence_detector_1101);
        rst_n = 0; serial_in = 0; history = 0; bit_number = 0;
        apply_reset();
        // 不命中
        apply_reset();
        send_bit(1); send_bit(0); send_bit(1); send_bit(0);

        // 單次命中
        apply_reset();
        send_bit(1); send_bit(1); send_bit(0); send_bit(1);

        // 共享前綴
        apply_reset();
        send_bit(1); send_bit(1); send_bit(1);
        send_bit(0); send_bit(1);  // 11101

        // 重疊命中，建議額外測試
        apply_reset();
        send_bit(1); send_bit(1); send_bit(0); send_bit(1);
        send_bit(1); send_bit(0); send_bit(1);  // 1101101

        // 中途 reset
        apply_reset();
        send_bit(1); send_bit(1); send_bit(0);
        apply_reset();
send_bit(1);  // 不得命中
        $display("tb_sequence_detector_1101: PASS"); $finish;
    end
endmodule
