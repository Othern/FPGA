# 講義：SystemVerilog 模組、參數化與 PWM

## 1. 模組是可重用的硬體方塊

`module`（模組）是電路的封裝單位：輸入接收訊號，輸出送出訊號，模組內部描述真正的硬體。不同模組在 FPGA 中會**同時**運作。

```systemverilog
module inverter (
    input  logic a,
    output logic y
);
    assign y = ~a;
endmodule
```

要使用模組，需建立一個實例（instantiation，將模組放進較大的電路）：

```systemverilog
inverter u_inverter (
    .a(button),
    .y(led)
);
```

`.` 左邊是子模組的連接埠名稱，右邊是目前模組中的訊號。這種具名連接比依位置連接更容易檢查。

## 2. `logic` 與訊號寬度

`logic` 是 SystemVerilog 中最常用的硬體訊號型別。本課的設計用它取代舊式 Verilog 中經常讓初學者混淆的 `wire`、`reg` 分別。

```systemverilog
logic       valid;       // 1 個 bit
logic [7:0] data;        // 8 個 bit，data[7] 是最高位元
logic [3:0] count;       // 可表示 0 到 15
```

位元寬度會決定硬體大小與可表示的範圍。`logic [WIDTH-1:0]` 在 `WIDTH=8` 時就是 8-bit；在 `WIDTH=4` 時則是 4-bit。

## 3. 參數化：用一份程式做出不同大小的電路

`parameter`（參數）是在建立模組實例時可覆寫的常數，常用於設定計數器位元數、FIFO 深度或 UART 的計數值。請閱讀 `src/param_counter.sv`：

```systemverilog
module param_counter #(
    parameter int WIDTH = 8
) (...);
```

預設 `WIDTH` 是 8，但測試平台可以建立一個 3-bit 的版本：

```systemverilog
param_counter #(.WIDTH(3)) dut (...);
```

`localparam` 是只供模組內部使用、不能由外部覆寫的常數。例如 `localparam logic [WIDTH-1:0] MAX_COUNT = {WIDTH{1'b1}};` 表示全為 1 的最大計數值。

### 位元寬度的常見陷阱

- `count + 1'b1` 會依 `count` 的寬度保留結果；超過最大值時自然回捲。
- 不要把預設值寫死成 `8'd0`；參數化設計應寫 `'0`，它會自動填滿目標訊號的寬度。
- 比較或相加不同寬度的數字時，請先想清楚結果寬度。這是日後 FIFO 指標與 UART 計時很重要的習慣。

## 4. 組合邏輯與循序邏輯的分工

延續第 1 週的規則：

| 類型 | 寫法 | 用途 |
| --- | --- | --- |
| 組合邏輯 | `always_comb` 或 `assign` | 輸入一變，輸出就依規則改變。 |
| 循序邏輯 | `always_ff @(posedge clk)` | 在時脈上升沿保存或更新狀態。 |

PWM 的相位計數器是「狀態」，因此放在 `always_ff`；`pwm_out` 只由現在的 `phase` 與 `duty` 決定，因此是組合邏輯：

```systemverilog
always_comb begin
    pwm_out = (phase < duty);
end
```

此寫法在每條路徑都給了 `pwm_out` 值，所以不會意外產生 latch（鎖存器）。

## 5. PWM：用數位訊號控制平均亮度

PWM（pulse-width modulation，脈衝寬度調變）是一串固定頻率的 0/1 脈衝。週期內為 1 的比例稱為占空比（duty cycle）。LED 亮滅夠快時，人眼會感覺到不同平均亮度。

`src/pwm.sv` 使用 4-bit 相位計數器，因此一個週期有 16 個時脈：

| `duty` | 高電位週期數 | 大約亮度 |
| --- | --- | --- |
| 0 | 0 / 16 | 關閉 |
| 4 | 4 / 16 | 25% |
| 8 | 8 / 16 | 50% |
| 15 | 15 / 16 | 接近全亮 |

真實 LED 的 PWM 頻率必須高到不會明顯閃爍；本範例的 `PWM_BITS=4` 只為了讓波形容易觀察。未來上板時可增加位元數，或先用除頻器降低輸入時脈。

## 6. 選讀：按鍵為何需要同步化與除彈跳

按鍵不是乾淨的數位訊號：按下或放開的短暫期間，接點可能在 0、1 間快速跳動，稱為彈跳（bounce）。而按鍵相對於 FPGA 時脈又是非同步輸入，若剛好在取樣邊緣改變，可能造成亞穩態（metastability，暫存器在短時間內無法立刻判定 0 或 1）。

`button_debouncer.sv` 採取兩步：

1. 兩級同步器（two-flop synchronizer）：用兩個串接的 flip-flop 把外部按鍵帶進 `clk` 時脈域，降低亞穩態傳到後續邏輯的機率。
2. 穩定計數：只有當同步後的按鍵狀態持續不同於目前輸出達 `STABLE_CYCLES` 個時脈，才更新 `btn_clean`。

這不是消除亞穩態的魔法；它是降低風險的基本做法。實際按鍵的穩定時間常需數毫秒，必須依時脈頻率設定 `STABLE_CYCLES`。本週測試使用很小的數字，方便快速模擬。

本節屬於選讀。若參數化、位元寬度與 PWM 尚未熟悉，先完成核心練習，再回來閱讀按鍵範例。

## 7. 本週程式檢查表

- 所有可綜合模組都沒有 `#` 延遲。
- 組合區塊對每一個輸出完整賦值。
- 時序區塊使用 `always_ff` 與 `<=`。
- 可調整大小的常數以 `parameter` 表達，內部衍生常數以 `localparam` 表達。
- 每改一次 RTL，先執行對應 testbench，再查看波形或 assertion（斷言，自動檢查條件）。
- testbench 應避開在待測電路取樣的同一個時脈邊緣改變輸入，以免發生 race condition（競爭條件：多個模擬程序在同一時間更新，先後順序不確定）。
