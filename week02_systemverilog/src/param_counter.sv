// 可用 WIDTH 調整位元數的同步、低有效重設計數器。
module param_counter #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             enable,
    output logic [WIDTH-1:0] count
);

    always_ff @(posedge clk) begin
        if (!rst_n)
            count <= '0;
        else if (enable)
            count <= count + 1'b1;
    end

endmodule
