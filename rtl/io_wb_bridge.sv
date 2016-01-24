/* I/O / Wishbone bridge */

module io_wb_bridge
  (if_wb.master       wb,        // Wishbone master interface
   output wire        sys_clk_i, // main clock
   output wire        sys_rst_i, // reset
   output wire [15:0] io_din,    // io data in
   input  wire        io_rd,     // io read
   input  wire        io_wr,     // io write
   input  wire [15:0] io_addr,   // io address
   input  wire [15:0] io_dout,   // io data out
   output wire        io_wait);  // io wait state

   wire io_access   = io_rd | io_wr;

   assign sys_clk_i = wb.clk_i;
   assign sys_rst_i = wb.rst_i;
   assign io_din    = wb.dat_i;
   assign wb.adr_o  = io_addr;
   assign wb.dat_o  = io_dout;
   assign wb.we_o   = io_wr;
   assign wb.cyc_o  = io_access;
   assign wb.stb_o  = io_access;
   assign io_wait   = io_access & ~wb.ack_i;
endmodule
