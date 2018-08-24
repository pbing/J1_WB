/* ROM with Wishbone interface */

`default_nettype none

module wb_rom
  #(parameter size       = 'h2000, // ROM8192x16
    parameter waitcycles = 0)
   (if_wb.slave wb);

   wire                 valid;
   wire                 rom_cen;
   logic [1:waitcycles] stall;   // optimized away when no waitcycles

   /* work around missing modport expressions */
   wire [15:0] wb_dat_o;

`ifdef NO_MODPORT_EXPRESSIONS
   assign wb.dat_s = wb_dat_o;
`else
   assign wb.dat_o = wb_dat_o;
`endif

   rom
     #(.size(size))
   rom
     (.clock   (wb.clk),
      .address (wb.adr[$clog2(size) - 1:0]),
      .q       (wb_dat_o),
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

   always_ff @(posedge wb.clk)
     if (wb.rst)
       stall <= '1;
     else
       if (stall == '0)
         stall <= '1;
       else
         if (valid)
           if (waitcycles < 2)
             stall <= '0;
           else
             stall <= {1'b0, stall[$left(stall):$right(stall) - 1]};

   always_comb
     if (waitcycles == 0)
       wb.stall = 1'b0;
     else
       wb.stall = valid & stall[$right(stall)];
endmodule

`resetall
