file mkdir sta_after_synthesis/reports
set report_dir sta_after_synthesis/reports

read_lib CORE65LPHVT_nom_1.05V_125C.lib
read_verilog /home/harshit22210/Desktop/64BIT/output/synthesized_netlist.v

set_top_module array64_signed

read_sdc design.sdc

report_timing -retime path_slew_propagation -max_path 50 -nworst 50 -path_type full_clock > $report_dir/PBA_best_time_sta.rpt
check_timing > $report_dir/check_timing_best_time_sta.rpt
report_timing > $report_dir/timing_report_best_time_sta.rpt
report_analysis_coverage > $report_dir/analysis_coverage_best_time_sta.rpt
report_analysis_summary > $report_dir/analysis_summary_best_time_sta.rpt
#report_annotated_parasitics > $report_dir/annotated_best_time_sta.rpt
report_clocks > $report_dir/clocks_best_time_sta.rpt
report_case_analysis > $report_dir/case_analysis_best_time_sta.rpt
report_constraints -all_violators > $report_dir/allviolations_best_time_sta.rpt
