# 第 3 週學生作答紀錄
## 練習 1：手算波形

### `0000`

| 次數 | 輸入 | 取樣後狀態 | `detected` |
| ---: | ---: | --- | ---: |
| 1 | 0 | `IDLE` | 0 |
| 2 | 0 | `IDLE` | 0 |
| 3 | 0 | `IDLE` | 0 |
| 4 | 0 | `IDLE` | 0 |

### `101`

| 次數 | 輸入 | 取樣後狀態 | `detected` |
| ---: | ---: | --- | ---: |
| 1 | 1 | `GOT_1` | 0 |
| 2 | 0 | `GOT_10` | 0 |
| 3 | 1 | `GOT_1` | 1 |

### `10101`

| 次數 | 輸入 | 取樣後狀態 | `detected` |
| ---: | ---: | --- | ---: |
| 1 | 1 | `GOT_1` | 0 |
| 2 | 0 | `GOT_10` | 0 |
| 3 | 1 | `GOT_1` | 1 |
| 4 | 0 | `GOT_10` | 0 |
| 5 | 1 | `GOT_1` | 1 |

### `1101001`

| 次數 | 輸入 | 取樣後狀態 | `detected` |
| ---: | ---: | --- | ---: |
| 1 | 1 | `GOT_1` | 0 |
| 2 | 1 | `GOT_1` | 0 |
| 3 | 0 | `GOT_10` | 0 |
| 4 | 1 | `GOT_1` | 1 |
| 5 | 0 | `GOT_10` | 0 |
| 6 | 0 | `IDLE` | 0 |
| 7 | 1 | `GOT_1` | 0 |

## 練習 2：驗證測試能抓錯
改在
    - `sequence_detector.sv`
    - `tb_sequence_detector_fail.sv`
可以透過以下指令進行模擬
```
iverilog -g2012 -o build/sequence_detector_fail.out src/sequence_detector_fail.sv sim/tb_sequence_detector_fail.sv
vvp build/sequence_detector_fail.out
gtkwave build/sequence_detector_fail.vcd
```
將 `GOT_10` 收到 `1` 的下一狀態暫時改成 `IDLE`。

預測：單次 `101` 仍會通過，因為 `detected` 是由目前狀態
`GOT_10` 與輸入 `1` 決定，不依賴下一狀態。

但 `10101` 會在第 5 個 bit 失敗。正常設計在第 3 個 bit 偵測到
第一個 `101` 後應回到 `GOT_1`，讓最後兩個 bit `01` 與前面的
重疊開頭組成第二個 `101`。錯誤設計改回 `IDLE`，因此第 5 個 bit
無法再次偵測到序列。