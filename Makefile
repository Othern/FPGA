.PHONY: test test-week01 test-week02 lint clean

IVERILOG := iverilog
VVP := vvp

test: test-week01 test-week02

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

lint:
	verilator --lint-only -Wall week01_digital_logic/src/*.sv
	verilator --lint-only -Wall week02_systemverilog/src/*.sv

clean:
	rm -rf week01_digital_logic/build week02_systemverilog/build
