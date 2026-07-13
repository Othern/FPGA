# 第 4 週教材：從 RTL 到開發板，並送出第一個 UART 字元

## 1. FPGA 開發流程

模擬通過只代表 RTL 在指定測試條件下行為正確；上板前仍要經過下列流程：

1. **Synthesis（綜合）**：將 SystemVerilog 轉成暫存器、邏輯閘、記憶體等硬體資源。
2. **Implementation（實作）**：把硬體放到實際 FPGA 資源，並完成訊號繞線。
3. **Timing analysis（時序分析）**：檢查繞線後的訊號能否在時脈規定時間內穩定到達。
4. **Bitstream（位元流）**：把實作結果轉成可設定 FPGA 的檔案。
5. **Hardware validation（硬體驗證）**：以 LED、UART 或量測工具確認真實硬體行為。

每一步出現錯誤都應先回到該步修正；不要用「能產生 bitstream」取代「時序已通過」。

## 2. 腳位與時脈約束

`.xdc` 是 Xilinx 的約束檔，將 RTL port 名稱連到開發板實體腳位。以下三行的意義不同：

```xdc
set_property PACKAGE_PIN W5 [get_ports { clk }]
set_property PACKAGE_PIN A18 [get_ports { uart_txd }]
create_clock -name sys_clk -period 10.000 [get_ports { clk }]
```

前兩行指定腳位；最後一行告訴工具 `clk` 每 10 ns 一次，即 100 MHz。若沒有 `create_clock`，工具不知道資料必須多快到達，時序報告就沒有可靠意義。腳位號碼只對指定開發板有效，應以該板官方 master XDC 為準。

## 3. Setup 與 hold 的白話理解

同一個時脈正緣，一個暫存器送出資料、另一個暫存器接收資料。

- **setup time（建立時間）**：資料要在接收正緣之前提早穩定；路徑太慢會違反 setup。
- **hold time（保持時間）**：資料在接收正緣之後還要維持一小段時間；路徑太快可能違反 hold。
- **slack（餘裕）**：可用時間減去實際所需時間。正值代表通過，負值代表失敗。

100 MHz 的時脈週期為 10 ns。這不是每條路徑都必須剛好花 10 ns，而是所有受此時脈約束的同步路徑都必須滿足工具計算出的限制。

## 4. UART 8N1 frame

UART（universal asynchronous receiver/transmitter，通用非同步收發器）沒有共享時脈。發送端與接收端事先約定鮑率（baud rate：每秒傳送的符號數）；本週使用 115200。

8N1 表示：閒置為 `1`，接著 1 個起始位元 `0`、8 個資料位元（**最低位元 LSB 先送**）、無 parity（同位元檢查）、1 個停止位元 `1`。

`8'h55` 的二進位是 `0101_0101`。線上順序為：

```text
idle  start  d0 d1 d2 d3 d4 d5 d6 d7  stop
  1      0    1  0  1  0  1  0  1  0    1
```

## 5. 用計數器建立位元時間

100 MHz 時脈搭配 115200 鮑率，每個 UART 位元理想上是 `100,000,000 / 115,200 = 868.055...` 個時脈。整數計數器不能表達小數，範例採用 868 個時脈；誤差很小，適合此入門示範。若時脈與鮑率可整除，位元時間最直觀，例如 testbench 使用 1 MHz / 100 k = 10。

`uart_tx` 用 FSM 依序待在 `IDLE`、`START`、`DATA`、`STOP`。`data_reg` 在接受 `start` 時鎖住資料，因此傳送中就算外部 `data` 改變，正在傳的 frame 也不會被破壞；`busy` 為 1 時忽略新的 `start`。

## 6. 由模擬走到上板的除錯順序

1. 先確認 `make test-week04` 通過。
2. 在波形找 `tx`：每一位元必須維持 `CLKS_PER_BIT` 個 `clk` 週期。
3. 檢查約束中的 port 名稱與 top module 完全相同。
4. 檢查時序報告中的時脈週期、未約束路徑、setup 與 hold。
5. 終端機顯示錯誤時，先檢查鮑率與 UART 設定；完全沒資料才回頭查腳位和 USB 線。

## 7. 口述驗收

1. 為什麼 `create_clock` 不等於把時脈「產生」出來？
2. setup 與 hold 分別對應「太慢」還是「太快」？
3. 為什麼 UART 的起始位元是 0、閒置是 1？
4. `8'h55` 在 TX 線上第一個資料位元是 0 還是 1？為什麼？
5. 為什麼 UART 傳送器要在收到 `start` 時先把 `data` 存到 `data_reg`？
