# 第 3 週：Testbench、自動檢查、波形除錯與 FSM

本週把「看波形判斷大概正確」提升成「測試會自行判斷正誤」。你會用 testbench（測試平台：只在模擬中產生輸入並檢查輸出的程式）、assertion（斷言：條件不成立時立即報錯）和波形定位問題，最後完成一個序列偵測 FSM。

預估投入：7 小時。

## 本週完成條件

- 能說明 DUT、stimulus、checker 與 reference model 的用途。
- 能避免在時脈邊緣同時改輸入與檢查輸出造成競爭（race condition）。
- 能用 `assert ... else $fatal` 自動檢查正常與邊界情況。
- 能說明 FSM（finite-state machine，有限狀態機）的狀態、轉移、輸入與輸出。
- 能在執行前預測序列 `1011011` 的狀態與 `detected` 波形。
- 修改偵測序列或測試資料後，能同步更新 testbench 並通過測試。

## 建議進度

| 時間 | 工作 |
| --- | --- |
| 1.5 小時 | 閱讀 `lesson.md` 第 1～3 節，理解 testbench 結構與時脈競爭。 |
| 1.5 小時 | 執行 `tb_sequence_detector.sv`，先讀終端輸出，再用 GTKWave 核對波形。 |
| 1.5 小時 | 閱讀 FSM 的三段式寫法，手動畫出狀態圖與預測表。 |
| 1.5 小時 | 完成 `exercises.md` 練習 1～3。 |
| 1 小時 | 完成本週驗收紀錄：解釋、預測、修改、重新測試。 |

## 執行模擬

在專案根目錄執行 `make test-week03`，或在本資料夾執行：

```powershell
mkdir -p build
iverilog -g2012 -o build/sequence_detector.out src/sequence_detector.sv sim/tb_sequence_detector.sv
vvp build/sequence_detector.out
gtkwave build/sequence_detector.vcd
```

看到 `tb_sequence_detector: PASS` 代表自動測試全部通過。
