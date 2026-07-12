# 第 3 週教材：從自動化測試到有限狀態機

## 1. Testbench 的四個角色

testbench（測試平台）是只在模擬中產生輸入、檢查輸出的程式，不會燒進 FPGA。

| 角色 | 白話定義 | 本週範例 |
| --- | --- | --- |
| DUT | design under test，受測設計 | `sequence_detector` |
| stimulus | 刺激，送給 DUT 的輸入 | `send_bit` task |
| checker | 檢查器，比較實際與預期值 | `assert` |
| reference model | 用直觀方法計算正確答案 | 最近三個輸入 bit |

`src/` 放可綜合（能轉成真實硬體）的 RTL；`sim/` 才能使用 `#5`、`$display`、`$fatal` 等模擬功能。

## 2. 避免時脈競爭

若 DUT 在正緣取樣，而 testbench 也在同一正緣改輸入，執行先後可能不確定。這叫 race condition（競爭條件）。本週固定採用：

1. `negedge` 改輸入；
2. `posedge` 讓 DUT 取樣；
3. 正緣後 `#1` 再檢查，等待非阻塞賦值更新完成。

```systemverilog
@(negedge clk); serial_in = value;
@(posedge clk); #1;
assert (detected === expected);
```

這個 `#1` 只用於 testbench，不可放進 RTL 假裝硬體延遲。

## 3. Assertion：讓測試自己判分

assertion（斷言）是可執行規格：條件不成立就報錯。

```systemverilog
assert (detected === expected)
    else $fatal(1, "expected=%0b actual=%0b", expected, detected);
```

checker 常用 `===`，因為它能明確抓出未知值 `X` 或高阻抗 `Z`。`$display` 只印訊息；`$fatal` 會讓自動測試失敗。錯誤訊息至少應包含測試位置、預期值與實際值。

## 4. FSM：用有限狀態記住過去

FSM（finite-state machine，有限狀態機）用有限個狀態記錄必要的歷史。本週偵測可重疊的 `101`：

| 狀態 | 記住的有效尾端 |
| --- | --- |
| `IDLE` | 無 |
| `GOT_1` | `1` |
| `GOT_10` | `10` |

```text
IDLE   --1--> GOT_1    IDLE   --0--> IDLE
GOT_1  --0--> GOT_10   GOT_1  --1--> GOT_1
GOT_10 --1--> GOT_1    GOT_10 --0--> IDLE
```

`GOT_10` 收到 `1` 時已完成 `101`，但這個 `1` 也是下一組序列的開頭，所以回到 `GOT_1`。這使 `10101` 可以命中兩次。

## 5. 三段式 FSM 與 Mealy 輸出

範例分成狀態暫存器、下一狀態組合邏輯、輸出組合邏輯。`detected` 同時依賴狀態與輸入，屬於 Mealy 型 FSM。Moore 型 FSM 的輸出只依賴狀態，通常需要額外狀態，輸出也可能晚一拍。

組合邏輯先給預設值，可避免遺漏分支而產生 latch（鎖存器：沒有時脈邊緣仍會保存資料的電路）。

## 6. 執行前預測

輸入 `1011011`：

| 次數 | 輸入 | 取樣後狀態 | `detected` |
| ---: | ---: | --- | ---: |
| reset | - | `IDLE` | 0 |
| 1 | 1 | `GOT_1` | 0 |
| 2 | 0 | `GOT_10` | 0 |
| 3 | 1 | `GOT_1` | 1 |
| 4 | 1 | `GOT_1` | 0 |
| 5 | 0 | `GOT_10` | 0 |
| 6 | 1 | `GOT_1` | 1 |
| 7 | 1 | `GOT_1` | 0 |

## 7. 波形除錯順序

在 GTKWave 依序加入 `clk`、`rst_n`、`serial_in`、`dut.state`、`dut.next_state`、`detected`。找「第一個與預測不同的週期」：狀態先錯就查轉移；狀態正確但輸出錯就查輸出；波形正確但 assertion 失敗就查 checker 的取樣時機。

## 8. 口述驗收

1. 為什麼 testbench 可用 `#`，RTL 卻不應用它實現功能？
2. 為什麼負緣改輸入、正緣後才檢查？
3. `assert` 與只用 `$display` 有何差別？
4. 為什麼 `GOT_10` 收到 `1` 後不是回 `IDLE`？
5. 同步 reset 若未跨過任何正緣，電路會被重設嗎？

