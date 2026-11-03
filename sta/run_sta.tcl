read_liberty lib/NangateOpenCellLibrary_typical.lib
read_verilog sta/alu_netlist.v
link_design alu

create_clock -name vclk -period 10

set_input_delay 1.0 -clock vclk [all_inputs]
set_output_delay 1.0 -clock vclk [all_outputs]

report_checks -path_delay max -format full -digits 3
report_checks -path_delay min -format full -digits 3
report_wns
report_tns

