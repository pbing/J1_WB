/* ROM with Wishbone interface */

`default_nettype none

module wb_rom
  #(parameter size = 'h2000) // ROM8192x16
   (if_wb.slave wb);

   wire valid;
   wire rom_cen;

   rom
     #(.size(size))
   rom
     (.clock   (wb.clk),
      .address (wb.adr[$clog2(size) - 1:0]),
      .q       (wb.dat_s),
      .cen     (rom_cen));

   assign rom_cen = valid;

   /* Wishbone control
    * Classic pipelined bus cycles
    */
   assign valid = wb.cyc & wb.stb;

   always_ff @(posedge wb.clk)
     if (wb.rst)
       wb.ack <= 1'b0;
     else
       wb.ack <= valid & ~wb.stall;

   assign wb.stall = 1'b0;
endmodule

`resetall
