# Read design

define_design_lib WORK -path work
set_app_var alib_library_analysis_path /project/design/CCE4600/lib/

# short module names
# https://solvnet.synopsys.com/retrieve/029589.html
set_app_var template_naming_style   "%s"
set_app_var template_parameter_style "%s"
#set_app_var hdlin_shorten_long_module_name true
#set_app_var hdlin_module_name_limit 32
set hdlin_force_template_style true

# FSM variables
set_app_var hdlin_reporting_level comprehensive
set_app_var fsm_auto_inferring true
#set_app_var fsm_enable_state_minimization true

analyze -format sverilog \
        -define NO_MODPORT_EXPRESSIONS \
    [list j1_types.sv \
         interfaces.sv \
         register_file.sv \
         j1_wb.sv]

#elaborate $DESIGN_NAME -param "dstack_depth => 8, rstack_depth => 8"
#elaborate $DESIGN_NAME -param "dstack_depth => 12, rstack_depth => 12"
#elaborate $DESIGN_NAME -param "dstack_depth => 16, rstack_depth => 16"
#elaborate $DESIGN_NAME -param "dstack_depth => 20, rstack_depth => 20"
#elaborate $DESIGN_NAME -param "dstack_depth => 24, rstack_depth => 24"
#elaborate $DESIGN_NAME -param "dstack_depth => 28, rstack_depth => 28"
elaborate $DESIGN_NAME
