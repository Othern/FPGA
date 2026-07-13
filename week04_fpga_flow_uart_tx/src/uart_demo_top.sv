// Basys 3 demonstration top: transmit the ASCII character 'U' periodically.
module uart_demo_top #(
    parameter int unsigned CLK_HZ = 100_000_000,
    parameter int unsigned BAUD = 115_200,
    parameter int unsigned SEND_INTERVAL_CYCLES = 50_000_000
) (
    input logic clk,
    input logic btnc,
    output logic led,
    output logic uart_txd
);
    localparam int unsigned INTERVAL_W = (SEND_INTERVAL_CYCLES <= 1) ? 1 : $clog2(SEND_INTERVAL_CYCLES);
    logic [INTERVAL_W-1:0] interval_count;
    logic start, busy, rst_n;
    (* ASYNC_REG = "TRUE" *) logic btn_sync0, btn_sync1;

    // btnc is asynchronous to clk; synchronize it before using it as reset.
    always_ff @(posedge clk) begin
        btn_sync0 <= btnc;
        btn_sync1 <= btn_sync0;
    end
    assign rst_n = ~btn_sync1;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            interval_count <= '0;
            start <= 1'b0;
            led <= 1'b0;
        end else begin
            start <= 1'b0;
            if (interval_count == SEND_INTERVAL_CYCLES - 1) begin
                interval_count <= '0;
                led <= ~led;
                if (!busy) start <= 1'b1;
            end else interval_count <= interval_count + 1'b1;
        end
    end

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) uart_tx_i (
        .clk, .rst_n, .start, .data(8'h55), .tx(uart_txd), .busy
    );
endmodule
