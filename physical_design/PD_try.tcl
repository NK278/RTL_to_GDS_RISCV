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



#/*Power Planning*/

#/*Adding Rings*/
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -center 1 -stacked_via_top_layer Metal9 -type core_rings -jog_distance 0.435 -threshold 0.435 -nets {GND VDD} -follow core -stacked_via_bottom_layer Metal1 -layer {bottom Metal8 top Metal8 right Metal9 left Metal9} -width 1.25 -spacing 0.4 -offset 0.435

# Add extra command
specifyScanChain test_si1 -start DFT_sdi -stop DFT_sdo
specifyScanChain test_si2 -start DFT_sdi_1 -stop DFT_sdo_1
#specifyScanChain test_si2 -start DFT_sdi_2 -stop DFT_sdo_2
# VDD & GND Rings on Squares
#/*Adding Stripes*/

addStripe -skip_via_on_wire_shape Noshape -block_ring_top_layer_limit Metal9 -max_same_layer_jog_length 0.88 -padcore_ring_bottom_layer_limit Metal7 -number_of_sets 10 -skip_via_on_pin Standardcell -stacked_via_top_layer Metal9 -padcore_ring_top_layer_limit Metal9 -spacing 0.4 -merge_stripes_value 0.435 -layer Metal8 -block_ring_bottom_layer_limit Metal7 -width 0.44 -nets {VDD GND} -stacked_via_bottom_layer Metal1

#/*Placement*/
setPlaceMode -fp false
placeDesign

optDesign -preCTS

#/*Power Analysis*/

set_power_analysis_mode -reset
set_power_analysis_mode -method static -analysis_view view1 -corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir -reset
set_power_output_dir ./PostPlacementPowerRpt
set_default_switching_activity -reset
set_default_switching_activity -input_activity 0.2 -period 10.0
read_activity_file -reset
set_power -reset
set_powerup_analysis -reset

set_dynamic_power_simulation -reset
report_power -rail_analysis_format VS -outfile ./PostPlacementPowerRpt/rtl_module_post_placement.rpt

# Area
summaryReport -outdir postPlaceArea -noHtml
report_area -detail -show_leaf_cells -table_style {vertical}



set_ccopt_mode -cts_buffer_cells {CLKBUFX12 CLKBUFX16 CLKBUFX2 CLKBUFX20 CLKBUFX3 CLKBUFX4 CLKBUFX6 CLKBUFX8 CLKINVX1 CLKINVX12 CLKINVX16 CLKINVX2 CLKINVX20 CLKINVX3 CLKINVX4 CLKINVX6 CLKINVX8} -cts_opt_priority all
create_ccopt_clock_tree_spec -file file_cts.spec -keep_all_sdc_clocks -views {view1}

source file_cts.spec
ccopt_design -check_prerequisites
ccopt_design
optDesign -postCTS -setup
optDesign -postCTS -hold; #for hold violation

#/*Power Analysis*/

set_power_analysis_mode -reset
set_power_analysis_mode -method static -analysis_view view1 -corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir -reset
set_power_output_dir ./PostCTSPowerRPT
set_default_switching_activity -reset
set_default_switching_activity -input_activity 0.2 -period 10.0
read_activity_file -reset
set_power -reset
set_powerup_analysis -reset

set_dynamic_power_simulation -reset
report_power -rail_analysis_format VS -outfile ./PostCTSPowerRPT/rtl_module_post_cts.rpt

# Area
summaryReport -outdir postCTSArea -noHtml
report_area -detail -show_leaf_cells -table_style {vertical}


#/*Global & Detail Routing*/
setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0
setNanoRouteMode -quiet -drouteStartIteration default
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
routeDesign -globalDetail -wireOpt


# Timing Report
# optDesign -postRoute
# optDesign -postRoute -hold

extractRC
rcOut -spef rtl_module.spef

#/*Writing SDF file with interconnect and gates delay*/
write_sdf -ideal_clock_network physical_design_rtl_module.sdf

#/*Generating gate count report*/
#summaryReport -outdir summaryReport
reportGateCount -level 5 -limit 100 -outfile rtl_module.gateCount

setAnalysisMode -analysisType onChipVariation
optDesign -postRoute
optDesign -postRoute -hold

#/*Power Analysis*/
set_power_analysis_mode -reset
set_power_analysis_mode -method static -analysis_view view1 -corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir -reset
set_power_output_dir ./PostRoutingPowerRpt
set_default_switching_activity -reset
set_default_switching_activity -input_activity 0.2 -period 10.0
read_activity_file -reset
set_power -reset
set_powerup_analysis -reset

set_dynamic_power_simulation -reset
report_power -rail_analysis_format VS -outfile ./PostRoutingPowerRpt/rtl_module.rpt


#/*Generating GDS*/
streamOut rtl_module.gds -mapFile streamOut.map -libName DesignLib -units 2000 -mode ALL

#/*Saving the Design*/
saveNetlist rtl_module_post_route_netlist.v
defOut -floorplan -netlist -routing rtl_module.def
saveDesign new_uptoGDS.enc

verify_drc
verify_connectivity

# Area
summaryReport -outdir postRouteArea -noHtml
report_area -detail -show_leaf_cells -table_style {vertical}
