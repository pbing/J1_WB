/* Wishbone interface */

interface if_wb
  #(adr_width = 16,                        // address width
    dat_width = 16)                        // data width
   (input wire               rst_i,        // reset
    input wire               clk_i);       // clock

   logic [adr_width - 1 : 0] adr_i, adr_o; // address
   logic [dat_width - 1 : 0] dat_i, dat_o; // data
   logic                     we_i, we_o;   // write enable
   logic                     cyc_i, cyc_o; // cycle
   logic                     stb_i, stb_o; // strobe
   logic                     ack_i, ack_o; // acknowledge

   modport master(input clk_i, input rst_i, output adr_o, input dat_i, output dat_o, output we_o, output cyc_o, output stb_o, input  ack_i);
   modport slave (input clk_i, input rst_i, input  adr_i, input dat_i, output dat_o, input  we_i, input  cyc_i, input  stb_i, output ack_o);
endinterface: if_wb
