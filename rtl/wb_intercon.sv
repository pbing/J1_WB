/* Wishbone interconnection */

`default_nettype none

module wb_intercon
  (if_wb.slave  wbm1,    // J1 code bus
   if_wb.master wbs1,    // ROM

   if_wb.slave  wbm2,    // J1 data bus
   if_wb.master wbs2_1,  // RAM
   if_wb.master wbs2_2,  // I/O
   if_wb.master wbs2_3,  // I/O
   if_wb.master wbs2_4,  // I/O
   if_wb.master wbs2_5); // I/O

   wire sel2_1 = wbm2.adr[15:14] == 2'b00;   // RAM
   wire sel2_2 = wbm2.adr[15:13] == 2'b0100; // I/O 4000H...4FFFH
   wire sel2_3 = wbm2.adr[15:13] == 2'b0101; // I/O 5000H...5FFFH
   wire sel2_4 = wbm2.adr[15:13] == 2'b0110; // I/O 6000H...6FFFH
   wire sel2_5 = wbm2.adr[15:13] == 2'b0111; // I/O 7000H...7FFFH

   assign wbm1.ack     = wbs1.ack;
   assign wbs1.adr     = wbm1.adr;
   assign wbs1.cyc     = wbm1.cyc;
   assign wbm1.stall   = wbs1.stall;
   assign wbs1.stb     = wbm1.stb;
   assign wbs1.we      = wbm1.we;
   assign wbs1.dat_i   = wbm1.dat_o;
   assign wbm1.dat_i   = wbs1.dat_o;

   assign wbs2_1.adr   = wbm2.adr;
   assign wbs2_1.cyc   = wbm2.cyc & sel2_1;
   assign wbs2_1.stb   = wbm2.stb & sel2_1;
   assign wbs2_1.we    = wbm2.we;
   assign wbs2_1.dat_i = wbm2.dat_o;

   assign wbs2_2.adr   = wbm2.adr;
   assign wbs2_2.cyc   = wbm2.cyc & sel2_2;
   assign wbs2_2.stb   = wbm2.stb & sel2_2;
   assign wbs2_2.we    = wbm2.we;
   assign wbs2_2.dat_i = wbm2.dat_o;

   assign wbs2_3.adr   = wbm2.adr;
   assign wbs2_3.cyc   = wbm2.cyc & sel2_3;
   assign wbs2_3.stb   = wbm2.stb & sel2_3;
   assign wbs2_3.we    = wbm2.we;
   assign wbs2_3.dat_i = wbm2.dat_o;

   assign wbs2_4.adr   = wbm2.adr;
   assign wbs2_4.cyc   = wbm2.cyc & sel2_4;
   assign wbs2_4.stb   = wbm2.stb & sel2_4;
   assign wbs2_4.we    = wbm2.we;
   assign wbs2_4.dat_i = wbm2.dat_o;

   assign wbs2_5.adr   = wbm2.adr;
   assign wbs2_5.cyc   = wbm2.cyc & sel2_5;
   assign wbs2_5.stb   = wbm2.stb & sel2_5;
   assign wbs2_5.we    = wbm2.we;
   assign wbs2_5.dat_i = wbm2.dat_o;

   assign wbm2.ack   = (wbs2_1.ack & sel2_1) |
                       (wbs2_2.ack & sel2_2) |
                       (wbs2_3.ack & sel2_3) |
                       (wbs2_4.ack & sel2_4) |
                       (wbs2_5.ack & sel2_5);

   assign wbm2.stall = (wbs2_1.stall & sel2_1) |
                       (wbs2_2.stall & sel2_2) |
                       (wbs2_3.stall & sel2_3) |
                       (wbs2_4.stall & sel2_4) |
                       (wbs2_5.stall & sel2_5);

   assign wbm2.dat_i = (wbs2_1.dat_i & {16, {sel2_1}}) |
                       (wbs2_2.dat_i & {16, {sel2_2}}) |
                       (wbs2_3.dat_i & {16, {sel2_3}}) |
                       (wbs2_4.dat_i & {16, {sel2_4}}) |
                       (wbs2_5.dat_i & {16, {sel2_5}});
endmodule

`resetall
