/* Wishbone slave */

//`define WB_SLAVE_ASYNCHRONOUS
`define WB_SLAVE_SYNCHRONOUS


module wb_slave(if_wb.slave wb);

`ifdef WB_SLAVE_ASYNCHRONOUS

   /* data */
   always @*
     if (wb.cyc_i && wb.stb_i && !wb.we_i)
       wb.dat_o = $random;
     else
       wb.dat_o = 16'h0;

   /* control */
   assign wb.ack_o = wb.cyc_i & wb.stb_i;
`endif



`ifdef WB_SLAVE_SYNCHRONOUS

   /* data */
   always @(posedge wb.clk_i)
     if (wb.cyc_i && wb.stb_i && !wb.we_i)
       wb.dat_o <= $random;
     else
       wb.dat_o <= 16'h0;

   /* control */
   always @(posedge wb.clk_i)
     if (wb.rst_i)
       wb.ack_o <= 1'b0;
     else
       if (wb.cyc_i && wb.stb_i)
	 begin
	    wb.ack_o <= 1'b1;
	    @(posedge wb.clk_i);
	    wb.ack_o <= 1'b0;
	 end
`endif

   /* check access */
   always @(posedge wb.clk_i)
     if (wb.cyc_i && wb.stb_i && wb.we_i)
       write_access:
	 assert ((wb.adr_i == 'h4000 && wb.dat_i == 'h0123) ||
		 (wb.adr_i == 'h4002 && wb.dat_i == 'h1234) ||
		 (wb.adr_i == 'h4004 && wb.dat_i == 'h2345) ||
		 (wb.adr_i == 'h4006 && wb.dat_i == 'h3456))
	   else $error("adr_i = 'h%h dat_i = 'h%h", wb.adr_i, wb.dat_i);

   /* monitor read access */
   always @(posedge wb.clk_i)
     if (wb.cyc_i && wb.stb_i && !wb.we_i && wb.ack_o)
       $display("%t %M adr_i = 'h%h dat_o = 'h%h", $realtime, wb.adr_i, wb.dat_o);
endmodule
