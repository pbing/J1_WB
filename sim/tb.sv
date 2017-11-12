/* Testbench */

module tb;
   timeunit 1ns;
   timeprecision 1ps;

   bit rst; // reset
   bit clk; // clock

   if_wb wbm1(.*);   // J1 code bus
   if_wb wbs1(.*);   // ROM

   if_wb wbm2(.*);   // J1 data bus
   if_wb wbs2_1(.*); // RAM
   if_wb wbs2_2(.*); // I/O
   if_wb wbs2_3(.*); // I/O
   if_wb wbs2_4(.*); // I/O
   if_wb wbs2_5(.*); // I/O

   j1_wb dut 
     (.sys_clk_i (clk),
      .sys_rst_i (rst),
      .wbc       (wbm1),
      .wbd       (wbm2));

   wb_rom wb_rom(.wb(wbs1));

   wb_ram wb_ram(.wb(wbs2_1));

   wb_io wb_io1(.wb(wbs2_2)); // I/O 4000H...4FFFH
   wb_io wb_io2(.wb(wbs2_3)); // I/O 5000H...5FFFH
   wb_io wb_io3(.wb(wbs2_4)); // I/O 6000H...6FFFH
   wb_io wb_io4(.wb(wbs2_5)); // I/O 7000H...7FFFH

   wb_intercon wb_intercon (.*);

   always #5ns clk = ~clk;

   initial
     begin
	$timeformat(-9, 3, " ns");

        /* load ROM image */
	$readmemh("j1.hex", tb.wb_rom.rom.mem);

        /* initialize RAM */
        for (int i = 0; i < 'h2000; i++)
          tb.wb_ram.ram.mem[i] = $random;

	rst = 1'b1;
	repeat(2) @(negedge clk);
	rst = 1'b0;

	repeat(100) @(negedge clk);
	$finish;
     end
endmodule
