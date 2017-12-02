/* Bridge Wishbone to J1 ibus() and dbus() interfaces */

module wb_j1_bridge
  (if_ibus.slave ibus,
   if_dbus.slave dbus,
   if_wb.master  wb);

   wire  [15:0] dbus_dat_i, wb_dat_i;
   logic [15:0] dbus_dat_o, wb_dat_o;

`ifdef SYNTHESIS
   assign dbus_dat_i = dbus.dat_m;
   assign dbus.dat_s = dbus_dat_o;
   assign wb_dat_i   = wb.dat_m;
   assign wb.dat_s   = wb_dat_o;
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
        wb.cyc     = wb.stb;
        wb.we      = dbus.we;
        wb_dat_o   = dbus_dat_i;
        ibus.dat   = wb_dat_i;
        dbus_dat_o = wb_dat_i;
     end
endmodule
