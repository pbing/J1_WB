/* Testbench */

module tb1;
   timeunit 1ns;
   timeprecision 1ps;

   bit reset; // reset
   bit clk;   // clock

   if_ibus ibus();
   if_dbus dbus();

   j1_core dut(.*);

   rom
     #(.size('h2000))
   rom
     (.clock   (clk),
      .address (ibus.adr[12:0]),
      .q       (ibus.dat),
      .cen     (ibus.re));

   spram
     #(.size('h1000))
   ram
     (.clock   (clk),
      .address (dbus.adr[11:0]),
      .data    (dbus.dat_o),
      .q       (dbus.dat_i),
      .wren    (dbus.we),
      .cen     (dbus.re | dbus.we));

   always #5ns clk = ~clk;

   initial
     begin
	$timeformat(-9, 3, " ns");

        /* load ROM image */
	$readmemh("j1.hex", tb1.rom.mem);

	reset = 1'b1;
	repeat(2) @(negedge clk);
	reset = 1'b0;

	repeat(350) @(negedge clk);
	$finish;
     end
endmodule
