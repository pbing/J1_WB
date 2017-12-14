# Constraints

set clk_period [expr 1.0e9/120.0e6]

create_clock -period $clk_period [get_ports clk]

set_input_delay  -clock [get_clocks clk] 1.0 [remove_from_collection [all_inputs] [get_ports {clk wb.dat_s}]]
set_input_delay  -clock [get_clocks clk] 7.33 [get_ports wb.dat_s]
set_output_delay -clock [get_clocks clk] 0.0 [all_outputs]
