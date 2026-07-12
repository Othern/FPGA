# 第 2 週練習：寫出可重用的電路

請先自行完成，再執行模擬。練習的 RTL 不可使用 `#` 延遲。

## 練習 1：改變計數器大小

1. 在 `tb_param_counter.sv` 中把 `.WIDTH(3)` 改成 `.WIDTH(5)`。
2. 將測試中的最大值與回捲次數調整為 5-bit 計數器。
3. 執行模擬，確認 `count` 從 31 回到 0。

思考：為什麼 `src/param_counter.sv` 不需要修改？

## 練習 2：加入遞減模式

複製 `param_counter.sv` 為 `up_down_counter.sv`，加入 `input logic up`：

- `up=1` 時遞增。
- `up=0` 時遞減。
- `enable=0` 時保持數值。
- reset 後為 0。

提示：時序邏輯中的兩個分支都用 non-blocking assignment，例如 `count <= count - 1'b1;`。

## 練習 3：PWM 呼吸燈的思考題

若把 `duty` 每隔一段時間加 1，達到最大值後再每隔一段時間減 1，LED 會呈現呼吸效果。

請畫出一個狀態圖，至少包含：遞增、遞減、最大值轉向、最小值轉向。先不用撰寫 RTL；下週學完 testbench 後再嘗試實作。

FSM（finite-state machine，有限狀態機）是用有限個狀態描述控制流程的電路；第 3 週會正式學習其 RTL 與測試方式。

## 練習 4：驗收問答

1. `parameter` 與 `localparam` 的差別是什麼？
2. 為何參數化計數器 reset 時用 `'0` 比 `8'd0` 更適合？
3. 在 4-bit PWM 中，`duty=8` 為什麼約等於 50% 占空比？
4. `always_comb` 少了某些條件分支的賦值，可能造成什麼硬體？
5. 選做：按鍵為什麼要先經過兩級同步器，再做除彈跳？

## 三層驗收

- 解釋：能說明 `parameter`、位元寬度與 PWM 占空比。
- 預測：執行 `tb_pwm.sv` 前，先預測 `duty=4` 與 `duty=8` 時的高電位週期數。
- 修改：將 `param_counter` 改為 5-bit 實例，並同步更新 testbench 的訊號寬度和預期值。

## 自我評量

核心題答對並通過 `param_counter`、`pwm` 測試即可進入第 3 週。按鍵除彈跳與其 testbench 為選做；完成後可在 GTKWave 觀察 `btn_raw`、`btn_sync`、`btn_clean` 的先後關係。
