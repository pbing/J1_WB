/* Wishbone interconnection */

`default_nettype none

module wb_intercon
  (if_wb.slave  wbm1,    // J1 code bus
   if_wb.master wbs1,    // ROM

   if_wb.slave  wbm2,    // J1 data bus
   if_wb.master wbs2_1,  // RAM
   if_wb.master wbs2_2); // I/O

   assign wbm1.ack   = wbs1.ack;
   assign wbs1.adr   = wbm1.adr;
   assign wbs1.cyc   = wbm1.cyc;
   assign wbm1.stall = wbs1.stall;
   assign wbs1.stb   = wbm1.stb;
   assign wbs1.we    = wbm1.we;
   assign wbs1.dat_i = wbm1.dat_o;
   assign wbm1.dat_i = wbs1.dat_o;

   assign wbm2.ack     = wbs2_1.ack;
   assign wbs2_1.adr   = wbm2.adr;
   assign wbs2_1.cyc   = wbm2.cyc;
   assign wbm2.stall   = wbs2_1.stall;
   assign wbs2_1.stb   = wbm2.stb;
   assign wbs2_1.we    = wbm2.we;
   assign wbs2_1.dat_i = wbm2.dat_o;
   assign wbm2.dat_i   = wbs2_1.dat_o;

/* FIXME */
//   assign wbm2.ack     = wbs2_2.ack;
   assign wbs2_2.adr   = wbm2.adr;
   assign wbs2_2.cyc   = wbm2.cyc;
//   assign wbm2.stall   = wbs2_2.stall;
   assign wbs2_2.stb   = wbm2.stb;
   assign wbs2_2.we    = wbm2.we;
   assign wbs2_2.dat_i = wbm2.dat_o;
//   assign wbm2.dat_i   = wbs2_2.dat_o;
endmodule

`resetall
