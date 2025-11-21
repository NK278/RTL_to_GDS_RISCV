# Set paths
#set_db lib_search_path "/path/to/libs"
#set_db hdl_search_path "/path/to/verilog"

# Load library files
######################################remove # from the case you want to run####################################
#set_attr library slow.lib
#set_attr library CORE65LPHVT_bc_1.05V_125C.lib
#set_attr library CORE65LPHVT_nom_1.05V_125C.lib
#set_attr library CORE65LPHVT_wc_1.05V_125C.lib
set_attr library CORE65LPSVT_bc_1.05V_125C.lib
#set_attr library CORE65LPSVT_nom_1.05V_125C.lib
#set_attr library CORE65LPSVT_wc_1.05V_125C.lib
#

# Read design files
read_hdl PROCESSOR.v
elaborate

# Read design constraints
read_sdc design.sdc

# Perform synthesis
synthesize -to_mapped -effort medium

# Generate reports
report timing > reports_script/timing_report.txt
report area > reports_script/area_report.txt
report power > reports_script/power_report.txt

# Export synthesized netlist
write_hdl > output/synthesized_netlist.v

#gui_show
