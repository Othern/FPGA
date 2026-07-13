## Basys 3: 100 MHz oscillator, LED0, and USB-UART FPGA transmit pin.
## This file is board-specific.  Do not reuse these pin locations for another board.
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -add -name sys_clk -period 10.000 -waveform {0 5} [get_ports { clk }]

set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { led }]
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports { uart_txd }]
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { btnc }]
