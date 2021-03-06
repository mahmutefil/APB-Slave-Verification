if [file exists work] {vdel -lib work -all}

vlib work

vcom APB_Slavee.vhd


vlog ./tbench_top.sv


vsim work.tbench_top -vopt



add wave -position end sim:/tbench_top/i_intf/*
add wave -position end sim:/tbench_top/DUT/*

run 500000 ns

coverage save -onexit result.ucdb; run -all
coverage report -output result.txt -srcfile=* -detail -option -cvg