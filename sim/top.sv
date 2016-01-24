/* Testbench */

module top;
   timeunit 1ns;
   timeprecision 1ps;

   bit rst_i; // reset
   bit clk_i; // clock

   if_wb wbm(.*);
   if_wb wbs(.*);

   j1_wb    dut  (.wb(wbm));
   wb_slave slave(.wb(wbs));

   /* Interconnection */
   assign wbm.dat_i = wbs.dat_o;
   assign wbm.ack_i = wbs.ack_o;

   assign wbs.adr_i = wbm.adr_o;
   assign wbs.dat_i = wbm.dat_o;
   assign wbs.we_i  = wbm.we_o;
   assign wbs.cyc_i = wbm.cyc_o;
   assign wbs.stb_i = (wbm.cyc_o && wbm.adr_o[15:4] == 'h400) ? wbm.stb_o : 1'b0;

   always #5ns clk_i = ~clk_i;

   initial
     begin
	$timeformat(-9, 3, " ns");
	$readmemh("j1.hex", dut.dpram.mem);

	rst_i = 1'b1;
	repeat(2) @(negedge clk_i);
	rst_i = 1'b0;

	repeat(50) @(negedge clk_i);
	$stop;
     end
endmodule
