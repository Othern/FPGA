# 第 2 週：SystemVerilog 模組化與可重用設計

本週把第 1 週的「看懂一段電路」進一步變成「寫出能在不同情況重複使用的電路」。重點是用參數調整硬體規模，而不是複製貼上多份程式。

預估投入：7 小時。

## 本週完成條件

- 能說出 `module` 的輸入、輸出與實例化（instantiation，將模組接入另一個模組）各自的用途。
- 能分辨 `logic`、`parameter`、`localparam` 與位元寬度 `[N-1:0]`。
- 能以 `always_comb` 寫完整的組合邏輯、以 `always_ff` 寫暫存器。
- 能修改 `param_counter` 的 `WIDTH`，並讓測試仍通過。
- 能解釋 PWM（脈衝寬度調變）：為何改變高電位所占比例能改變 LED 平均亮度。
- 選做：能說明兩級同步器與按鍵除彈跳的用途；尚未熟悉不影響進入第 3 週。

## 建議進度

| 時間 | 工作 |
| --- | --- |
| 1.5 小時 | 閱讀 `lesson.md` 第 1～4 節，手動畫出 `param_counter` 方塊圖。 |
| 1.5 小時 | 閱讀 PWM 範例並執行 `tb_pwm.sv`，在波形中數高電位週期。 |
| 1 小時 | 選做：閱讀按鍵除彈跳範例，理解同步化與穩定計數。 |
| 1.5 小時 | 完成 `exercises.md` 的練習 1～3。 |
| 1.5 小時 | 回答驗收題、預測波形並記錄不確定的概念。 |

## 資料夾結構

```text
week02_systemverilog/
├── lesson.md
├── exercises.md
├── src/
│   ├── param_counter.sv     # 可調整位元寬度的計數器
│   ├── pwm.sv               # LED 亮度控制範例
│   └── button_debouncer.sv  # 同步化與按鍵除彈跳範例
└── sim/
    ├── tb_param_counter.sv
    ├── tb_pwm.sv
    └── tb_button_debouncer.sv
```

## 執行模擬

安裝方式統一參考根目錄的 `SETUP.md`。在本資料夾建立 `build/` 並執行下列命令；`#` 延遲只存在於 testbench，設計檔 `src/` 內沒有用它建立硬體延遲。

```powershell
mkdir -p build
iverilog -g2012 -o build/param_counter.out src/param_counter.sv sim/tb_param_counter.sv
vvp build/param_counter.out

iverilog -g2012 -o build/pwm.out src/pwm.sv sim/tb_pwm.sv
vvp build/pwm.out

iverilog -g2012 -o build/button_debouncer.out src/button_debouncer.sv sim/tb_button_debouncer.sv
vvp build/button_debouncer.out

gtkwave build/pwm.vcd
```

核心驗收以 `param_counter` 與 `pwm` 顯示 `PASS` 為準；`button_debouncer` 是選做。安裝方式統一參考根目錄的 `SETUP.md`；第 3 週將專門練習測試平台與波形除錯。
