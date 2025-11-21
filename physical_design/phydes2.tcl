# Initialize Design
set init_gnd_net gnd
set init_lef_file {//home/mrinank22305/Desktop/Processor/lef.lef}
set init_mmmc_file /home/mrinank22305/Desktop/Processor/rtl.view
set init_io_file pin_data.io
set init_pwr_net vdd
set init_verilog /home/mrinank22305/Desktop/Processor/dft_report/dft_syn_min_area_dft.v
init_design

# ========== MEMORY MANAGEMENT ==========
# Increase memory limits before operations begin
set_memory_usage -limit 8G
set_thread_count 4

# Floorplanning
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site gsclib090site -r 1 0.5 4.06 4.06 4.06 4.06

# Power Planning
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -center 1 -stacked_via_top_layer Metal9 -type core_rings -jog_distance 0.435 -threshold 0.435 -nets {GND VDD} -follow core -stacked_via_bottom_layer Metal1 -layer {bottom Metal8 top Metal8 right Metal9 left Metal9} -width 1.25 -spacing 0.4 -offset 0.435

addStripe -skip_via_on_wire_shape Noshape -block_ring_top_layer_limit Metal9 -max_same_layer_jog_length 0.88 -padcore_ring_bottom_layer_limit Metal7 -number_of_sets 10 -skip_via_on_pin Standardcell -stacked_via_top_layer Metal9 -padcore_ring_top_layer_limit Metal9 -spacing 0.4 -merge_stripes_value 0.435 -layer Metal8 -block_ring_bottom_layer_limit Metal7 -width 0.44 -nets {VDD GND} -stacked_via_bottom_layer Metal1

# Scan Chains
specifyScanChain test_si1 -start DFT_sdi -stop DFT_sdo
specifyScanChain test_si2 -start DFT_sdi_1 -stop DFT_sdo_1

# Placement
setPlaceMode -fp false
placeDesign
optDesign -preCTS

# Power Analysis (Post-Placement)
set_power_analysis_mode -reset
set_power_analysis_mode -method static -analysis_view view1 -corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir ./PostPlacementPowerRpt
set_default_switching_activity -input_activity 0.2 -period 10.0
report_power -rail_analysis_format VS -outfile ./PostPlacementPowerRpt/rtl_module_post_placement.rpt
summaryReport -outdir postPlaceArea -noHtml
report_area -detail -show_leaf_cells -table_style {vertical}

# CTS with Buffer Specification
set_ccopt_mode -cts_buffer_cells {CLKBUFX12 CLKBUFX16 CLKBUFX2 CLKBUFX20 CLKBUFX3 CLKBUFX4 CLKBUFX6 CLKBUFX8 CLKINVX1 CLKINVX12 CLKINVX16 CLKINVX2 CLKINVX20 CLKINVX3 CLKINVX4 CLKINVX6 CLKINVX8}
create_ccopt_clock_tree_spec -file file_cts.spec -keep_all_sdc_clocks -views {view1}
source file_cts.spec
ccopt_design

# ========== POST-CTS BUFFER INSERTION ==========
optDesign -postCTS -setup
optDesign -postCTS -hold

# Check and fix hold violations with proper buffer command
if {[llength [get_hold_violations]] > 0} {
    puts "INFO: Inserting buffers for hold violation fixes"
    addRepeater -hold -buffer BUF_X2 -distance 50 -cell [get_cells -hier *]
    timeDesign -postCTS -hold
}

# Power Analysis (Post-CTS)
set_power_output_dir ./PostCTSPowerRPT
report_power -rail_analysis_format VS -outfile ./PostCTSPowerRPT/rtl_module_post_cts.rpt
summaryReport -outdir postCTSArea -noHtml
report_area -detail -show_leaf_cells -table_style {vertical}

# ========== ROUTING ==========
setNanoRouteMode -quiet -timingEngine {}
routeDesign -globalDetail -wireOpt

# ========== POST-ROUTE OPTIMIZATION ==========
optDesign -postRoute
optDesign -postRoute -hold

# Manual buffer insertion for specific critical nets (example)
# if {[llength [get_nets -hier "critical_net*"]] > 0} {
#     addRepeater -net [get_nets -hier "critical_net*"] -cell BUF_X4 -distance 100
# }

extractRC
rcOut -spef rtl_module.spef
write_sdf -ideal_clock_network physical_design_rtl_module.sdf

# Final Verification
verify_drc
verify_connectivity

# Power Analysis (Post-Route)
set_power_output_dir ./PostRoutingPowerRpt
report_power -rail_analysis_format VS -outfile ./PostRoutingPowerRpt/rtl_module.rpt

# Output Files
reportGateCount -level 5 -limit 100 -outfile rtl_module.gateCount
streamOut rtl_module.gds -mapFile streamOut.map -libName DesignLib -units 2000 -mode ALL
saveNetlist rtl_module_post_route_netlist.v
defOut -floorplan -netlist -routing rtl_module.def
saveDesign new_uptoGDS.enc

# Final Area Report
summaryReport -outdir postRouteArea -noHtml
report_area -detail -show_leaf_cells -table_style {vertical}

# ========== CLEANUP ==========
# Release memory before exit
release_memory
puts "Flow completed successfully"
