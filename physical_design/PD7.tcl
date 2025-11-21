# Creating some directories for generating reports_wc.
# Arrange in correct sequence
file mkdir /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route
file mkdir /home/mrinank22305/Desktop/Processor/place_and_route/timing
file mkdir /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/area
file mkdir /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/GDS
file mkdir /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/netlist
file mkdir /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/incremental_placement_report
#source /home/anuj24175/cmos65/IP_temp1/scripts/cortexm0integration_config.tcl

set init_gnd_net gnd
#set init_lef_file {//home/mrinank22305/Desktop/Processor/CORE65LPSVT_soc.lef}
set init_lef_file /home/mrinank22305/Desktop/Processor/CORE65LPSVT_soc.lef
set init_mmmc_file /home/mrinank22305/Desktop/Processor/rtl_wc.view
set init_io_file pin_location.io
set init_pwr_net vdd
set init_verilog /home/mrinank22305/Desktop/Processor/dft_report/dft_syn_min_area_dft_CORE65LPSVT_wc_1.05V_125C.v
init_design

# informing the tech node and effort kept standard
setDesignMode -process 65 -flowEffort standard
# Timing calculation mode. onChipVariation mode enables use of max and min delays for paths for late and early calculations/optimizations respectively.
setAnalysisMode -analysisType onChipVariation


# Informing the implementation tool about the scan chains 
# This is important : Physical design tool won't run if this is not specified (not the case when your netlist does not have scan chains)
#set scan_data_in $rm_scan_data_in
#set scan_data_out $rm_scan_data_out
#set no_of_chains $rm_no_of_chains
#for { set i 0 } {$i <= [expr $no_of_chains - 1] } {incr i} {
   #specifyScanChain scan_chain_${i} -start ${scan_data_in}${i} -stop ${scan_data_out}${i}
#}
#if { 0 } {
# floorplan telling which site to use from the LEF file
# rowDensity = (std area + block/macro area) / core area
# Taken 0.6 => Just an estimate of utilization of the core area for placement. Being done to avoid congestion in routing (can be changed).
#loadFPlan /home/anuj24175/cmos65/IP_temp1/work/CORTEXM0INTEGRATION_mem_wrapper.fp
#floorPlan -site CORE -r 1 $utilization_factor 5 5 5 5
floorPlan -site CORE -r 1 0.5 4.06 4.06 4.06 4.06
#floorPlan -site CORE -r 1 0.5 12 12 12 12

#						  Left Bot  Right Top
# Always place the macro before adding the stripes. 
# Stripes hence avoid crossing the Macro and shorts don't occur.
# placeInstance SRAM0 1 1 R0






# Center the core rings between core IO pads and core boundary.
# Type selects whether to create core or block rings.
# Layer specified for horizontal and vertical routing. We have the uppermost layer as Metal 6 in our design.
# Width and spacing of the meta specified
# Offset from the outermost boundary defined as well.
addRing -center 1 -type core_rings -nets {gnd vdd} -follow core -layer {bottom M7 top M7 right AP left AP} -width {top 1.25 bottom 1.25 left 3 right 3} -spacing {top 0.4 bottom 0.4 left 2 right 2} -offset {top 0.435 bottom 0.435 left 0.435 right 0.435}


# Spacing between vdd and gnd stripe : 0.46
# Layer being used for stripes : Metal 5
# Width of both vdd and gndstripes : 0.44
# Padcore_ring_top_layer_limit and Padcore_ring_bottom_layer_limit: Specifies the topmost and lowermost layer that the stripe can switch to when encountered by a padcore or ring.

#
specifyScanChain test_si1 -start DFT_sdi -stop DFT_sdo
specifyScanChain test_si2 -start DFT_sdi_1 -stop DFT_sdo_1
#
addStripe -padcore_ring_bottom_layer_limit M6 -number_of_sets 60 -padcore_ring_top_layer_limit AP -spacing 2 -layer M7 -block_ring_bottom_layer_limit M6 -width 3 -nets {vdd gnd}

