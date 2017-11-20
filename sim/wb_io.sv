/* I/O with Wishbone interface */

`default_nettype none

module wb_io(if_wb.slave wb);
   wire valid;
   wire io_ren;
   wire io_wen;

   always_ff @(posedge wb.clk)
     if (io_wen)
       $display("%t %M DAT_I = %h", $realtime, wb.dat_m);


   always_ff @(posedge wb.clk)
     if (io_ren)
       begin
          logic [15:0] dat_o;

          dat_o = $random;
          $display("%t %M DAT_O = %h", $realtime, dat_o);
          wb.dat_s <= dat_o;
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
