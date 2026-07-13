# 第 4 週：FPGA 開發流程、時序約束與 UART TX

本週第一次把已模擬的 RTL 做成可燒錄的 FPGA 設計。你會建立時脈約束、讀懂基本時序報告，並讓開發板透過 USB-UART 每半秒傳送一次字元 `U`。

預估投入：7 小時。預設上板目標是 **Digilent Basys 3**；若使用 Arty S7，仍可使用相同 RTL，但必須改用該板的時脈頻率與官方 `.xdc` 腳位。

## 本週完成條件

- 能說明 synthesis（綜合：把 RTL 轉為邏輯電路）、implementation（實作：放置與繞線）與 bitstream（位元流：燒入 FPGA 的設定檔）的順序。
- 能說明時脈約束 `create_clock` 為何不可省略，並在報告確認沒有未約束時脈。
- 能區分 setup 與 hold：前者是資料不能太晚到，後者是資料不能太早變。
- 能用 `uart_tx` 送出正確的 8N1 UART frame（1 起始、8 資料、無同位元、1 停止）。
- `make test-week04` 顯示 `tb_uart_tx: PASS`；上板後終端機可重複收到 `U`。

## 建議進度

| 時間 | 工作 |
| --- | --- |
| 1.5 小時 | 閱讀 `lesson.md` 第 1～4 節；在紙上畫出 `0x55` 的 UART frame。 |
| 1 小時 | 執行 UART testbench，於 GTKWave 檢查起始、資料與停止位元。 |
| 2 小時 | 在 Vivado 建立 Basys 3 專案、加入 RTL 與約束，完成 synthesis/implementation。 |
| 1.5 小時 | 檢查時序報告後產生 bitstream，燒錄並以終端機觀察輸出。 |
| 1 小時 | 完成 `exercises.md` 與驗收紀錄。 |

## 先跑模擬

在專案根目錄執行：

```powershell
make test-week04
gtkwave week04_fpga_flow_uart_tx/build/uart_tx.vcd
```

`tb_uart_tx: PASS` 表示模擬檢查了閒置高電位、起始位元、LSB-first 資料位元、停止位元，以及忙碌時忽略重複 `start`。

## Basys 3 上板步驟（Vivado）

1. 建立 RTL Project，選擇 Basys 3 對應的 FPGA part（可從板檔或開發板文件確認）。
2. 加入 `src/uart_tx.sv`、`src/uart_demo_top.sv`，並設 `uart_demo_top` 為 top module。
3. 加入 `constraints/basys3_uart_demo.xdc`。此範例預設 `clk` 為 100 MHz、鮑率為 115200；`btnc` 是中間按鈕，按住時重設。
4. 先執行 **Run Synthesis**，再執行 **Run Implementation**。在實作完成前不要產生 bitstream。
5. 開啟 **Report Timing Summary**：確認 `sys_clk` 被辨識為 10 ns 時脈、`Unconstrained Paths` 為 0、setup/hold 均沒有 failing endpoints。
6. 產生 bitstream，用 Hardware Manager 將它燒到 FPGA。
7. 開啟對應的 USB Serial Port（115200, 8N1, no flow control）。每約 0.5 秒應看到一個 `U`；LED 同步翻轉。

按鈕 reset 在不同板子上的極性與腳位不同。Basys 3 範例使用中間按鈕 `btnc`，並在 RTL 以兩級同步器處理它；換板時請一併更新 top port 與約束。

## 常見狀況

- 終端機顯示亂碼：鮑率、資料位元、停止位元或所選序列埠不一致；先確認為 115200 8N1。
- `Unconstrained Paths` 不是 0：先修正或補上時脈約束，不要忽略警告。
- `uart_txd` 沒有輸出：確認 top module、A18 腳位與 USB 資料線，而非只接供電的線。
- 開機只看見一次字元：確認終端機在 bitstream 下載後才開啟，並等待半秒。
