# 第 1 週學生作答紀錄

本檔保留原本寫在 `exercises.md` 的作答，方便批改與後續訂正。已知真值表中 `a=1`、`b=0`、`c=1` 的輸出需要修正；其餘批改意見可繼續記錄在本檔。

## 練習 1

對 `a=1`、`b=0`、`c=1`：

- `1 & 0 = 0`
- `0 ^ 1 = 1`

| a | b | c | `(a & b) ^ c` |
| --- | --- | --- | --- |
| 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | 0 |
| 0 | 1 | 0 | 0 |
| 1 | 1 | 0 | 1 |
| 0 | 0 | 1 | 1 |
| 1 | 0 | 1 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 1 | 1 | 0 |

## 練習 2

```systemverilog
module comb_logic (
    input  logic a,
    input  logic b,
    input  logic c,
    output logic parity,
);

    always_comb begin
        parity = a ^ b ^ c;
    end
endmodule
```

> 批改紀錄：介面最後多了一個逗號，且尚未實際修改 `src/comb_logic.sv` 與 testbench。

## 練習 3

```systemverilog
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
```

> 批改紀錄：RTL 邏輯正確，但尚未建立 `src/down_counter.sv` 與對應 testbench。0 再減 1 會回捲為 `4'b1111`。

## 練習 4

1. 組合邏輯的輸入與輸出有立即關係；循序邏輯會儲存值，因此相同輸入不一定得到相同輸出。
2. `always_comb` 用於組合電路；`always_ff` 用於循序電路。
3. `enable=0` 時不執行賦值，所以 `count` 保持數值。
4. 同步 reset 必須等待下一個 `clk` 上升沿才會更新循序電路。
5. 發生 overflow（溢位：結果超出目前位元寬度可表示的範圍），4-bit 只保留低 4 位，因此回到 0。
