// 將非同步按鍵同步化，並在輸入穩定 STABLE_CYCLES 個時脈後更新輸出。
module button_debouncer #(
    parameter int STABLE_CYCLES = 4
) (
    input  logic clk,
    input  logic rst_n,
    input  logic btn_raw,
    output logic btn_clean
);
    localparam int COUNT_WIDTH = (STABLE_CYCLES <= 1) ? 1 : $clog2(STABLE_CYCLES);

    logic sync_ff1;
    logic btn_sync;
    logic [COUNT_WIDTH-1:0] stable_count;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            sync_ff1     <= 1'b0;
            btn_sync     <= 1'b0;
            btn_clean    <= 1'b0;
            stable_count <= '0;
        end else begin
            sync_ff1 <= btn_raw;
            btn_sync <= sync_ff1;

            if (btn_sync == btn_clean) begin
                stable_count <= '0;
            end else if (stable_count == STABLE_CYCLES - 1) begin
                btn_clean    <= btn_sync;
                stable_count <= '0;
            end else begin
                stable_count <= stable_count + 1'b1;
            end
        end
    end

endmodule
