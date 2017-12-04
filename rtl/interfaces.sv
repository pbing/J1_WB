/* Interfaces */

/* Classic pipelined bus cycle Wishbone
 *
 * These modport expressions do not work with Design Compiler:
 *
 * modport master (.dat_i(dat_s), .dat_o(dat_m), ...);
 * modport slave  (.dat_i(dat_m), .dat_o(dat_s), ...);
 */

interface if_wb
  (input wire rst,
   input wire clk);

   parameter adr_width = 16;
   parameter dat_width = 16;

   logic                     ack;
   logic [adr_width - 1 : 0] adr;
   logic                     cyc;
   logic                     stall;
   logic                     stb;
   logic                     we;
   logic [dat_width - 1 : 0] dat_m; // channel from master
   logic [dat_width - 1 : 0] dat_s; // channel from slave

   modport master
     (input  clk,
      input  rst,
      input  ack,
      output adr,
      output cyc,
      input  stall,
      output stb,
      output we,
`ifdef NO_MODPORT_EXPRESSIONS
      input  dat_s,
      output dat_m
`else
      input  .dat_i(dat_s),
      output .dat_o(dat_m)
`endif
      );

   modport slave
     (input  clk,
      input  rst,
      output ack,
      input  adr,
      input  cyc,
      output stall,
      input  stb,
      input  we,
`ifdef NO_MODPORT_EXPRESSIONS
      input  dat_m,
      output dat_s
`else
      input  .dat_i(dat_m),
      output .dat_o(dat_s)
`endif
      );
endinterface: if_wb

/* Instruction bus */
interface if_ibus;
   parameter adr_width = 16;
   parameter dat_width = 16;

   logic [adr_width - 1 : 0] adr;
   logic                     re;
   logic [dat_width - 1 : 0] dat;

   modport master
     (output adr,
      output re,
      input  dat);

   modport slave
     (input  adr,
      input  re,
      output dat);
endinterface: if_ibus

/* Data bus */
interface if_dbus;
   parameter adr_width = 16;
   parameter dat_width = 16;

   logic [adr_width - 1 : 0] adr;
   logic                     re;
   logic                     we;
   logic [dat_width - 1 : 0] dat_m; // channel from master
   logic [dat_width - 1 : 0] dat_s; // channel from slave

   modport master
     (output adr,
      output re,
      output we,
`ifdef NO_MODPORT_EXPRESSIONS
      input  dat_s,
      output dat_m
`else
      input  .dat_i(dat_s),
      output .dat_o(dat_m)
`endif
      );

   modport slave
     (input  adr,
      input  re,
      input  we,
`ifdef NO_MODPORT_EXPRESSIONS
      input  dat_m,
      output dat_s
`else
      input  .dat_i(dat_m),
      output .dat_o(dat_s)
`endif
      );
endinterface: if_dbus
