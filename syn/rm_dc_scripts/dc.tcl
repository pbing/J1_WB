source -echo -verbose ./rm_setup/dc_setup.tcl
set DFT_COMPILE false

#################################################################################
# Design Compiler Reference Methodology Script for Top-Down Flow
# Script: dc.tcl
# Version: M-2016.12-SP4 (July 17, 2017)
# Copyright (C) 2007-2016 Synopsys, Inc. All rights reserved.
#################################################################################

#################################################################################
# Additional Variables
#
# Add any additional variables needed for your flow here.
#################################################################################


################################################################################
# You can enable inference of multibit registers from the buses defined in the RTL.
# The replacement of single-bit cells with multibit library cells occurs during execution 
# of the compile_ultra command. This variable has to be set before reading the RTL
#
# set_app_var hdlin_infer_multibit default_all
#################################################################################

if { $OPTIMIZATION_FLOW == "hplp"} {
 set_app_var hdlin_infer_multibit default_all
}

# No additional flow variables are being recommended

if {[file exists [which ${LIBRARY_DONT_USE_PRE_COMPILE_LIST}]]} {
  puts "RM-Info: Sourcing script file [which ${LIBRARY_DONT_USE_PRE_COMPILE_LIST}]\n"
  source -echo -verbose $LIBRARY_DONT_USE_PRE_COMPILE_LIST
}

#################################################################################
# Setup for Formality Verification
#################################################################################

# In the event of an inconclusive (or hard) verification, we recommend using
# the set_verification_priority commands provided from the analyze_points command
# in Formality. The set_verification_priority commands target specific
# operators to reduce verification complexity while minimizing QoR impact.
# The set_verification_priority commands should be applied after the design
# is read and elaborated.

# For designs that don't have tight QoR constraints and don't have register retiming,
# you can use the following variable to enable the highest productivity single pass flow.
# This flow modifies the optimizations to make verification easier.
# This variable setting should be applied prior to reading in the RTL for the design.

# set_app_var simplified_verification_mode true

# For more information about facilitating formal verification in the flow, refer
# to the following SolvNet article:
# "Resolving Inconclusive and Hard Verifications in Design Compiler"
# https://solvnet.synopsys.com/retrieve/033140.html

# Define the verification setup file for Formality
set_svf ${RESULTS_DIR}/${DCRM_SVF_OUTPUT_FILE}

#################################################################################
# Setup SAIF Name Mapping Database
#
# Include an RTL SAIF for better power optimization and analysis.
#
# saif_map should be issued prior to RTL elaboration to create a name mapping
# database for better annotation.
################################################################################

# saif_map -start

#################################################################################
# Read in the RTL Design
#
# Read in the RTL source files or read in the elaborated design (.ddc).
#################################################################################

puts "RM-Info: Sourcing script file [which ${DCRM_RTL_READ_SCRIPT}]\n"
source -echo -verbose ${DCRM_RTL_READ_SCRIPT}

# OR

# You can read an elaborated design from the same release.
# Using an elaborated design from an older release will not give the best results.

# read_ddc ${DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE}
current_design ${DESIGN_NAME}
link

write -hierarchy -format ddc -output ${RESULTS_DIR}/${DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE}

#################################################################################
# sets the multibit_mode attribute
#################################################################################
if { $OPTIMIZATION_FLOW == "hplp"} {
  # Enable mapping to multibit only if the timing is not degraded.
  set_multibit_options -mode timing_driven
}

#################################################################################
# Reports pre-synthesis congestion analysis.
#################################################################################
if { $OPTIMIZATION_FLOW == "hc"} {
  #Analyze the RTL constructs which may lead to congestion
  analyze_rtl_congestion > ${REPORTS_DIR}/${DCRM_ANALYZE_RTL_CONGESTION_REPORT_FILE}
}

#################################################################################
# Apply Logical Design Constraints
#################################################################################

# You can use either SDC file ${DCRM_SDC_INPUT_FILE} or Tcl file 
# ${DCRM_CONSTRAINTS_INPUT_FILE} to constrain your design.
if {[file exists [which ${DCRM_SDC_INPUT_FILE}]]} {
  puts "RM-Info: Reading SDC file [which ${DCRM_SDC_INPUT_FILE}]\n"
  read_sdc ${DCRM_SDC_INPUT_FILE}
}
if {[file exists [which ${DCRM_CONSTRAINTS_INPUT_FILE}]]} {
  puts "RM-Info: Sourcing script file [which ${DCRM_CONSTRAINTS_INPUT_FILE}]\n"
  source -echo -verbose ${DCRM_CONSTRAINTS_INPUT_FILE}
}

if {![shell_is_in_topographical_mode]} {
    set_wire_load_selection WireAreaLowkCon
}

# You can enable analysis and optimization for multiple clocks per register.
# To use this, you must constrain to remove false interactions between mutually exclusive
# clocks.  This is needed to prevent unnecessary analysis that can result in
# a significant runtime increase with this feature enabled.
#
# set_clock_groups -physically_exclusive | -logically_exclusive | -asynchronous \
#                  -group {CLKA, CLKB} -group {CLKC, CLKD} 
#
# set_app_var timing_enable_multiple_clocks_per_reg true

#################################################################################
# Apply The Operating Conditions
#################################################################################

# Set operating condition on top level

# set_operating_conditions -max <max_opcond> -min <min_opcond>

