/* ROM with Wishbone interface */

`default_nettype none

module wb_rom(if_wb.slave wb);
   wire valid;
   wire rom_cen;

   /* Single port ROM */
   rom4kx16 rom(.clock   (wb.clk),
                .address (wb.adr[11:0]),
                .q       (wb.dat_o),
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
