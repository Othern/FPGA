// 可用 WIDTH 調整位元數的同步、低有效重設計數器。
module up_down_counter #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             up,
    input  logic             enable,
    output logic [WIDTH-1:0] count
);

    always_ff @(posedge clk) begin
        if (!rst_n)
            count <= '0;
        else if (enable)
            if (up) 
                count <= count + 1'b1;
            else
                count <= count - 1'b1;
    end

endmodule