sroute -nets {vdd gnd} -allowLayerChange 1 -layerChangeRange {M1 AP}

# Saves us from unconnected pins DRCs
globalNetConnect vdd -type pgpin -pin vdd
globalNetConnect gnd -type pgpin -pin gnd


setPlaceMode -place_global_place_io_pins true



place_opt_design -out_dir /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/incremental_placement_report -prefix cortexm0integration


# connect power ang ground pins of all the instances to global nets
# globalNetConnect gnd -type pgpin -pin gnd
# globalNetConnect vdd -type pgpin -pin vdd
# add horizintal stripes vdd/gnd sRoute





#report_timing -early -view {view_fast} -max_paths 100 > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/timing/timing_post_PreCTS_early.txt
report_timing -early -view {view1} -max_paths 100 > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/timing/timing_post_PreCTS_early.txt
report_timing -late -max_paths 100 > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/timing/timing_post_PreCTS_late.txt




set_ccopt_mode -cts_buffer_cells {HS65_LS_BFX284 } -cts_opt_priority all
set_ccopt_mode -cts_buffer_cells {HS65_LH_BFX9 HS65_LH_BFX7 HS65_LH_BFX4 HS65_LH_BFX2 HS65_LH_BFX18 HS65_LH_BFX13 HS65_LH_BFX27 HS65_LH_BFX22 HS65_LH_BFX35 HS65_LH_BFX31 HS65_LH_BFX44 HS65_LH_BFX40 HS65_LH_BFX53 HS65_LH_BFX49 HS65_LH_BFX62 HS65_LH_BFX71 HS65_LH_BFX106 HS65_LH_BFX213 HS65_LH_BFX284 } -cts_opt_priority all


#create_ccopt_clock_tree_spec -file /home/mrinank22305/Desktop/Processor/ccopt_new.spec -keep_all_sdc_clocks -views {view_slow view_fast}
create_ccopt_clock_tree_spec -file /home/mrinank22305/Desktop/Processor/ccopt_new.spec -keep_all_sdc_clocks -views {view1}

source /home/mrinank22305/Desktop/Processor/ccopt_new.spec 

# ccopt_design is a super command. Capable of doing complete CTS
ccopt_design -check_prerequisites
ccopt_design -outDir /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/timing


optDesign -postCTS;

# Repair clock tree rules violations post CTS
ccopt_pro -enable_drv_fixing true -enable_drv_fixing_by_rebuffering true -enable_refine_place true -enable_routing_eco true -enable_skew_fixing true -enable_skew_fixing_by_rebuffering true -enable_timing_update true

# Check for any violations
report_constraint -all_violators


checkPlace /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/place_violations_report_postCTS.txt

# Multi mode multi corner analysis allows us to direclty use the already created views

#report_timing -early -view {view_fast} -max_paths 100 > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/timing/timing_post_CTS_early.txt
#report_timing -late -view {view_slow} -max_paths 100 > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/timing/timing_post_CTS_late.txt
report_timing -late -view {view1} -max_paths 100 > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/timing/timing_post_CTS_late.txt

setDesignMode -bottomRoutingLayer M1 -topRoutingLayer AP

routeDesign

verify_drc > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/post_route_DRC_vio.rpt

verifyConnectivity > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/post_detailedRoute_verifyConnectivity.rpt

reportRoute > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/postDetailRoute_reportRoute.rpt

reportWire /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/postDetailRoute_reportWire.rpt

#report_timing -early -view {view_fast} -max_paths 100 > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/timing/timing_post_PnR_early.txt
#report_timing -late -view {view_slow} -max_paths 100 > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/timing/timing_post_PnR_late.txt
report_timing -late -view {view1} -max_paths 100 > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/timing/timing_post_PnR_late.txt

report_area -detail > /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/area/area_post_pnr.rpt
report_power -rail_analysis_format VS -outfile /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/area/power.rpt

streamOut /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/GDS/GDSoutput

saveNetlist /home/mrinank22305/Desktop/Processor/reports_wc/place_and_route/netlist/CORTEXM0INTEGRATION_wrapper__post_pnr.v

#}
