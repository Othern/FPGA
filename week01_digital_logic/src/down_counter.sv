module down_counter (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       enable,
    output logic [3:0] count
);
    always_ff @(posedge clk) begin
        if (!rst_n)
            count <= 4'b0000;
        else if (enable)
            count <= count - 4'b0001;
    end
endmodule