#set_attr lib_search_path /home/mrinank22305/Desktop/processor/lib/90
#set_attr hdl_search_path /home/mrinank22305/Desktop/Processor/output/synthesized_netlist

######################################remove # from the case you want to run####################################
#set_attr library slow.lib
#set_attr library CORE65LPHVT_wc_0.90V_105C.lib
#set_attr library CORE65LPSVT_bc_1.05V_125C.lib
set_attr library CORE65LPSVT_nom_1.05V_125C.lib
#set_attr library CORE65LPSVT_wc_1.05V_125C.lib
#set_attr library CORE65LPHVT_bc_1.05V_125C.lib
#set_attr library CORE65LPHVT_nom_1.05V_125C.lib
#set_attr library CORE65LPHVT_wc_1.05V_125C.lib
#
#read_hdl /home/mrinank22305/Desktop/Processor/output/synthesized_netlist.v
read_hdl /home/mrinank22305/Desktop/Processor/PROCESSOR.v
elaborate PROCESSOR
read_sdc /home/mrinank22305/Desktop/Processor/design.sdc
report timing -lint
set_attr dft_scan_style muxed_scan
define_dft shift_enable -active high -create_port scan_en
define_dft test_clock clock

report dft_setup
check_dft_rules >dft_report/dft_rules_report
fix_dft_violations -test_control scan_en -async_set -async_reset -clock
synthesize -to_mapped
set_attribute dft_min_number_of_scan_chains 1 PROCESSOR
set_attribute dft_mix_clock_edges_in_scan_chains true PROCESSOR
replace_scan
connect_scan_chains -auto_create_chains -preview
connect_scan_chains -auto_create_chains
report qor
write_atpg -cadence > rtl_module_min_area_dft.atpg
write_atpg -stil > rtl_module_still_min_area_dft.atpg
#write_scandef> dft_report/rtl_module_min_area_dft.def
#write_scandef> dft_report/rtl_module_min_area_dft_CORE65LPHVT_bc_1.05V_125C.def
write_scandef> dft_report/rtl_module_min_area_dft_CORE65LPHVT_nom_1.05V_125C.def
#write_scandef> dft_report/rtl_module_min_area_dft_CORE65LPHVT_wc_1.05V_125C.def
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge > dft_report/delays_optimal_min_area_dft.sdf

######################################remove # from the case you want to run####################################
#write_hdl -mapped > dft_report/dft_syn_min_area_dft.v
#write_hdl -mapped > dft_report/dft_syn_min_area_dft_CORE65LPHVT_wc_0.90V_105C.v
#write_hdl -mapped > dft_report/dft_syn_min_area_dft_CORE65LPSVT_bc_1.05V_125C.v
write_hdl -mapped > dft_report/dft_syn_min_area_dft_CORE65LPSVT_nom_1.05V_125C.v
#write_hdl -mapped > dft_report/dft_syn_min_area_dft_CORE65LPSVT_wc_1.05V_125C.v
#write_hdl -mapped > dft_report/dft_syn_min_area_dft_CORE65LPHVT_bc_1.05V_125C.v
#write_hdl -mapped > dft_report/dft_syn_min_area_dft_CORE65LPHVT_nom_1.05V_125C.v
#write_hdl -mapped > dft_report/dft_syn_min_area_dft_CORE65LPHVT_wc_1.05V_125C.v

#
#write_sdc > dft_report/dft_constraints_for_physical_design_min_area_dft.sdc
#write_sdc > dft_report/dft_constraints_for_physical_design_min_area_dft_CORE65LPSVT_bc_1.05V_125C.sdc
write_sdc > dft_report/dft_constraints_for_physical_design_min_area_dft_CORE65LPSVT_nom_1.05V_125C.sdc
#write_sdc > dft_report/dft_constraints_for_physical_design_min_area_dft_CORE65LPSVT_wc_1.05V_125C.sdc
#
write_script > dft_report/dft_script_min_area_dft_sdc.g
report gates > dft_report/gates_min_area_dft.rep
report dft_registers >dft_report/registers_min_area_dft.rep
report timing > dft_report/dft_timing_report_min_area_dft.rep
report power > dft_report/dft_power_report_min_area_dft.rep
report area > dft_report/dft_area_report_min_area_dft.rep
report summary > dft_report/summary_min_area_dft.rep
#gui_show
