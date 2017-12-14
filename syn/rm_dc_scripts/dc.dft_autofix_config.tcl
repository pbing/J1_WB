puts "RM-Info: Running script [info script]\n"

#################################################################################
# Design Compiler DFT Autofix Configuration File Reference
# Script: dc.dft_autofix_config.tcl
# Version: M-2016.12-SP4 (July 17, 2017)
# Copyright (C) 2010-2017 Synopsys, Inc. All rights reserved.
#################################################################################

#################################################################################
# AutoFix Capabilities
# 
#  DFT Compiler can insert logic to fix scan rule violations associated with
#  uncontrollable clocks, uncontrollable asynchronous set signals, and 
#  uncontrollable asynchronous reset signals. These are reported under D1/D2/D3/D9 rules.
#  This capability is referred to as "AutoFix." 
#  By default, this capability is not enabled.
#  
#  The following script enables each of these capabilities, as well
#  as provides a basic specification on which externally controllable 
#  signal to use:
#
# For each capability, you need to specify:
#
# 1. The name of the externally controllable clock/set/reset signal. 
#    If externally controllable clock/set/reset is used, then
#    this signal needs to be already defined as clock/set/reset, respectively.
#
# 2. The name of the TestMode or ScanEnable signal that switches the design between
#    functional mode and test mode. 
#
#    Note: ScanEnable can be used for sets/resets, but not clocks.
#    If you choose to use scan_enable then you must also specify 
#    "set_dft_drc_configuration -allow_se_set_reset".
#
#    Note: This TestMode signal should not be the same as the TestMode signal
#    that switches the design from one test-mode of operation (e.g., internal scan)
#    to another test-mode of operation (e.g., Scan Compression mode)
# 
# You can make further configurations using the "set_autofix_configuration" command.
#################################################################################

# Specify a TestMode signal that switches the design between functional
# mode and test mode. This will be shared among all fixes.
#
set_dft_signal -view spec -type TestMode -port <test_mode_port>



# Enable Clock Fixing
#
set_dft_configuration -fix_clock enable

# Specify the externally controllable "clock" signal.
# This signal should have already been defined with ScanClock.
# Refer to README.DC-RM.txt on using ${DESIGN_NAME}.dft_signal_defs.tcl script
# to define DFT signals in your design
#
set_dft_signal -view spec -type TestData -port <clock_port>


# Enable Set Fixing
set_dft_configuration -fix_set enable


# Specify the externally controllable "set" signal. 
# This signal should have already been defined with type Reset.
# Refer to README.DC-RM.txt on using ${DESIGN_NAME}.dft_signal_defs.tcl script
# to define DFT signals in your design
#
# Note: You can share this to also fix "reset" as long as you do not have gates with
# both uncontrollable sets and resets on the same cell (i.e., No D2 and D3 on the same cell).
#
set_dft_signal -view spec -type TestData -port <set_port>


# Enable Reset Fixing
set_dft_configuration -fix_reset enable

# Specify the externally controllable "reset" signal
# This signal should have already been defined with type Reset.
# This is optional if you are able to use the same signal to fix set and reset. 
# (See note on "Enable Set Fixing" above.)
#
set_dft_signal -view spec -type TestData -port <reset_port>

# Relate the external clock signal to be used to fix uncontrollable clocks above
# with the following command
#
set_autofix_configuration -type clock \
  -test_data <externally_controllable_clock> 
  

# Relate the external "set" or "reset" signal to be used to fix uncontrollable sets 
# or resets above with the following command
#
set_autofix_configuration -type set \
  -test_data <externally_controllable_set> 

set_autofix_configuration -type reset \
  -test_data <externally_controllable_reset> 

# If you want to use a different signal to fix a particular cell, use the
# "set_autofix_element" command. For more information, refer to the
# DFT Compiler User Guide, Chapter 7: Advanced DFT Architecture Methodologies,
# Section: Using AutoFix 


# If you do not have an externally controllable set/reset signal available for AutoFix, you can
# use the "set_autofix_configuration -method gate" option to disable the uncontrollable set/reset signal.
# set_autofix_configuration -type set -method gate

puts "RM-Info: Completed script [info script]\n"
