/* Interfaces */

/* Classic pipelined bus cycle Wishbone */
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
   logic [dat_width - 1 : 0] dat_i, dat_o;

   modport master
     (input  clk,
      input  rst,
      input  ack,
      output adr,
      output cyc,
      input  stall,
      output stb,
      output we,
      input  dat_i,
      output dat_o);

   modport slave
     (input  clk,
      input  rst,
      output ack,
      input  adr,
      input  cyc,
      output stall,
      input  stb,
      input  we,
      input  dat_i,
      output dat_o);

   modport monitor
     (input  clk,
      input  rst,
      input  ack,
      input  adr,
      input  cyc,
      input  stall,
      input  stb,
      input  we,
      input  dat_i,
      input  dat_o);
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

   modport monitor
     (input  adr,
      input  re,
      input  dat);
endinterface: if_ibus

/* Data bus */
interface if_dbus;
   parameter adr_width = 16;
   parameter dat_width = 16;

   logic [adr_width - 1 : 0] adr;
   logic                     re;
   logic                     we;
   logic [dat_width - 1 : 0] dat_i, dat_o;

   modport master
     (output adr,
      output re,
      output we,
      input  dat_i,
      output dat_o);

   modport slave
     (input  adr,
      input  re,
      input  we,
      input  dat_i,
      output dat_o);

   modport monitor
     (input  adr,
      input  re,
      input  we,
      input  dat_i,
      input  dat_o);
endinterface: if_dbus
