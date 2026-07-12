// 三個 1-bit 輸入的組合邏輯範例。
module comb_logic (
    input  logic a,
    input  logic b,
    input  logic c,
    output logic y,
    output logic is_zero
);

    always_comb begin
        y       = (a & b) ^ c;
        is_zero = ~(a | b | c);
    end

endmodule
