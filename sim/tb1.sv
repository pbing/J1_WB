/* Testbench */

`default_nettype none

module tb1;
   timeunit 1ns;
   timeprecision 1ps;

   bit reset; // reset
   bit clk;   // clock

   if_ibus ibus();
   if_dbus dbus();

   j1_core       dut(.*);
   rom_wrapper   rom(.*);
   spram_wrapper ram(.*);

   always #5ns clk = ~clk;

   initial
     begin
	$timeformat(-9, 3, " ns");

        /* load ROM image */
	$readmemh("j1.hex", tb1.rom.rom.mem);

	reset = 1'b1;
	repeat(2) @(negedge clk);
	reset = 1'b0;

	repeat(350) @(negedge clk);
	$finish;
     end
endmodule

`resetall
