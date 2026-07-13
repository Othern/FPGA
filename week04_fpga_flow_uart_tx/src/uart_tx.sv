// 8N1 UART transmitter.  One start request sends data[7:0], LSB first.
module uart_tx #(
    parameter int unsigned CLK_HZ = 100_000_000,
    parameter int unsigned BAUD   = 115_200
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic [7:0] data,
    output logic       tx,
    output logic       busy
);
    localparam int unsigned CLKS_PER_BIT = CLK_HZ / BAUD;
    localparam int unsigned COUNT_W = (CLKS_PER_BIT <= 1) ? 1 : $clog2(CLKS_PER_BIT);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;
    logic [COUNT_W-1:0] clk_count;
    logic [2:0] bit_index;
    logic [7:0] data_reg;

    initial begin
        if (CLK_HZ < BAUD) $error("CLK_HZ must be at least BAUD");
        if ((CLK_HZ % BAUD) != 0) $warning("CLK_HZ / BAUD is rounded down; choose an exact divisor when possible");
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state     <= IDLE;
            clk_count <= '0;
            bit_index <= '0;
            data_reg  <= '0;
        end else begin
            case (state)
                IDLE: begin
                    clk_count <= '0;
                    bit_index <= '0;
                    if (start) begin
                        data_reg <= data;
                        state    <= START;
                    end
                end
                START: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        state     <= DATA;
                    end else clk_count <= clk_count + 1'b1;
                end
                DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        if (bit_index == 3'd7) state <= STOP;
                        else bit_index <= bit_index + 1'b1;
                    end else clk_count <= clk_count + 1'b1;
                end
                STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        state     <= IDLE;
                    end else clk_count <= clk_count + 1'b1;
                end
                default: state <= IDLE;
            endcase
        end
    end

    always_comb begin
        tx = 1'b1;                 // UART 閒置時為高電位。
        unique case (state)
            START: tx = 1'b0;
            DATA:  tx = data_reg[bit_index];
            default: tx = 1'b1;
        endcase
    end

    assign busy = (state != IDLE);
endmodule