#################################################################################
# Create Default Path Groups
#
# Separating these paths can help improve optimization.
# Remove these path group settings if user path groups have already been defined.
#################################################################################

set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
group_path -name REGOUT -to [all_outputs] 
group_path -name REGIN -from [remove_from_collection [all_inputs] ${ports_clock_root}] 
group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]

#################################################################################
# Power Optimization Section
#################################################################################

    #############################################################################
    # Clock Gating Setup
    #############################################################################

    # If your design has instantiated clock gates, you should use identify_clock_gating
    # command to identify and the report_clock_gating -multi_stage to report them.

    # identify_clock_gating
    # report_clock_gating -multi_stage -nosplit > ${REPORTS_DIR}/${DCRM_INSTANTIATE_CLOCK_GATES_REPORT}

    # If you do not want clock-gating to optimize your user instantiated
    # clock-gating cells, you should set the pwr_preserve_cg attribute upon
    # those clock-gating cells.

    # set_preserve_clock_gate [get_cell <user_clock_gating_cells>]

    # Default clock_gating_style suits most designs.  Change only if necessary.
    # set_clock_gating_style -positive_edge_logic {integrated} -negative_edge_logic {integrated} -control_point before ...   

    # Clock gate insertion is now performed during compile_ultra -gate_clock
    # so insert_clock_gating is no longer recommended at this step.

    # The following setting can be used to enable global clock gating.
    # With global clock gating, common enables are extracted across hierarchies
    # which results in fewer redundant clock gates. 

    # set compile_clock_gating_through_hierarchy true 

    # For better timing optimization of enable logic, clock latency for 
    # clock gating cells can be optionally specified.

    # set_clock_gate_latency -clock <clock_name> -stage <stage_num> \
    #         -fanout_latency {fanout_range1 latency_val1 fanout_range2 latency_val2 ...}

    # You can use "set_self_gating_options" command to specify self-gating 
    # options when -self_gating option is used in addition to -gate_clock 
    # option at the compile_ultra command. To inserts self-gate on clock-gated
    # registers, uncomment the following line:
    # set_self_gating_options -interaction_with_clock_gating insert

    #############################################################################
    # Apply Power Optimization Constraints
    #############################################################################

    # Include a SAIF file, if possible, for power optimization.  If a SAIF file
    # is not provided, the default toggle rate of 0.1 will be used for propagating
    # switching activity.

    # read_saif -auto_map_names -input ${DESIGN_NAME}.saif -instance < DESIGN_INSTANCE > -verbose

    if {[shell_is_in_topographical_mode]} {
      # For multi-Vth design, replace the following to set the threshold voltage groups in the libraries.

      # set_attribute <my_hvt_lib> default_threshold_voltage_group HVT -type string
      # set_attribute <my_lvt_lib> default_threshold_voltage_group LVT -type string
    }

    # Starting in J-2014.09, leakage optimization is the default flow and is always enabled.

    if {[shell_is_in_topographical_mode]} {
      # Use the following command to enable power prediction using clock tree estimation.

      # set_power_prediction true -ct_references <LIB CELL LIST>
    }

