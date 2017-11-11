/* Testbench */

module top;
   timeunit 1ns;
   timeprecision 1ps;

   bit rst; // reset
   bit clk; // clock

   if_wb wbc1(.*);
   if_wb wbc2(.*);
   if_wb wbd1(.*);
   if_wb wbd2(.*);

   j1_wb dut 
     (.sys_clk_i (clk),
      .sys_rst_i (rst),
      .wbc       (wbc1),
      .wbd       (wbd1));

   wb_rom wb_rom(.wb(wbc2));
   wb_ram wb_ram(.wb(wbd2));

   /* Interconnection */
   assign wbc1.ack   = wbc2.ack;
   assign wbc2.adr   = wbc1.adr;
   assign wbc2.cyc   = wbc1.cyc;
   assign wbc1.stall = wbc2.stall;
   assign wbc2.stb   = wbc1.stb;
   assign wbc2.we    = wbc1.we;
   assign wbc2.dat_i = wbc1.dat_o;
   assign wbc1.dat_i = wbc2.dat_o;

   assign wbd1.ack   = wbd2.ack;
   assign wbd2.adr   = wbd1.adr;
   assign wbd2.cyc   = wbd1.cyc;
   assign wbd1.stall = wbd2.stall;
   assign wbd2.stb   = wbd1.stb;
   assign wbd2.we    = wbd1.we;
   assign wbd2.dat_i = wbd1.dat_o;
   assign wbd1.dat_i = wbd2.dat_o;


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
