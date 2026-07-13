# 第 4 週練習：時序與 UART TX

## 練習 1：先預測 frame

在執行模擬前，寫出 `0x53` 的 UART 8N1 線路順序（包含 idle、start、d0 到 d7、stop）。說明第一個資料位元為何不是二進位字串最左邊那個 bit。

## 練習 2：讓測試抓到鮑率計數錯誤

暫時將 `uart_tx.sv` 中 `START` 狀態的比較改成 `CLKS_PER_BIT - 2`。先預測 testbench 是否會失敗、會在哪個檢查點失敗，再執行確認，最後恢復 RTL。思考：目前測試為何還沒有直接量測每個位元的精確長度？

## 練習 3：新增送出完成訊號

在 `uart_tx` 增加一個僅維持一個 `clk` 週期的 `done` 輸出，代表停止位元結束、模組即將回到 idle。同步修改 testbench，至少檢查 `done` 不會提早出現，也不會維持兩拍。

## 練習 4：上板與時序驗收

完成 Basys 3 或你的實際開發板的專案後，記錄：

- 板名、FPGA part、實際系統時脈。
- `.xdc` 中時脈 port、實體腳位與 period。
- Timing Summary 的 setup/hold 結果與 Unconstrained Paths 數量。
- 終端機的設定與實際看到的輸出。

若尚未取得開發板，完成練習 1～3、保留 `.xdc` 草稿，並在第 5 週前補做上板驗收即可。

## 驗收清單

- [ ] 能在不看程式下畫出 `0x55` 的 8N1 frame。
- [ ] `make test-week04` 顯示 `tb_uart_tx: PASS`。
- [ ] 能說出 `create_clock`、setup、hold 與 slack 的意義。
- [ ] 已在波形確認 LSB-first 與每位元維持固定時間。
- [ ] 已檢查實作後時序報告；或已記錄尚待上板的項目。
- [ ] 已嘗試植入錯誤、確認 testbench 會失敗，並恢復正確版本。
