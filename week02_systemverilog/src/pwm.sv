// PWM_BITS 決定一個 PWM 週期的解析度：2**PWM_BITS 個時脈。
module pwm #(
    parameter int PWM_BITS = 4
) (
    input  logic                clk,
    input  logic                rst_n,
    input  logic [PWM_BITS-1:0] duty,
    output logic                pwm_out
);
    logic [PWM_BITS-1:0] phase;

    always_ff @(posedge clk) begin
        if (!rst_n)
            phase <= '0;
        else
            phase <= phase + 1'b1;
    end

    always_comb begin
        pwm_out = (phase < duty);
    end

endmodule
