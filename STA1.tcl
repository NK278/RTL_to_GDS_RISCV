file mkdir sta_after_synthesis/reports
set report_dir sta_after_synthesis/reports

read_lib slow.lib
read_verilog /home/mrinank22305/Desktop/Processor/output/synthesized_netlist.v

set_top_module PROCESSOR
setDesignMode -process 65
read_sdc design.sdc


report_timing -late -early > $report_dir/GBA.rpt

report_timing -late -early -max_paths 50 -retime path_slew_propagation > $report_dir/timing_report_besttiming_PBA.rpt

#report_analysis_coverage > /home/mrinank22305/Desktop/2.RCA/RCA_4bit_65nm_CORE65LPHVT/4.STA1/sta_after_synthesis/analysis_coverage_besttiming.rpt
report_analysis_coverage > $report_dir/analysis_coverage_best_time_sta.rpt

report_analysis_summary > $report_dir/analysis_summary_besttiming.rpt

report_clocks > $report_dir/clocks_besttiming.rpt

report_case_analysis > $report_dir/case_analysis_besttiming.rpt

report_constraints -all_violators > $report_dir/allviolations_besttiming.rpt