if {[shell_is_in_topographical_mode]} {

  ##################################################################################
  # Apply Physical Design Constraints
  #
  # Optional: Floorplan information can be read in here if available.
  # This is highly recommended for irregular floorplans.
  #
  # Floorplan constraints can be provided from one of the following sources:
  # * extract_physical_constraints with a DEF file
  #	* read_floorplan with a floorplan file (written by write_floorplan)
  #	* User generated Tcl physical constraints
  #
  ##################################################################################

  # Specify ignored layers for routing to improve correlation
  # Use the same ignored layers that will be used during place and route

  if { ${MIN_ROUTING_LAYER} != ""} {
    set_ignored_layers -min_routing_layer ${MIN_ROUTING_LAYER}
  }
  if { ${MAX_ROUTING_LAYER} != ""} {
    set_ignored_layers -max_routing_layer ${MAX_ROUTING_LAYER}
  }

  report_ignored_layers

  # If the macro names change after mapping and writing out the design due to
  # ungrouping or Verilog change_names renaming, it may be necessary to translate 
  # the names to correspond to the cell names that exist before compile.

  # During DEF constraint extraction, extract_physical_constraints automatically
  # matches DEF names back to precompile names in memory using standard matching rules.
  # read_floorplan will also automatically perform this name matching.

  # Modify set_query_rules if other characters are used for hierarchy separators
  # or bus names. 

  # set_query_rules  -hierarchical_separators {/ _ .} \
  #                  -bus_name_notations {[] __ ()}   \
  #                  -class {cell pin port net}       \
  #                  -wildcard                        \
  #                  -regsub_cumulative               \
  #                  -show

  ## For DEF floorplan input

  # The DEF file for Design Compiler Topographical can be written from IC Compiler using the following 
  # recommended options:
  # icc_shell> write_def -version 5.7 -rows_tracks_gcells -fixed -pins -blockages -specialnets \
  #                      -vias -regions_groups -verbose -output ${DCRM_DCT_DEF_INPUT_FILE}

  if {[file exists [which ${DCRM_DCT_DEF_INPUT_FILE}]]} {
    # If you have physical only cells as a part of your floorplan DEF file, you can use
    # the -allow_physical_cells option with extract_physical_constraints to include
    # the physical only cells as a part of the floorplan in Design Compiler to improve correlation.
    #
    # Note: With -allow_physical_cells, new logical cells in the DEF file
    #       that have a fixed location will also be added to the design in memory.
    #       See the extract_physical_constraints manpage for more information about
    #       identifying the cells added to the design when using -allow_physical_cells.
  
    # extract_physical_constraints -allow_physical_cells ${DCRM_DCT_DEF_INPUT_FILE}

    puts "RM-Info: Reading in DEF file [which ${DCRM_DCT_DEF_INPUT_FILE}]\n"
    extract_physical_constraints ${DCRM_DCT_DEF_INPUT_FILE}
    if { $OPTIMIZATION_FLOW == "hplp"} {
	extract_physical_constraints -allow_physical_cells ${DCRM_DCT_DEF_INPUT_FILE}  
    }
  }
  
  # OR

  ## For floorplan file input

  # The floorplan file for Design Compiler Topographical can be written from IC Compiler using the following 
  # recommended options:
  # Note: IC Compiler requires the use of -placement {terminal} with -create_terminal beginning in the
  #       D-2010.03-SP1 release.
  # icc_shell> write_floorplan -placement {io terminal hard_macro soft_macro} -create_terminal \
  #                            -row -create_bound -preroute -track ${DCRM_DCT_FLOORPLAN_INPUT_FILE}

  # Read in the secondary floorplan file, previously written by write_floorplan in Design Compiler,
  # to restore physical-only objects back to the design, before reading the main floorplan file.

  if {[file exists [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}.objects]]} {
    puts "RM-Info: Reading in secondary floorplan file [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}.objects]\n"
    read_floorplan ${DCRM_DCT_FLOORPLAN_INPUT_FILE}.objects
  }

  if {[file exists [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}]]} {
    puts "RM-Info: Reading in floorplan file [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}]\n"
    read_floorplan ${DCRM_DCT_FLOORPLAN_INPUT_FILE}
  }

  # OR

  ## For Tcl file input

  # For Tcl constraints, the name matching feature must be explicitly enabled
  # and will also use the set_query_rules setttings. This should be turned off
  # after the constraint read in order to minimize runtime.

  if {[file exists [which ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}]]} {
    set_app_var enable_rule_based_query true
    puts "RM-Info: Sourcing script file [which ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}]\n"
    source -echo -verbose ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}
    set_app_var enable_rule_based_query false 
  }


  # Use write_floorplan to save the applied floorplan.

  # Note: A secondary floorplan file ${DCRM_DCT_FLOORPLAN_OUTPUT_FILE}.objects
  #       might also be written to capture physical-only objects in the design.
  #       This file should be read in before reading the main floorplan file.

  write_floorplan -all ${RESULTS_DIR}/${DCRM_DCT_FLOORPLAN_OUTPUT_FILE}

  # Verify that all the desired physical constraints have been applied
  # Add the -pre_route option to include pre-routes in the report
  report_physical_constraints > ${REPORTS_DIR}/${DCRM_DCT_PHYSICAL_CONSTRAINTS_REPORT}
}

#################################################################################
# Apply Additional Optimization Constraints
#################################################################################

# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants

#################################################################################
# Save the compile environment snapshot for the Consistency Checker utility.
#
# This utility checks for inconsistent settings between Design Compiler and
# IC Compiler which can contribute to correlation mismatches.
#
# Download this utility from SolvNet.  See the following SolvNet article for
# complete details:
#
# https://solvnet.synopsys.com/retrieve/026366.html
#
# The article is titled: "Using the Consistency Checker to Automatically Compare
# Environment Settings Between Design Compiler and IC Compiler"
#################################################################################

# Uncomment the following to snapshot the environment for the Consistency Checker

# write_environment -consistency -output ${REPORTS_DIR}/${DCRM_CONSISTENCY_CHECK_ENV_FILE}

#################################################################################
# Check for Design Problems 
#################################################################################

# Check the current design for consistency
check_design -summary
check_design > ${REPORTS_DIR}/${DCRM_CHECK_DESIGN_REPORT}

# The analyze_datapath_extraction command can help you to analyze why certain data 
# paths are no extracted, uncomment the following line to report analyisis.

# analyze_datapath_extraction > ${REPORTS_DIR}/${DCRM_ANALYZE_DATAPATH_EXTRACTION_REPORT}


#################################################################################
# Multibit Register Reports pre-compile_ultra
#################################################################################

#################################################################################
# Uncomment the next line to verify that the desired bussed registers are grouped as multibit components 
# These multibit components are mapped to multibit registers during compile_ultra
#
redirect ${REPORTS_DIR}/${DCRM_MULTIBIT_COMPONENTS_REPORT} {report_multibit -hierarchical }
#################################################################################


