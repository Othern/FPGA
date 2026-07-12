`timescale 1ns/1ps

module tb_comb_logic;
    logic a, b, c;
    logic y, is_zero;
    logic expected_y, expected_zero;
    integer i;

    comb_logic dut (
        .a(a), .b(b), .c(c), .y(y), .is_zero(is_zero)
    );

    initial begin
        $dumpfile("build/comb_logic.vcd");
        $dumpvars(0, tb_comb_logic);

        for (i = 0; i < 8; i = i + 1) begin
            {a, b, c} = i[2:0];
            #1;
            expected_y    = (a & b) ^ c;
            expected_zero = ~(a | b | c);
            assert (y === expected_y)
                else $fatal(1, "y failed for a,b,c=%b%b%b", a, b, c);
            assert (is_zero === expected_zero)
                else $fatal(1, "is_zero failed for a,b,c=%b%b%b", a, b, c);
        end

        $display("tb_comb_logic: PASS");
        $finish;
    end
endmodule
