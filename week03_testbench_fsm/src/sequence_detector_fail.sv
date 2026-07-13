// 偵測可重疊的 3-bit 序列 101。
module sequence_detector_fail (input logic clk, rst_n, serial_in, output logic detected);
    typedef enum logic [1:0] {IDLE, GOT_1, GOT_10} state_t;
    state_t state, next_state;
    always_ff @(posedge clk) begin
        if (!rst_n) state <= IDLE;
        else state <= next_state;
    end
    always_comb begin
        next_state = state;
        unique case (state)
            IDLE: begin
                if (serial_in) next_state = GOT_1;
                else next_state = IDLE;
            end
            GOT_1: begin
                if (serial_in) next_state = GOT_1;
                else next_state = GOT_10;
            end
            GOT_10: begin
                if (serial_in) next_state = IDLE;
                else next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    always_comb detected = (state == GOT_10) && serial_in && rst_n;
endmodule
