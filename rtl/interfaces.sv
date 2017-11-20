/* Interfaces */

/* Classic pipelined bus cycle Wishbone
 *
 * These modport expressions do not work with Design Compiler:
 *
 * modport master (.dat_i(m_dat_i), .dat_o(m_dat_o), ...);
 * modport slave  (.dat_i(s_dat_i), .dat_o(s_dat_o), ...);
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
   logic [dat_width - 1 : 0] m_dat_i, m_dat_o;
   logic [dat_width - 1 : 0] s_dat_i, s_dat_o;

   assign m_dat_i = s_dat_o;
   assign s_dat_i = m_dat_o;

   modport master
     (input  clk,
      input  rst,
      input  ack,
      output adr,
      output cyc,
      input  stall,
      output stb,
      output we,
      input  m_dat_i,
      output m_dat_o);

   modport slave
     (input  clk,
      input  rst,
      output ack,
      input  adr,
      input  cyc,
      output stall,
      input  stb,
      input  we,
      input  s_dat_i,
      output s_dat_o);
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
   logic [dat_width - 1 : 0] m_dat_i, m_dat_o;
   logic [dat_width - 1 : 0] s_dat_i, s_dat_o;

   assign m_dat_i = s_dat_o;
   assign s_dat_i = m_dat_o;

   modport master
     (output adr,
      output re,
      output we,
      input  m_dat_i,
      output m_dat_o);

   modport slave
     (input  adr,
      input  re,
      input  we,
      input  s_dat_i,
      output s_dat_o);
endinterface: if_dbus
