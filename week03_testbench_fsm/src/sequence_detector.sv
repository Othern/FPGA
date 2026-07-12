// 偵測可重疊的 3-bit 序列 101。
module sequence_detector (input logic clk, rst_n, serial_in, output logic detected);
    typedef enum logic [1:0] {IDLE, GOT_1, GOT_10} state_t;
    state_t state, next_state;
    always_ff @(posedge clk) begin
        if (!rst_n) state <= IDLE;
        else state <= next_state;
    end
    always_comb begin
        next_state = state;
        unique case (state)
            IDLE: next_state = serial_in ? GOT_1 : IDLE;
            GOT_1: next_state = serial_in ? GOT_1 : GOT_10;
            GOT_10: next_state = serial_in ? GOT_1 : IDLE;
            default: next_state = IDLE;
        endcase
    end
    always_comb detected = (state == GOT_10) && serial_in && rst_n;
endmodule
