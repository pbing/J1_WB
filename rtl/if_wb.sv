/* Classic pipelined bus cycle Wishbone interface */

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

   modport master(input  clk,
                  input  rst,
                  input  ack,
                  output adr,
                  output cyc,
                  input  stall,
                  output stb,
                  output we,
                  input  dat_i,
                  output dat_o);

   modport slave(input  clk,
                 input  rst,
                 output ack,
                 input  adr,
                 input  cyc,
                 output stall,
                 input  stb,
                 input  we,
                 input  dat_i,
                 output dat_o);

   modport monitor(input  clk,
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