#################################################################################
# Compile the Design
#
# Recommended Options:
#
#     -scan
#     -gate_clock (-self_gating)
#     -retime
#     -spg
#
# Use compile_ultra as your starting point. For test-ready compile, include
# the -scan option with the first compile and any subsequent compiles.
#
# Use -gate_clock to insert clock-gating logic during optimization.  This
# is now the recommended methodology for clock gating.
#
# Use -self_gating option in addition to -gate_clock for potentially saving 
# additional dynamic power, in topographical mode only. Registers that are 
# not clock gated will be considered for XOR self gating.
# XOR self gating should be performed along with clock gating, using -gate_clock
# and -self_gating options. XOR self gates will be inserted only if there is 
# potential power saving without degrading the timing.
# An accurate switching activity annotation either by reading in a saif 
# file or through set_switching_activity command is recommended.
# You can use "set_self_gating_options" command to specify self-gating 
# options.
#
# Use -retime to enable adaptive retiming optimization for further timing benefit.
#
# Use the -spg option to enable Design Compiler Graphical physical guidance flow.
# The physical guidance flow improves QoR, area and timing correlation, and congestion.
# It also improves place_opt runtime in IC Compiler.
#
# Note: In addition to -spg option you can enable the support of via resistance for 
#       RC estimation to improve the timing correlation with IC Compiler by using the 
#       following setting:
#
#       set_app_var spg_enable_via_resistance_support true
#
# You can selectively enable or disable the congestion optimization on parts of 
# the design by using the set_congestion_optimization command.
# This option requires a license for Design Compiler Graphical.
#
# The constant propagation is enabled when boundary optimization is disabled. In 
# order to stop constant propagation you can do the following
#
# set_compile_directives -constant_propagation false <object_list>
#
# Note: Layer optimization is on by default in Design Compiler Graphical, to 
#       improve the the accuracy of certain net delay during optimization.
#       To disable the the automatic layer optimization you can use the 
#       -no_auto_layer_optimization option.
#
#################################################################################
## RM+ Variable and Command Settings before first compile_ultra
#################################################################################
if { $OPTIMIZATION_FLOW == "hplp"} {
    if {[shell_is_in_topographical_mode]} {

	# The following variable, when set to true, runs additional optimizations to improve the timing of  
	# the design at the cost of additional run time.
	set_app_var compile_timing_high_effort true

	# The following variable enables a mode of coarse placement in which cells are not distributed  
	# evenly  across the surface but are allowed to clump together for better QoR     
	set_app_var placer_max_cell_density_threshold 0.75        

	# The following variable, when set to true, enables very high effort optimization to fix total negative slack 
	# Setting following variable to true may affect run time
	set_app_var psynopt_tns_high_effort true

	# Use the following variable to enable the physically aware clock gating 
	set_app_var power_cg_physically_aware_cg true
	
	#The following variable helps to reduce the total negative slack of the design
	set_app_var placer_tns_driven true

	# Enable low power placement.  
	# Low power placement affects the placement of cells, pulls them closer together, 
	# on nets with high switching activity to reduce the overall dynamic power of your design.  
        set_app_var power_low_power_placement true

        # In MCMM flow use set_scenario_options -dynamic_power true 
	set_dynamic_optimization true
	
	# The following variable enables register replication across the hierarchy by creating new ports
	# on the instances of the subdesigns if it is necessary to improve the timing of the design
	set_app_var compile_register_replication_across_hierarchy true 
    }
}
if { $OPTIMIZATION_FLOW == "hc"} {
   if {[shell_is_in_topographical_mode]} {

       # This command enables congestion aware Global buffering based on Zroutebased estimation,
       # reducing congestion along narrow channels across macros. Enabling this feature may have 
       # runtime and QOR impact. Enable this variable on macro intensive designs with narrow channels.
       # set_ahfs_options -global_route true


       # With the following variables set, Zroute-based congestion-driven placement is enabled
       # instead of virtual route based estimation. 
       # Enabling this feature may have runtime impact. Enable this for highly congested designs
       # set_app_var placer_congestion_effort medium
       # set_app_var placer_enable_enhanced_router true

       # Enabling the variable can lead to lower congestion for designs that have congestion due to
       # multiplexing logic in the RTL. This variable is supported only in the initial compile step,
       # Not supported in incremental compile.
       set_app_var compile_prefer_mux true
   }
}
if { $OPTIMIZATION_FLOW == "rtm_exp"} {
  if {[shell_is_in_topographical_mode]} {
  
      set_host_options -max_cores 8
      # The following command overrides runtime-intensive user settings with settings designed
      # to improve runtime. Since the run time intensive optimizations are turned off it might 
      # impact QoR. You can use this as an exploration flow when run time is a concern.
      compile_prefer_runtime
  }
}
if {[shell_is_in_topographical_mode]} {
  # Use the "-check_only" option of "compile_ultra" to verify that your
  # libraries and design are complete and that optimization will not fail
  # in topographical mode.  Use the same options as will be used in compile_ultra.

  # compile_ultra -scan -gate_clock -check_only
}

compile_ultra -scan -gate_clock

#################################################################################
# Save Design after First Compile
#################################################################################

write -format ddc -hierarchy -output ${RESULTS_DIR}/${DCRM_COMPILE_ULTRA_DDC_OUTPUT_FILE}

