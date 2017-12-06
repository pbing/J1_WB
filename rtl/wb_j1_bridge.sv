/* Bridge Wishbone to J1 ibus() and dbus() interfaces */

module wb_j1_bridge
  (if_ibus.slave ibus,
   if_dbus.slave dbus,
   if_wb.master  wb);

   wire  [15:0] dbus_dat_i, wb_dat_i;
   logic [15:0] dbus_dat_o, wb_dat_o;
   logic        wb_stb_r;

`ifdef NO_MODPORT_EXPRESSIONS
   assign dbus_dat_i = dbus.dat_m;
   assign dbus.dat_s = dbus_dat_o;
   assign wb_dat_i   = wb.dat_s;
   assign wb.dat_m   = wb_dat_o;
`else
   assign dbus_dat_i = dbus.dat_i;
   assign dbus.dat_o = dbus_dat_o;
   assign wb_dat_i   = wb.dat_i;
   assign wb.dat_o   = wb_dat_o;
`endif

   /* connect to Wishbone interface with no wait states */
   always_comb
     begin
        wb.adr     = ibus.re ? ibus.adr : dbus.adr;
        wb.stb     = ibus.re | dbus.re | dbus.we;
        wb.cyc     = wb.stb | wb_stb_r;
        wb.we      = dbus.we;
        wb_dat_o   = dbus_dat_i;
        ibus.dat   = wb_dat_i;
        dbus_dat_o = wb_dat_i;
     end

   always_ff @(wb.clk)
     if (wb.rst)
       wb_stb_r <= 1'b0;
     else
       wb_stb_r <= wb.stb;
endmodule
