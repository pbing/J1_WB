###################################################################

# Created by write_sdc on Thu Dec 14 10:10:32 2017

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_wire_load_selection_group WireAreaLowkCon
create_clock [get_ports clk]  -period 2.5  -waveform {0 1.25}
group_path -name FEEDTHROUGH  -from [list [get_ports reset] [get_ports wb_clk] [get_ports wb_rst] [get_ports wb_ack] [get_ports wb_stall] [get_ports {wb_dat_s[15]}] [get_ports {wb_dat_s[14]}] [get_ports {wb_dat_s[13]}] [get_ports {wb_dat_s[12]}] [get_ports {wb_dat_s[11]}] [get_ports {wb_dat_s[10]}] [get_ports {wb_dat_s[9]}] [get_ports {wb_dat_s[8]}] [get_ports {wb_dat_s[7]}] [get_ports {wb_dat_s[6]}] [get_ports {wb_dat_s[5]}] [get_ports {wb_dat_s[4]}] [get_ports {wb_dat_s[3]}] [get_ports {wb_dat_s[2]}] [get_ports {wb_dat_s[1]}] [get_ports {wb_dat_s[0]}]]  -to [list [get_ports {wb_adr[15]}] [get_ports {wb_adr[14]}] [get_ports {wb_adr[13]}] [get_ports {wb_adr[12]}] [get_ports {wb_adr[11]}] [get_ports {wb_adr[10]}] [get_ports {wb_adr[9]}] [get_ports {wb_adr[8]}] [get_ports {wb_adr[7]}] [get_ports {wb_adr[6]}] [get_ports {wb_adr[5]}] [get_ports {wb_adr[4]}] [get_ports {wb_adr[3]}] [get_ports {wb_adr[2]}] [get_ports {wb_adr[1]}] [get_ports {wb_adr[0]}] [get_ports wb_cyc] [get_ports wb_stb] [get_ports wb_we] [get_ports {wb_dat_m[15]}] [get_ports {wb_dat_m[14]}] [get_ports {wb_dat_m[13]}] [get_ports {wb_dat_m[12]}] [get_ports {wb_dat_m[11]}] [get_ports {wb_dat_m[10]}] [get_ports {wb_dat_m[9]}] [get_ports {wb_dat_m[8]}] [get_ports {wb_dat_m[7]}] [get_ports {wb_dat_m[6]}] [get_ports {wb_dat_m[5]}] [get_ports {wb_dat_m[4]}] [get_ports {wb_dat_m[3]}] [get_ports {wb_dat_m[2]}] [get_ports {wb_dat_m[1]}] [get_ports {wb_dat_m[0]}]]
group_path -name REGIN  -from [list [get_ports reset] [get_ports wb_clk] [get_ports wb_rst] [get_ports wb_ack] [get_ports wb_stall] [get_ports {wb_dat_s[15]}] [get_ports {wb_dat_s[14]}] [get_ports {wb_dat_s[13]}] [get_ports {wb_dat_s[12]}] [get_ports {wb_dat_s[11]}] [get_ports {wb_dat_s[10]}] [get_ports {wb_dat_s[9]}] [get_ports {wb_dat_s[8]}] [get_ports {wb_dat_s[7]}] [get_ports {wb_dat_s[6]}] [get_ports {wb_dat_s[5]}] [get_ports {wb_dat_s[4]}] [get_ports {wb_dat_s[3]}] [get_ports {wb_dat_s[2]}] [get_ports {wb_dat_s[1]}] [get_ports {wb_dat_s[0]}]]
group_path -name REGOUT  -to [list [get_ports {wb_adr[15]}] [get_ports {wb_adr[14]}] [get_ports {wb_adr[13]}] [get_ports {wb_adr[12]}] [get_ports {wb_adr[11]}] [get_ports {wb_adr[10]}] [get_ports {wb_adr[9]}] [get_ports {wb_adr[8]}] [get_ports {wb_adr[7]}] [get_ports {wb_adr[6]}] [get_ports {wb_adr[5]}] [get_ports {wb_adr[4]}] [get_ports {wb_adr[3]}] [get_ports {wb_adr[2]}] [get_ports {wb_adr[1]}] [get_ports {wb_adr[0]}] [get_ports wb_cyc] [get_ports wb_stb] [get_ports wb_we] [get_ports {wb_dat_m[15]}] [get_ports {wb_dat_m[14]}] [get_ports {wb_dat_m[13]}] [get_ports {wb_dat_m[12]}] [get_ports {wb_dat_m[11]}] [get_ports {wb_dat_m[10]}] [get_ports {wb_dat_m[9]}] [get_ports {wb_dat_m[8]}] [get_ports {wb_dat_m[7]}] [get_ports {wb_dat_m[6]}] [get_ports {wb_dat_m[5]}] [get_ports {wb_dat_m[4]}] [get_ports {wb_dat_m[3]}] [get_ports {wb_dat_m[2]}] [get_ports {wb_dat_m[1]}] [get_ports {wb_dat_m[0]}]]
set_input_delay -clock clk  1  [get_ports clk]
set_input_delay -clock clk  1  [get_ports reset]
set_input_delay -clock clk  1  [get_ports wb_clk]
set_input_delay -clock clk  1  [get_ports wb_rst]
set_input_delay -clock clk  1  [get_ports wb_ack]
set_input_delay -clock clk  1  [get_ports wb_stall]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[15]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[14]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[13]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[12]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[11]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[10]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[9]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[8]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[7]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[6]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[5]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[4]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[3]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[2]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[1]}]
set_input_delay -clock clk  1  [get_ports {wb_dat_s[0]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[15]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[14]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[13]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[12]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[11]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[10]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[9]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[8]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[7]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[6]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[5]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[4]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[3]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[2]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[1]}]
set_output_delay -clock clk  0  [get_ports {wb_adr[0]}]
set_output_delay -clock clk  0  [get_ports wb_cyc]
set_output_delay -clock clk  0  [get_ports wb_stb]
set_output_delay -clock clk  0  [get_ports wb_we]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[15]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[14]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[13]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[12]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[11]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[10]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[9]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[8]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[7]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[6]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[5]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[4]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[3]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[2]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[1]}]
set_output_delay -clock clk  0  [get_ports {wb_dat_m[0]}]
