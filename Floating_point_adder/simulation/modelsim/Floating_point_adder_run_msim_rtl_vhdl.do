transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {E:/FPGA_Project/Midterm_Project/Floating_point_adder/Floating_point_adder_main.vhd}
vcom -93 -work work {E:/FPGA_Project/Midterm_Project/Floating_point_adder/FullAdder_Sub_Module.vhd}
vcom -93 -work work {E:/FPGA_Project/Midterm_Project/Floating_point_adder/FullAdder_Exponent.vhd}
vcom -93 -work work {E:/FPGA_Project/Midterm_Project/Floating_point_adder/FullAdder_Mantissa.vhd}
vcom -93 -work work {E:/FPGA_Project/Midterm_Project/Floating_point_adder/Shift_right_left.vhd}

vcom -93 -work work {E:/FPGA_Project/Midterm_Project/Floating_point_adder/simulation/modelsim/Floating_point_adder_main.vht}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="+acc"  Floating_point_adder_testbench

add wave *
view structure
view signals
run -all