if {$OPTIMIZATION_FLOW != "rtm_exp"} {


################################################################################
## RM+ Variable and Command Settings before incremental compile
################################################################################
if { $OPTIMIZATION_FLOW == "hplp" } {
    if {[shell_is_in_topographical_mode]} {
	# You can use placement aware multibit banking to group single-bit register cells that 
	# are physically near each other into a multibit registers
	identify_register_banks -output \
	    ${RESULTS_DIR}/${DCRM_MULTIBIT_CREATE_REGISTER_BANK_FILE}
	source -echo -verbose ${RESULTS_DIR}/${DCRM_MULTIBIT_CREATE_REGISTER_BANK_FILE}
    }
}
if $DFT_COMPILE {
#################################################################################
# DFT Compiler Optimization Section
#################################################################################

    #############################################################################
    # Verilog Libraries for Test Design Rule Checking
    #############################################################################

    # For complex cells that do not have functional models in .lib format,
    # you can supply a list of TetraMAX-compatible Verilog libraries 
    # for test design rule checking.
    # Set the following variable in the dc_setup.tcl file:
    
    # set_app_var test_simulation_library <list of Verilog library files>

    #############################################################################
    # DFT Signal Type Definitions
    #
    # These are design-specific settings that should be modified.
    # The following are only examples and should not be used.
    #############################################################################

    # Define all global DFT signals in this section. If you define any Top-down DFT partitions, 
    # specify DFT signals in the DFT partitions section.
    # It is recommended that top-level test ports be defined as a part of the
    # RTL design and included in the netlist for floorplanning.

    # If you create test ports here and they are not in your floorplan, you should use
    # create_terminal for these additional test ports for topographical mode synthesis.

    if {[shell_is_in_topographical_mode]} {
      # create_terminal -layer "layer_name" -bounding_box {x1 y1 x2 y2} -port ScanPortName ... (repeat for each new test port)
    }

    # If you are using the internal pins flow, it is recommended to run the
    # change_names command before set_dft_signal to avoid problems after DFT insertion.
    # In this case, set_dft_signal pins should be based on pin names after change_names.
    #   -  Use the "-view existing_dft" for already connected DFT signals which must be 
    #      understood for the design to pass "dft_drc".
    #   -  Use the "-view spec" for DFT signals that DFT Compiler will use during
    #      "insert_dft" when making new scan connections.

    # change_names -rules verilog -hierarchy

    # set_dft_signal -view spec -type ScanDataOut -port SO
    # set_dft_signal -view spec -type ScanDataIn -port SI
    # set_dft_signal -view spec -type ScanEnable -port SCAN_ENABLE
    # set_dft_signal -view existing_dft -type ScanClock -port [list CLK] -timing {45 55}
    # set_dft_signal -view existing_dft -type Reset -port RESET -active 0

    puts "RM-Info: Sourcing script file [which ${DCRM_DFT_SIGNAL_SETUP_INPUT_FILE}]\n"
    source -echo -verbose ${DCRM_DFT_SIGNAL_SETUP_INPUT_FILE}

    #############################################################################
    # DFT for Clock Gating
    #
    # This section includes variables and commands used only when clock gating
    # has been performed in the design.
    #############################################################################

    # Use the following command to initialize clock gating cells for test that are
    # made transparent with a signal held constant for testing, e.g. of type 'Constant'.
    # The value set depends on the hierarchy depth of the clock-gating cells.
    # This setting is not needed where clock-gating cells are controlled with scan enable.

    # set_dft_drc_configuration -clock_gating_init_cycles 1

    # To specify a dedicated ScanEnable/TestMode signal to be used for clock gating,
    # use the "-usage clock_gating" option of the "set_dft_signal" command

    # set_dft_signal -view spec -type <ScanEnable|TestMode> -port <dedicated port> -usage clock_gating

    # You can specify the clock-gating connectivity of the ScanEnable/TestMode signals
    # after they are predefined with set_dft_signal -usage clock_gating

    # set_dft_connect <LABEL> -type clock_gating_control -source <DFT signal> [-target ...]

    #############################################################################
    # DFT Configuration
    #############################################################################

    # Preserve the design name when writing to the database during DFT insertion. 
    set_dft_insertion_configuration -preserve_design_name true

    # Do not perform synthesis optimization during DFT insertion. 
    set_dft_insertion_configuration -synthesis_optimization none

    # Multibit cell handling
    # Specify -preserve_multibit_segment to false to treat the cells inside a
    # multibit component as discrete sequential cells. This improves balancing
    # of scan chains.
    # Starting I-2013.12 release, the default setting is false
    # set_scan_configuration -preserve_multibit_segment false

    ## DFT Clock Mixing Specification
    # For a hierarchical flow, don't mix clocks at the block level:
    # set_scan_configuration -clock_mixing no_mix

    # For a top-down methodology clock mixing is recommended, if possible:
    set_scan_configuration -clock_mixing mix_clocks

    #############################################################################
    # DFT AutoFix Configuration
    #############################################################################

    # Please refer to the DFT Compiler, DFTMAX, and DFTMAX Ultra User Guide, Chapter 12,
    # "Advanced DFT Architecture Methodologies", "Using AutoFix" section.

    # Please refer to the dc.dft_autofix_config.tcl file included with the
    # Design Compiler Reference Methodology scripts for an example of a
    # design-specific AutoFix configuration.

    # Create a design-specific Autofix configuration file and uncomment the
    # following line to source this file.

    # source -echo -verbose ${DCRM_DFT_AUTOFIX_CONFIG_INPUT_FILE}

    #############################################################################
    # DFTMAX Compression Configuration 
    #############################################################################

    # To enable DFTMAX compression insertion regenerate a new set of scripts with default
    # configuration or uncomment the following command to enable it.

    # set_dft_configuration -scan_compression enable

    # DFTMAX Compression Options:
    # 
    #  -min_power true
    #     This specifies that compressor inputs are to be gated for functional power
    #     saving. 
    #     It also reduces glitching during functional and capture operations
    #     Default for -min_power option is false. Recommend that you set this to
    #     true. 
    #
    #  -xtolerance: value is set to tool default. 
    #     Specify "high" to generate DFTMAX compression architecture that has 100% X-tolerance.
    #
    #  -minimum_compression: tool default is a target compression ratio of 10,
    #
    #  -location <compressor_decompressor_location>
    #      Specifies the instance name in which the compressor and decompressor 
    #      will be instantiated.
    #      The default location is the top level of the current design.
    # 
    # For details on these and other DFTMAX compression options, please refer to the
    # DFT Compiler, DFTMAX, and DFTMAX Ultra User Guide, Chapter 18, "Using DFTMAX Compression"
    # and Chapter 20, "Managing X Values in Scan Compression".
     
    # set_scan_compression_configuration -xtolerance high -min_power true;

    # Use the following to define the test-mode signal to be used for DFTMAX  
    # compression. Ensure that that test mode signals to be used for clockgating have 
    # been configured with set_dft_signal -usage clock_gating.

    # set_dft_signal -view spec -type TestMode -port scan_compression_enable




    #############################################################################
    # DFT Pipelined Scan Data Configuration
    #############################################################################

    # Pipelined Scan Data Registers are commonly used with DFTMAX designs to
    # reduce the delay between top-level scan-in and scan-out ports and the
    # first and last element of the scan chain.

    # For details on Pipelined Scan Data please refer to DFT Compiler, DFTMAX, and DFTMAX Ultra
    # User Guide Chapter 21, "Advanced DFTMAX Compression", "Pipelined Scan Data" section.

    # Enabling automatic insertion of Pipelined Scan Data registers

    # set_dft_configuration -pipeline_scan_data enable

    # Controlling Automatic insertion of Pipelined Scan Data Registers

    # Use set_pipeline_scan_data_configuration to control how Pipelined Scan Data Registers 
    # should be inserted

    # Options:
    #  -head_pipeline_clock  <name of clock for head pipeline registers>
    #  -tail_pipeline_clock  <name of clock for tail pipeline registers>
    #  -head_pipeline_stages <desired number of head pipeline stages>
    #  -tail_pipeline_stages <desired number of tail pipeline stages>

    # Note: No scan clock signal can be shared with the Pipelined Scan Data Register clock

    # set_pipeline_scan_data_configuration -head_pipeline_clock <clock_name> \
    #   -tail_pipeline_clock <clock_name> \
    #   -head_pipeline_stages <x> \
    #   -tail_pipeline_stages <y>

    #############################################################################
    # DFT Additional Setup
    #############################################################################

    # Add any additional design-specific DFT constraints here

    #############################################################################
    # Defining Multiple Test modes
    #############################################################################
    
    # Use the define_test_mode command to define additional test modes that you wish to build.
    #
    # If you have enabled DFTMAX or DFTMAX Ultra Compression, the tool will build two test modes by 
    # default: ScanCompression_mode and Internal_scan. 
    #
    # If you wish to override the default test modes, you need to define the purpose of that test mode, 
    # then use the -base_mode and -test_mode options of set_scan_compression_configuration or 
    # set_streaming_compression_configuration command to define the correspondence between the two modes.
    #  
    # Design Compiler shell switches to that test mode after a define_test_mode command.
    #
    ###########################################################################
    # Defining DFT partitions
    ###########################################################################
    # Use the define_dft_partition command to define a set of clock domains, design references,
    # hierarchical cells, or sequential leaf cells that you can specify scan and compression configuration.
    # Then use the current_dft_partition command to set the current partition, then apply one or more
    # supported test configuration commands to configure scan for that partition.
    # Define any partition specific DFT signals in this section.
    #
    # Be sure to define any global scan and compression configuration and signals before define_dft_partition command.
    #
    # Please refer to the DFT Compiler, DFTMAX, and DFTMAX Ultra User Guide, Chapter 18,
    # "Using DFTMAX Compression", "Top-Down Flat Compressed Scan Flow with Partitions" section.
    #
    # define_dft_partition <partition_1>       \
    #   -include <list_of_cells_or_references> \
    #   -clocks  <list of_clocks>
    #
    # define_dft_partition <partition_2>       \
    #   -include <list_of_cells_or_references> \
    #   -clocks  <list of_clocks>
    #
    # current_dft_partition <partition_1>
    # <Scan and Compression configuration for partition_1>
    # If you have defined multiple test modes, you must use -test_mode option when defining DFT signals.
    # <DFT signals specific to partition_1>
    #
    # current_dft_partition <partition_2>
    # <Scan and Compression configuration for partition_2>
    # If you have defined multiple test modes, you must use -test_mode option when defining DFT signals.
    # <DFT signals specific to partition_2>
    
    #############################################################################
    # DFT Test Protocol Creation
    #############################################################################

    create_test_protocol

    #############################################################################
    # DFT Insertion
    #############################################################################

    # Use the -verbose version of dft_drc to assist in debugging if necessary
    
    dft_drc                                
    dft_drc -verbose                           > ${REPORTS_DIR}/${DCRM_DFT_DRC_CONFIGURED_VERBOSE_REPORT}
    report_scan_configuration                  > ${REPORTS_DIR}/${DCRM_DFT_SCAN_CONFIGURATION_REPORT}
    report_dft_insertion_configuration         > ${REPORTS_DIR}/${DCRM_DFT_PREVIEW_CONFIGURATION_REPORT}

    # Use the -show all version to preview_dft for more detailed report
    preview_dft                                > ${REPORTS_DIR}/${DCRM_DFT_PREVIEW_DFT_SUMMARY_REPORT}
    preview_dft -show all -test_points all     > ${REPORTS_DIR}/${DCRM_DFT_PREVIEW_DFT_ALL_REPORT}

    insert_dft

    #################################################################################
    # Re-create Default Path Groups
    #
    # In case of ports being created during insert_dft they need to be added
    # to those path groups.
    # Separating these paths can help improve optimization.
    #################################################################################
    
    set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
    group_path -name REGOUT -to [all_outputs]
    group_path -name REGIN -from [remove_from_collection [all_inputs] ${ports_clock_root}]
    group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
}

################################################################################
## RM+ Variable and Command Settings before incremental compile
################################################################################
if { $OPTIMIZATION_FLOW == "hplp" } {
  # Creating path groups to reduce TNS
 create_auto_path_groups -mode mapped
}
if { (${OPTIMIZATION_FLOW} == "hc") || (${OPTIMIZATION_FLOW} == "hplp") } {
    if {[shell_is_in_topographical_mode]} {

	# Enable congestion-driven  placement  in incremental compile to improve congestion    
	# while preserving quality of results
	set_app_var spg_congestion_placement_in_incremental_compile true
    }
}

if {[file exists [which ${LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST}]]} {
  puts "RM-Info: Sourcing script file [which ${LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST}]\n"
  source -echo -verbose $LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST
}

#########################################################################
# Incremental compile is required if netlist and/or constraints are 
# changed after first compile
# Example: DFT insertion, Placement aware multibit banking etc.       
# Incremental compile is also recommended for final QoR signoff as well
#########################################################################   

compile_ultra -incremental -scan

################################################################################
# Remove the path groups generated by create_path_groups command. 
# This does not remove user created path groups
################################################################################
if { $OPTIMIZATION_FLOW == "hplp" } {
    remove_auto_path_groups
}
#################################################################################
# High-effort area optimization
#
# optimize_netlist -area command, was introduced in I-2013.12 release to improve
# area of gate-level netlists. The command performs monotonic gate-to-gate 
# optimization on mapped designs, thus improving area without degrading timing or
# leakage. 
#################################################################################

optimize_netlist -area
}
#################################################################################
# Write Out Final Design and Reports
#
#        .ddc:   Recommended binary format used for subsequent Design Compiler sessions
#    Milkyway:   Recommended binary format for IC Compiler
#        .v  :   Verilog netlist for ASCII flow (Formality, PrimeTime, VCS)
#       .spef:   Topographical mode parasitics for PrimeTime
#        .sdf:   SDF backannotated topographical mode timing for PrimeTime
#        .sdc:   SDC constraints for ASCII flow
#
#################################################################################

