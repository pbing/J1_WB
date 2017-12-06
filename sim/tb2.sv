/* Testbench */

`default_nettype none

module tb2;
   timeunit 1ns;
   timeprecision 1ps;

   bit reset; // reset
   bit clk;   // clock

   if_wb wbm (.rst(reset), .clk);
   if_wb wbs1(.rst(reset), .clk);
   if_wb wbs2(.rst(reset), .clk);
   if_wb wbs3(.rst(reset), .clk);
   if_wb wbs4(.rst(reset), .clk);
   if_wb wbs5(.rst(reset), .clk);

   j1_wb dut(.wb(wbm), .*);

   wb_rom wb_rom(.wb(wbs1)); // ROM 0000H...3FFFH
   wb_ram wb_ram(.wb(wbs2)); // RAM 4000H...4FFFH


   /* I/O 5000H...5FFFH */
   wb_io  wb_io1
     (.wb     (wbs3),
      .io_out (/*open*/),
      .io_in  (16'h0000));

   /* I/O 6000H...6FFFH */
   wb_io  wb_io2
     (.wb     (wbs4),
      .io_out (/*open*/),
      .io_in  (16'h0000));

   /*  I/O 7000H...7FFFH */
   wb_io  wb_io3
     (.wb     (wbs5),
      .io_out (/*open*/),
      .io_in  (16'h0000));

   wb_intercon wb_intercon (.*);

   always #5ns clk = ~clk;

   initial
     begin
	$timeformat(-9, 3, " ns");

        /* load ROM image */
	$readmemh("j1.hex", tb2.wb_rom.rom.mem);

	reset = 1'b1;
	repeat(2) @(negedge clk);
	reset = 1'b0;

	repeat(350) @(negedge clk);
	$finish;
     end
endmodule

`resetall
