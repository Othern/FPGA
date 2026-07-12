# 第 2 週學生作答紀錄
## 練習 1

### 指令
```powershell
iverilog -g2012 -o build/param_counter_width_5.out src/param_counter.sv sim/tb_param_counter_width_5.sv
vvp build/param_counter_width_5.out
gtkwave build/param_counter_width_5.vcd     
```
### 修改檔案
- 可以查看
    - 模擬： `./sim/tb_param_counter_width_5.sv`
    - build：
        - `param_counter_5.out`
        - `param_counter.vcd`

### 思考：為什麼 `src/param_counter.sv` 不需要修改？
因為有將 `WIDTH` 參數化，使得 module 可以根據模擬時調整相依於 `WIDTH` 的參數，包含了 `count` 寬度等等。

## 練習 2：加入遞減模式