change_names -rules verilog -hierarchy

# write_icc2_files -force  -output ${RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}

if $DFT_COMPILE {
    #############################################################################
    # DFT Write out Test Protocols and Reports
    #############################################################################

    # write_scan_def adds SCANDEF information to the design database in memory, so 
    # this command must be performed prior to writing out the design database 
    # containing binary SCANDEF.

    write_scan_def -output ${RESULTS_DIR}/${DCRM_DFT_FINAL_SCANDEF_OUTPUT_FILE}
    check_scan_def > ${REPORTS_DIR}/${DCRM_DFT_FINAL_CHECK_SCAN_DEF_REPORT}
    write_test_model -format ctl -output ${RESULTS_DIR}/${DCRM_DFT_FINAL_CTL_OUTPUT_FILE}

    report_dft_signal > ${REPORTS_DIR}/${DCRM_DFT_FINAL_DFT_SIGNALS_REPORT}

    # DFT outputs for standard scan mode

    write_test_protocol -test_mode Internal_scan -output ${RESULTS_DIR}/${DCRM_DFT_FINAL_PROTOCOL_OUTPUT_FILE}
    current_test_mode Internal_scan
    report_scan_path > ${REPORTS_DIR}/${DCRM_DFT_FINAL_SCAN_PATH_REPORT}
    dft_drc
    dft_drc -verbose > ${REPORTS_DIR}/${DCRM_DFT_DRC_FINAL_REPORT}

    # DFT outputs for compressed scan mode

    # write_test_protocol -test_mode ScanCompression_mode -output ${RESULTS_DIR}/${DCRM_DFT_FINAL_SCAN_COMPR_PROTOCOL_OUTPUT_FILE}
    # current_test_mode ScanCompression_mode
    # report_scan_path > ${REPORTS_DIR}/${DCRM_DFT_FINAL_SCAN_COMPR_SCAN_PATH_REPORT}
    # dft_drc 
    # dft_drc -verbose > ${REPORTS_DIR}/${DCRM_DFT_DRC_FINAL_SCAN_COMPR_REPORT}
}

