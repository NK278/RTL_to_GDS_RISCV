file mkdir sta_after_synthesis_bc/reports
set report_dir sta_after_synthesis_bc/reports

read_lib CORE65LPSVT_bc_1.05V_125C.lib
#read_verilog /home/mrinank22305/Desktop/Processor/reports_bc/place_and_route/netlist/bc.v
#read_verilog /home/mrinank22305/Desktop/Processor/bc_optimized.v
read_verilog bc_optimizedd.v

set_top_module PROCESSOR

#read_sdc design.sdc
read_sdc /home/mrinank22305/Desktop/Processor/dft_report/dft_constraints_for_physical_design_min_area_dft_CORE65LPSVT_bc_1.05V_125C.sdc

report_timing -retime path_slew_propagation -max_path 50 -nworst 50 -path_type full_clock > $report_dir/PBA_best_time_sta.rpt
check_timing > $report_dir/check_timing_best_time_sta.rpt
report_timing > $report_dir/timing_report_best_time_sta.rpt
report_analysis_coverage > $report_dir/analysis_coverage_best_time_sta.rpt
report_analysis_summary > $report_dir/analysis_summary_best_time_sta.rpt
#report_annotated_parasitics > $report_dir/annotated_best_time_sta.rpt
report_clocks > $report_dir/clocks_best_time_sta.rpt
report_case_analysis > $report_dir/case_analysis_best_time_sta.rpt
report_constraints -all_violators > $report_dir/allviolations_best_time_sta.rpt
