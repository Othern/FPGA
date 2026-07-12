`timescale 1ns/1ps

module tb_pwm;
    logic clk = 1'b0;
    logic rst_n;
    logic [3:0] duty;
    logic pwm_out;
    int high_count;
    int i;

    pwm #(.PWM_BITS(4)) dut (
        .clk(clk), .rst_n(rst_n), .duty(duty), .pwm_out(pwm_out)
    );

    always #5 clk = ~clk;

    task automatic check_high_cycles(input logic [3:0] expected);
        high_count = 0;
        for (i = 0; i < 16; i = i + 1) begin
            #1 if (pwm_out) high_count = high_count + 1;
            @(posedge clk);
        end
        assert (high_count == expected)
            else $fatal(1, "duty=%0d, expected %0d high cycles, got %0d", duty, expected, high_count);
    endtask

    initial begin
        $dumpfile("build/pwm.vcd");
        $dumpvars(0, tb_pwm);
        rst_n = 1'b0;
        duty = 4'd0;
        @(posedge clk); #1;
        assert (pwm_out == 1'b0) else $fatal(1, "duty 0 should be off");

        rst_n = 1'b1;
        duty = 4'd4;
        check_high_cycles(4);

        duty = 4'd8;
        check_high_cycles(8);

        duty = 4'd0;
        check_high_cycles(0);
        $display("tb_pwm: PASS");
        $finish;
    end
endmodule
