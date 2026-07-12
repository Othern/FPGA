# 第 1 週：數位邏輯、時脈與重設

本週目標是在不使用開發板的前提下，理解硬體描述語言的基本思維，並用模擬結果驗證兩類電路：組合邏輯與循序邏輯。

預估投入：7 小時。

## 本週完成條件

- 能說明組合邏輯與循序邏輯的差異。
- 能說明為何暫存器通常要在時脈邊緣才更新。
- 能用波形確認 reset、計數與 overflow 行為。
- 通過 `tb_comb_logic.sv` 與 `tb_counter.sv` 的所有測試。

## 建議進度

| 時間 | 工作 |
| --- | --- |
| 1 小時 | 閱讀 `lesson.md` 的第 1 至 3 節。 |
| 1.5 小時 | 閱讀並手動推演 `src/comb_logic.sv`。 |
| 1.5 小時 | 閱讀並手動推演 `src/counter.sv`。 |
| 1.5 小時 | 執行兩個 testbench、開啟波形。 |
| 1.5 小時 | 完成 `exercises.md` 的挑戰題。 |

## 資料夾結構

```text
week01_digital_logic/
├── lesson.md             # 中文講義
├── exercises.md          # 練習與驗收題
├── answers.md            # 學生作答與批改紀錄
├── src/
│   ├── comb_logic.sv     # 組合邏輯範例
│   └── counter.sv        # 同步計數器範例
└── sim/
    ├── tb_comb_logic.sv  # 組合邏輯測試
    └── tb_counter.sv     # 計數器測試
```

## 執行模擬
### 檔案之間的關係
```
src/counter.sv
       │
       │ 被 testbench 實例化
       ▼
sim/tb_counter.sv
       │
       │ iverilog 編譯
       ▼
build/counter.out
       │
       │ vvp 執行模擬
       ▼
build/counter.vcd
       │
       │ GTKWave 讀取
       ▼
     波形圖
```
- `counter.sv` 定義「電路應該怎麼運作」
- `tb_counter.sv` 定義「要怎麼刺激與檢查這個電路」
- `counter.out` 是兩個 SystemVerilog 檔案編譯後的模擬程式
- `counter.vcd` 是執行模擬後產生的訊號變化紀錄
- `GTKWave` 把 counter.vcd 顯示成波形
### 指令
全課程安裝方式以根目錄的 `SETUP.md` 為準。請先建立 `build/`，再於本資料夾執行：

```powershell
mkdir -p build
iverilog -g2012 -o build/comb.out src/comb_logic.sv sim/tb_comb_logic.sv
vvp build/comb.out

iverilog -g2012 -o build/counter.out src/counter.sv sim/tb_counter.sv
vvp build/counter.out
gtkwave build/counter.vcd
```

預期兩個模擬都輸出 `PASS`。`*.vcd` 是波形檔；請觀察 `clk` 上升沿、`rst_n` 與 `count` 的關係。

> 注意：testbench 中的 `#` 延遲只用來產生模擬刺激，不能放入要綜合至 FPGA 的設計模組。