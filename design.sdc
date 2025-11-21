create_clock -name clock -period 7.1 [get_ports clock]
set_clock_transition -rise 2 [get_clocks clock]
set_clock_transition -fall 2 [get_clocks clock]
set_clock_uncertainty -setup 2 [get_clocks clock]
set_input_transition 2 [get_ports reset]
set_load 1 [get_ports zero]



