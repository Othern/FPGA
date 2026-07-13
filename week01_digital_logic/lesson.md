# 講義：從邏輯運算到時脈計數器

## 1. FPGA 與 HDL 的思考方式

軟體程式描述的是「依序執行的步驟」；SystemVerilog 的可綜合設計描述的是「同時存在的電路」。例如一個 AND gate 和一個計數器會同時運作，而不是先跑完其中一個才跑另一個。

FPGA 設計的基本流程是：

1. 撰寫 RTL（register-transfer level，暫存器傳輸層級：描述資料如何在暫存器與組合邏輯間流動）。
2. 以 testbench（測試平台：用來產生輸入並檢查輸出的模擬程式）模擬並檢查波形。
3. 綜合（synthesis，將 RTL 轉換成邏輯元件）、配置與繞線（place and route，決定元件位置與訊號連線）。
4. 加入腳位與時脈約束，檢查時序。
5. 燒錄到開發板測試。

本週只完成前兩步。

## 2. 位元、二進位與布林邏輯

- `0` 和 `1` 是單一 bit。
- `logic [3:0] x` 是 4-bit 向量，左側 `[3]` 是最高位元（MSB），右側 `[0]` 是最低位元（LSB）。
- 4-bit 無號數的範圍是 0 至 15；`4'b1111 + 1` 會回捲為 `4'b0000`。

常用布林運算：

| 運算 | SystemVerilog | 意義 |
| --- | --- | --- |
| AND | `a & b` | 兩者皆為 1 才為 1 |
| OR | `a | b` | 任一為 1 即為 1 |
| XOR | `a ^ b` | 兩者不同才為 1 |
| NOT | `~a` | 將 0、1 反相 |

## 3. 組合邏輯：輸入一變，輸出跟著變

組合邏輯沒有記憶能力；輸出只取決於「現在」的輸入。`src/comb_logic.sv` 中的 `y` 與 `is_zero` 都是組合邏輯。

請用 `always_comb` 描述多步驟組合邏輯。它能協助工具檢查敏感訊號，並清楚表達「這不是暫存器」。組合邏輯必須在所有分支對輸出賦值，否則可能意外推導出 latch。

```systemverilog
always_comb begin
  y = (a & b) ^ c;
end
```

### Latch：為什麼組合邏輯一定要完整賦值？

Latch（鎖存器）是一種記憶元件，但它是**電位敏感**的：enable 有效的整段時間，輸出會持續跟著輸入變化；enable 無效時，輸出保留最後的值。它不像一般同步設計的 flip-flop，只在時脈邊緣更新。

FPGA 初學專案應以 `always_ff @(posedge clk)` 建立 flip-flop 來保存狀態。意外產生的 latch 會使設計較難理解，也較難進行時序分析。

| 電路類型 | 輸出更新時機 | 常見寫法 |
| --- | --- | --- |
| 組合邏輯 | 輸入變動後立即反映 | `always_comb`、`assign` |
| Latch | enable 有效的整段時間 | `always_latch` |
| Flip-flop | 時脈邊緣 | `always_ff @(posedge clk)` |

意外 latch 最常見的原因是：`always_comb` 裡某些條件路徑沒有對輸出賦值。工具為了讓輸出保留舊值，就只能推導出記憶元件。

```systemverilog
// 不佳：sel 為 0 時 q 沒有新值，會推導出 latch
always_comb begin
  if (sel)
    q = a;
end
```

改為使每個分支都賦值：

```systemverilog
// 良好：q 在每個條件下都有值，這是組合邏輯
always_comb begin
  if (sel)
    q = a;
  else
    q = b;
end
```

也可以在區塊一開始設定預設值；`case` 則應提供 `default`。若綜合工具警告 *inferred latch*，先視為錯誤：檢查是否漏寫 `else`、`default` 或預設賦值。只有在明確需要 latch 時，才使用 `always_latch`。

## 4. 循序邏輯：在時脈邊緣保存資料

暫存器會保留先前的值。下列程式的 `count` 只會在 `clk` 的上升沿更新：

```systemverilog
always_ff @(posedge clk) begin
  if (!rst_n)
    count <= '0;
  else if (enable)
    count <= count + 1'b1;
end
```

- `posedge clk`：只在時脈由 0 變 1 的瞬間觸發。
- `rst_n`：名稱中的 `_n` 表示低有效；`rst_n == 0` 時重設。
- `<=`：non-blocking assignment（非阻塞賦值），代表同一時脈邊緣取樣的暫存器在模擬時間步結束時一起更新；時序邏輯優先使用它。
- `enable == 0` 時沒有賦新值，暫存器自然維持原值。

本週範例採用**同步、低有效重設**：reset 只有在下一個 `clk` 上升沿才真正改變 `count`。

### `=` 與 `<=` 的分工

- blocking assignment（阻塞賦值）`=`：目前敘述完成後，下一行才繼續執行；本教材用於 `always_comb`。
- non-blocking assignment（非阻塞賦值）`<=`：先計算右側，稍後一起更新左側；本教材用於 `always_ff`。

模擬中還可能看到 `X` 與 `Z`：`X` 是未知值，表示模擬器無法判定為 0 或 1；`Z` 是高阻抗，表示訊號像未被驅動。內部 RTL 若意外出現 `X`，常見原因是未重設或組合邏輯沒有完整賦值。

## 5. 如何讀計數器波形

打開 `build/counter.vcd` 後，依序檢查：

1. `rst_n` 為 0 時，下一個 `clk` 上升沿後 `count` 是否為 0。
2. `enable` 為 1 時，每一個上升沿 `count` 是否加 1。
3. `enable` 為 0 時，`count` 是否維持不變。
4. 在最大值 15 後，4-bit `count` 是否回到 0。

## 6. 本週容易犯的錯誤

- 在 RTL 的 `always_ff` 中使用 `#10`：這不是可實作的硬體延遲。
- 在一個 `always_ff` 裡使用 `=` 更新暫存器：可能與真實硬體的同步行為不符。
- 忘記 reset：模擬起始值可能是 `X`，硬體上也沒有可靠初始狀態。
- 把非同步按鍵直接送進時序邏輯：後續課程會學同步化與除彈跳。

## 補充教材
[清大數位邏輯 ocw](https://www.youtube.com/playlist?list=PLfXQiaewslOv00szAvSeASqSfKamP-0v8)