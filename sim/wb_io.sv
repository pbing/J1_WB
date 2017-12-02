/* I/O with Wishbone interface */

`default_nettype none

module wb_io(if_wb.slave wb);
   wire valid;
   wire io_ren;
   wire io_wen;

   wire  [15:0] wb_dat_i;
   logic [15:0] wb_dat_o;

`ifdef SYNTHESIS
   assign wb_dat_i = wb.dat_m;
   assign wb.dat_s = wb_dat_o;
`else
   assign wb_dat_i = wb.dat_i;
   assign wb.dat_o = wb_dat_o;
`endif

   always_ff @(posedge wb.clk)
     if (io_wen)
       $display("%t %M DAT_I = %h", $realtime, wb_dat_i);


   always_ff @(posedge wb.clk)
     if (io_ren)
       begin
          wb_dat_o = $random;
          $display("%t %M DAT_O = %h", $realtime, wb_dat_o);
       end

   assign io_ren = valid & ~wb.we;
   assign io_wen = valid &  wb.we;

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
