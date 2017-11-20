/* Bridge Wishbone to J1 ibus() and dbus() interfaces */

module wb_j1_bridge
  (if_ibus.slave ibus,
   if_dbus.slave dbus,
   if_wb.master  wb);

   /* connect to Wishbone interface with no wait states */
   always_comb
     begin
        wb.adr       = ibus.re ? ibus.adr : dbus.adr;
        wb.stb       = ibus.re | dbus.re | dbus.we;
        wb.cyc       = wb.stb;
        wb.we        = dbus.we;
        wb.m_dat_o   = dbus.s_dat_i;
        ibus.dat     = wb.m_dat_i;
        dbus.s_dat_o = wb.m_dat_i;
     end
endmodule
