set init_gnd_net gnd
#set init_lef_file {//home/mrinank22305/Desktop/Processor/lef.lef}
#set init_lef_file {//home/mrinank22305/Desktop/Processor/CORE65LPSVT_soc.lef}
set init_lef_file /home/mrinank22305/Desktop/Processor/CORE65LPHVT_soc.lef

######################################remove # from the case you want to run####################################
set init_mmmc_file /home/mrinank22305/Desktop/Processor/rtl_CORE65LPHVT_bc_1.05V_125C.view 
#set init_mmmc_file /home/mrinank22305/Desktop/Processor/rtl_CORE65LPHVT_nom_1.05V_125C.view
#set init_mmmc_file /home/mrinank22305/Desktop/Processor/rtl_CORE65LPHVT_wc_1.05V_125C.view
#set init_mmmc_file /home/mrinank22305/Desktop/Processor/rtl_CORE65LPHVT_wc_0.90V_105C.view
#set init_mmmc_file /home/mrinank22305/Desktop/Processor/rtl_CORE65LPSVT_bc_1.05V_125C.view 
#set init_mmmc_file /home/mrinank22305/Desktop/Processor/rtl_CORE65LPSVT_nom_1.05V_125C.view
#set init_mmmc_file /home/mrinank22305/Desktop/Processor/rtl_CORE65LPSVT_wc_1.05V_125C.view
#set init_mmmc_file /home/mrinank22305/Desktop/Processor/rtl.view
#

set init_io_file pin_data.io
set init_pwr_net vdd

######################################remove # from the case you want to run####################################
#set init_verilog /home/mrinank22305/Desktop/Processor/dft_report/dft_syn_min_area_dft_CORE65LPHVT_wc_0.90V_105C.v
#set init_verilog /home/mrinank22305/Desktop/Processor/dft_report/dft_syn_min_area_dft_CORE65LPSVT_bc_1.05V_125C.v
#set init_verilog /home/mrinank22305/Desktop/Processor/dft_report/dft_syn_min_area_dft_CORE65LPSVT_nom_1.05V_125C.v
#set init_verilog /home/mrinank22305/Desktop/Processor/dft_report/dft_syn_min_area_dft_CORE65LPSVT_wc_1.05V_125C.v
set init_verilog /home/mrinank22305/Desktop/Processor/dft_report/dft_syn_min_area_dft_CORE65LPHVT_bc_1.05V_125C.v
#set init_verilog /home/mrinank22305/Desktop/Processor/dft_report/dft_syn_min_area_dft_CORE65LPHVT_nom_1.05V_125C.v
#set init_verilog /home/mrinank22305/Desktop/Processor/dft_report/dft_syn_min_area_dft_CORE65LPHVT_wc_1.05V_125C.v
#set init_verilog /home/mrinank22305/Desktop/Processor/dft_report/dft_syn_min_area_dft.v
#

init_design

#/*Floorplanning*/
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site CORE -r 1 0.5 4.06 4.06 4.06 4.06
#floorPlan -site gsclib090site -r 1 0.5 4.06 4.06 4.06 4.06
#floorPlan -site CORE -r 10 0.2 4.06 4.06 4.06 4.06



    # Adding Rings for 65nm
setAddRingMode -stacked_via_top_layer AP
setAddRingMode -stacked_via_bottom_layer M1
setAddStripeMode -stacked_via_top_layer AP
setAddStripeMode -stacked_via_bottom_layer M1

# Adding Filler Cells
#addIoFiller -cell FILLER_CELL_NAME

# Adding Rings
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -center 1 -type core_rings -jog_distance 0.435 -threshold 0.435 -nets {VSS VDD} -follow core -layer {bottom M7 top M7 right AP left AP} -width 3 -spacing 0.5 -offset 1

# Adding Stripes
addStripe -skip_via_on_wire_shape Noshape -block_ring_top_layer_limit AP -max_same_layer_jog_length 0.88 -padcore_ring_bottom_layer_limit M6 -number_of_sets 10 -skip_via_on_pin Standardcell -spacing 0.4 -merge_stripes_value 0.435 -layer M7 -block_ring_bottom_layer_limit M6 -width 0.44 -nets {VDD VSS}


# Placement of standard cells without any optimization
defIn /home/mrinank22305/Desktop/2.RCA/RCA_32bit_65nm_CORE65LPHVT/5.DFT/dft_report/min_delay/rtl_module_min_delay.def
setPlaceMode -fp false
placeDesign -noPrePlaceOpt

# Pre-CTS timing check
setDelayCalMode -siAware false
timeDesign -preCTS

#########################################################################################  Clock Tree Synthesis  #######################################################################################################

create_ccopt_clock_tree_spec
get_ccopt_clock_trees *
set_ccopt_property target_max_trans 0.5
set_ccopt_property target_skew 0.2  
ccopt_design

# Post-CTS timing report generation
# Setup Timing check
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix rtl_module_postCTS -outDir timingReports

# Hold Timing Check
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix rtl_module_postCTS -outDir timingReports

# Generating gate count report
reportGateCount -level 5 -limit 100 -outfile rtl_module.gateCount

########################################################################################  Global & Detail Routing  ######################################################################################################

setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0
setNanoRouteMode -quiet -drouteStartIteration default
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
routeDesign -globalDetail

optDesign -postRoute -drv

optDesign -postRoute -hold
optDesign -postRoute -setup

# Writing SDF file with interconnect and gates delay
write_sdf -ideal_clock_network physical_design_rtl_module.sdf

# Post Routing timing report
# Setup Timing check
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix rtl_module_postRoute -outDir timingReports

# Hold Timing Check
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix rtl_module_postRoute -outDir timingReports

#######################################################################################  REPORTS  #######################################################################################################################

# Timing Analysis
report_timing -late > $report_dir/timing_setup_report_GBA.rpt
report_timing -early > $report_dir/timing_hold_report_GBA.rpt
report_timing -retime path_slew_propagation -max_path 100 -nworst 100 -format retime_slew > $report_dir/timing_setup_report_PBA.rpt
report_timing -retime path_slew_propagation -max_path 100 -nworst 100 -early -format retime_slew > $report_dir/timing_hold_report_PBA.rpt

# Area Analysis
report_area -detail > $report_dir/Total_Area.rpt

reportWire > $report_dir/postDetailRoute_reportWire.rpt

# Power Analysis
set_power_analysis_mode -reset
set_power_analysis_mode -method static -analysis_view view1 -corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir -reset
set_power_output_dir ./
set_default_switching_activity -reset
set_default_switching_activity -input_activity 0.2 -period 10.0
read_activity_file -reset
set_power -reset
set_powerup_analysis -reset
set_dynamic_power_simulation -reset
report_power -rail_analysis_format VS -outfile .//rtl_module.rpt
report_power
report_power -rail_analysis_format VS -outfile ./reports/rtl_module.rpt
report_power -outfile ./reports/power_report.rpt

# Generating GDS
streamOut rtl_module.gds -mapFile streamOut.map -libName DesignLib -units 2000 -mode ALL

# Saving the Design
saveNetlist rtl_module_post_route_netlist.v
defOut -floorplan -netlist -routing rtl_module.def
saveDesign new_uptoGDS.enc
show -gui
