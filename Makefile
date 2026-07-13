.PHONY: test test-week01 test-week02 test-week03 test-week04 lint clean

IVERILOG := iverilog
VVP := vvp

test: test-week01 test-week02 test-week03 test-week04

test-week01:
	mkdir -p week01_digital_logic/build
	cd week01_digital_logic && $(IVERILOG) -g2012 -o build/comb.out src/comb_logic.sv sim/tb_comb_logic.sv
	cd week01_digital_logic && $(VVP) build/comb.out
	cd week01_digital_logic && $(IVERILOG) -g2012 -o build/counter.out src/counter.sv sim/tb_counter.sv
	cd week01_digital_logic && $(VVP) build/counter.out

test-week02:
	mkdir -p week02_systemverilog/build
	cd week02_systemverilog && $(IVERILOG) -g2012 -o build/param_counter.out src/param_counter.sv sim/tb_param_counter.sv
	cd week02_systemverilog && $(VVP) build/param_counter.out
	cd week02_systemverilog && $(IVERILOG) -g2012 -o build/pwm.out src/pwm.sv sim/tb_pwm.sv
	cd week02_systemverilog && $(VVP) build/pwm.out
	cd week02_systemverilog && $(IVERILOG) -g2012 -o build/button_debouncer.out src/button_debouncer.sv sim/tb_button_debouncer.sv
	cd week02_systemverilog && $(VVP) build/button_debouncer.out

test-week03:
	mkdir -p week03_testbench_fsm/build
	cd week03_testbench_fsm && $(IVERILOG) -g2012 -o build/sequence_detector.out src/sequence_detector.sv sim/tb_sequence_detector.sv
	cd week03_testbench_fsm && $(VVP) build/sequence_detector.out

test-week04:
	mkdir -p week04_fpga_flow_uart_tx/build
	cd week04_fpga_flow_uart_tx && $(IVERILOG) -g2012 -o build/uart_tx.out src/uart_tx.sv sim/tb_uart_tx.sv
	cd week04_fpga_flow_uart_tx && $(VVP) build/uart_tx.out

lint:
	verilator --lint-only -Wall week01_digital_logic/src/*.sv
	verilator --lint-only -Wall week02_systemverilog/src/*.sv
	verilator --lint-only -Wall week03_testbench_fsm/src/*.sv
	verilator --lint-only -Wall week04_fpga_flow_uart_tx/src/*.sv

clean:
	rm -rf week01_digital_logic/build week02_systemverilog/build week03_testbench_fsm/build week04_fpga_flow_uart_tx/build
