/* RAM with Wishbone interface */

`default_nettype none

module wb_ram
  #(parameter size       = 'h800, // RAM2048x16
    parameter waitcycles = 0)
   (if_wb.slave wb);

   wire                 valid;
   wire                 ram_cen;
   wire                 ram_wen;

   /* work around missing modport expressions */
   wire [15:0] wb_dat_i, wb_dat_o;

`ifdef NO_MODPORT_EXPRESSIONS
   assign wb_dat_i = wb.dat_m;
   assign wb.dat_s = wb_dat_o;
`else
   assign wb_dat_i = wb.dat_i;
   assign wb.dat_o = wb_dat_o;
`endif

   spram
     #(.size(size))
   ram
     (.clock   (wb.clk),
      .address (wb.adr[$clog2(size) - 1:0]),
      .data    (wb_dat_i),
      .q       (wb_dat_o),
      .cen     (ram_cen),
      .wren    (ram_wen));

   assign ram_cen = valid;
   assign ram_wen = ram_cen & wb.we;

   /* Wishbone control
    * Classic pipelined bus cycles
    */
   assign valid = wb.cyc & wb.stb;

   always_ff @(posedge wb.clk)
     if (wb.rst)
       wb.ack <= 1'b0;
     else
       wb.ack <= valid & ~wb.stall;

   generate
      case (waitcycles)
        0:
          begin:w0
             assign wb.stall = 1'b0;
          end:w0

        1:
          begin:w1
             logic stall;

             always_ff @(posedge wb.clk)
               if (wb.rst)
                 stall <= 1'b1;
               else
                 if (stall == 1'b0)
                   stall <= 1'b1;
                 else
                   if (valid)
                     stall <= 1'b0;

             assign wb.stall = valid & stall;
          end:w1

        default
          begin:wn
             logic [1:waitcycles] stall;

             always_ff @(posedge wb.clk)
               if (wb.rst)
                 stall <= '1;
               else
                 if (stall == '0)
                   stall <= '1;
                 else
                   if (valid)
                     stall <= {1'b0, stall[$left(stall):$right(stall) - 1]};

             assign wb.stall = valid & stall[$right(stall)];
          end:wn
      endcase
   endgenerate
endmodule

`resetall
