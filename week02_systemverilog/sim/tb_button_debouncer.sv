`timescale 1ns/1ps

module tb_button_debouncer;
    logic clk = 1'b0;
    logic rst_n;
    logic btn_raw;
    logic btn_clean;

    button_debouncer #(.STABLE_CYCLES(4)) dut (
        .clk(clk), .rst_n(rst_n), .btn_raw(btn_raw), .btn_clean(btn_clean)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/button_debouncer.vcd");
        $dumpvars(0, tb_button_debouncer);
        rst_n = 1'b0;
        btn_raw = 1'b0;
        @(posedge clk); #1;
        assert (btn_clean == 1'b0) else $fatal(1, "reset failed");

        @(negedge clk);
        rst_n = 1'b1;
        // 模擬彈跳：短暫的 1 不應改變乾淨輸出。
        btn_raw = 1'b1;
        @(negedge clk);
        btn_raw = 1'b0;
        repeat (3) @(posedge clk); #1;
        assert (btn_clean == 1'b0) else $fatal(1, "bounce was accepted");

        // 保持按下，等待兩級同步與四個穩定取樣。
        @(negedge clk);
        btn_raw = 1'b1;
        repeat (6) @(posedge clk); #1;
        assert (btn_clean == 1'b1) else $fatal(1, "stable press was not accepted");

        @(negedge clk);
        btn_raw = 1'b0;
        repeat (6) @(posedge clk); #1;
        assert (btn_clean == 1'b0) else $fatal(1, "stable release was not accepted");
        $display("tb_button_debouncer: PASS");
        $finish;
    end
endmodule