#################################################################################
# Write out Design
#################################################################################

write -format verilog -hierarchy -output ${RESULTS_DIR}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}

write -format ddc     -hierarchy -output ${RESULTS_DIR}/${DCRM_FINAL_DDC_OUTPUT_FILE}


# Write and close SVF file and make it available for immediate use
set_svf -off

#################################################################################
# Write out Design Data
#################################################################################

if {[shell_is_in_topographical_mode]} {

  # Note: A secondary floorplan file ${DCRM_DCT_FINAL_FLOORPLAN_OUTPUT_FILE}.objects
  #       might also be written to capture physical-only objects in the design.
  #       This file should be read in before reading the main floorplan file.

  write_floorplan -all ${RESULTS_DIR}/${DCRM_DCT_FINAL_FLOORPLAN_OUTPUT_FILE}

  # Write parasitics data from Design Compiler Topographical placement for static timing analysis
  write_parasitics -output ${RESULTS_DIR}/${DCRM_DCT_FINAL_SPEF_OUTPUT_FILE}

  # Write SDF backannotation data from Design Compiler Topographical placement for static timing analysis
  write_sdf ${RESULTS_DIR}/${DCRM_DCT_FINAL_SDF_OUTPUT_FILE}

  # Do not write out net RC info into SDC
  set_app_var write_sdc_output_lumped_net_capacitance false
  set_app_var write_sdc_output_net_resistance false
}

