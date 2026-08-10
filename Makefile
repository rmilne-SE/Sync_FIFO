all:
	mkdir -p build
	iverilog -g2012 -o build/fifo_top.out rtl/fifo.sv tb/assertions.sv tb/coverage.sv tb/driver.sv tb/monitor.sv tb/scoreboard.sv tb/tb_fifo.sv
	vvp build/fifo_top.out