/* Testbench */

module top;
   timeunit 1ns;
   timeprecision 1ps;

   bit rst; // reset
   bit clk; // clock

   if_wb wbm1(.*);   // J1 code bus
   if_wb wbs1(.*);   // ROM

   if_wb wbm2(.*);   // J1 data bus
   if_wb wbs2_1(.*); // RAM
   if_wb wbs2_2(.*); // I/O

   j1_wb dut 
     (.sys_clk_i (clk),
      .sys_rst_i (rst),
      .wbc       (wbm1),
      .wbd       (wbm2));

   wb_rom wb_rom(.wb(wbs1));
   wb_ram wb_ram(.wb(wbs2_1));

   wb_intercon wb_intercon (.*);

   always #5ns clk = ~clk;

   initial
     begin
	$timeformat(-9, 3, " ns");
	$readmemh("j1.hex", top.wb_rom.rom.mem);

	rst = 1'b1;
	repeat(2) @(negedge clk);
	rst = 1'b0;

	repeat(100) @(negedge clk);
	$finish;
     end
endmodule