write_sdc -nosplit ${RESULTS_DIR}/${DCRM_FINAL_SDC_OUTPUT_FILE}

# If SAIF is used, write out SAIF name mapping file for PrimeTime-PX
# saif_map -type ptpx -write_map ${RESULTS_DIR}/${DESIGN_NAME}.mapped.SAIF.namemap

#################################################################################
# Generate Final Reports
#################################################################################

if { $OPTIMIZATION_FLOW  == "rtm_exp"} {
  set_host_options -max_cores 8
  update_timing

  parallel_execute [list \
  "report_qor > ${REPORTS_DIR}/${DCRM_FINAL_QOR_REPORT}" \
  "report_timing -transition_time -nets -attributes -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_TIMING_REPORT}" \
  "report_area -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}" \
  "report_clock_gating -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_CLOCK_GATING_REPORT}" \
  ]

} else {
report_qor > ${REPORTS_DIR}/${DCRM_FINAL_QOR_REPORT}

report_timing -transition_time -nets -attributes -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_TIMING_REPORT}

if {[shell_is_in_topographical_mode]} {
  report_area -physical -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}
} else {
  report_area -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}
}
report_area -designware  > ${REPORTS_DIR}/${DCRM_FINAL_DESIGNWARE_AREA_REPORT}
report_resources -hierarchy > ${REPORTS_DIR}/${DCRM_FINAL_RESOURCES_REPORT}
report_clock_gating -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_CLOCK_GATING_REPORT}
}

# Create a QoR snapshot of timing, physical, constraints, clock, power data, and routing on 
# active scenarios and stores it in the location  specified  by  the icc_snapshot_storage_location 
# variable. 

if {[shell_is_in_topographical_mode]} {
  set icc_snapshot_storage_location ${REPORTS_DIR}/${DCRM_DCT_FINAL_QOR_SNAPSHOT_FOLDER}
  create_qor_snapshot -name ${DCRM_DCT_FINAL_QOR_SNAPSHOT_REPORT} > ${REPORTS_DIR}/${DCRM_DCT_FINAL_QOR_SNAPSHOT_REPORT}
}


# Uncomment the next line to report all the multibit registers and the banking ratio in the design
redirect ${REPORTS_DIR}/${DCRM_MULTIBIT_BANKING_REPORT} {report_multibit_banking -nosplit }

# Use SAIF file for power analysis
# read_saif -auto_map_names -input ${DESIGN_NAME}.saif -instance < DESIGN_INSTANCE > -verbose


report_power -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_POWER_REPORT}
report_clock_gating -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_CLOCK_GATING_REPORT}

# Uncomment the next line if you include the -self_gating to the compile_ultra command
# to report the XOR Self Gating information.
# report_self_gating  -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_SELF_GATING_REPORT}

# Uncomment the next line to reports the number, area, and  percentage  of cells 
# for each threshold voltage group in the design.
# report_threshold_voltage_group -nosplit > ${REPORTS_DIR}/${DCRM_THRESHOLD_VOLTAGE_GROUP_REPORT}

if {[shell_is_in_topographical_mode]} {
  # report_congestion (topographical mode only) uses zroute for estimating and reporting 
  # routing related congestion which improves the congestion correlation with IC Compiler.
  # Design Compiler Topographical supports create_route_guide command to be consistent with IC
  # Compiler after topographical mode synthesis.
  # Those commands require a license for Design Compiler Graphical.

  report_congestion > ${REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_REPORT}

  # Use the following to generate and write out a congestion map from batch mode
  # This requires a GUI session to be temporarily opened and closed so a valid DISPLAY
  # must be set in your UNIX environment.

  if {[info exists env(DISPLAY)]} {
    gui_start

    # Create a layout window
    set MyLayout [gui_create_window -type LayoutWindow]

    # Build congestion map in case report_congestion was not previously run
    report_congestion -build_map

    # Display congestion map in layout window
    gui_show_map -map "Global Route Congestion" -show true

    # Zoom full to display complete floorplan
    gui_zoom -window [gui_get_current_window -view] -full

    # Write the congestion map out to an image file
    # You can specify the output image type with -format png | xpm | jpg | bmp

    # The following saves only the congestion map without the legends
    gui_write_window_image -format png -file ${REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_MAP_OUTPUT_FILE}

    # The following saves the entire congestion map layout window with the legends
    gui_write_window_image -window ${MyLayout} -format png -file ${REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_MAP_WINDOW_OUTPUT_FILE}

    gui_stop
  } else {
    puts "Information: The DISPLAY environment variable is not set. Congestion map generation has been skipped."
  }
}


#################################################################################
# Write out Milkyway Design for Top-Down Flow
#
# This should be the last step in the script
#################################################################################

if {[shell_is_in_topographical_mode]} {
  # write_milkyway uses mw_design_library variable from dc_setup.tcl
  write_milkyway -overwrite -output ${DCRM_FINAL_MW_CEL_NAME}
}

exit
