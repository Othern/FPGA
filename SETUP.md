# FPGA 教材環境設定

本檔是全課程共用的安裝與驗證入口。OSS CAD Suite 是工具集合，包含本課會使用的 Icarus Verilog、Verilator、GTKWave 與 Yosys。

## 工具用途

- Icarus Verilog：編譯並執行 SystemVerilog 模擬。
- GTKWave：讀取 VCD（value change dump，記錄訊號隨時間變化的波形檔）。
- Verilator lint：靜態檢查，不執行模擬便找出語法錯誤和可疑寫法。
- Yosys：synthesis（綜合，將 RTL 轉換成邏輯元件）工具；前期用於基本結構檢查。

## 建議系統

- 前三週模擬：Windows、macOS、Linux 皆可。
- 第四週開始使用廠商工具與開發板：以 Windows 10/11 為主要教學環境。
- VS Code 只負責編輯程式；模擬器仍需另外安裝。

## 安裝 OSS CAD Suite

1. 從 YosysHQ 的 `oss-cad-suite-build` Releases 下載符合系統的壓縮檔。
2. 解壓縮到不會任意移動的位置。Windows 路徑避免空格；macOS/Linux 可放在 `~/tools/oss-cad-suite`。
3. 啟用環境：

Windows PowerShell：

```powershell
C:\tools\oss-cad-suite\environment.ps1
```

macOS 或 Linux：

```bash
source "$HOME/tools/oss-cad-suite/environment"
```

macOS 若因下載隔離屬性無法執行，可對安裝目錄執行：

```bash
xattr -dr com.apple.quarantine "$HOME/tools/oss-cad-suite"
```

## 驗證安裝

```bash
iverilog -V
vvp -V
verilator --version
yosys -V
```

任一命令出現 `command not found`，通常表示尚未載入 `environment`，或安裝路徑不正確。

## 執行全部現有測試

在專案根目錄執行：

```bash
make test
```

`make`（建置工具：依 Makefile 中的規則執行一組命令）會建立 `build/`，編譯並執行第一、二週的 testbench。若 Windows 沒有 `make`，可依各週 README 逐條執行 `iverilog` 與 `vvp`。

## 查看波形

```bash
gtkwave week01_digital_logic/build/counter.vcd
gtkwave week02_systemverilog/build/pwm.vcd
```

開發板廠商工具與腳位驅動將在選定 Basys 3 或 Arty S7 後，於第 4 週另行設定。
