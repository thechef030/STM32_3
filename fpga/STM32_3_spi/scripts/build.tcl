if {$argc != 1} {error "Usage: vivado -mode batch -source scripts/build.tcl -tclargs rx|tx"}
set spi_role [lindex $argv 0]
source [file join [file dirname [info script]] create_project.tcl]
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {error "Bitstream build failed"}
open_run impl_1
report_timing_summary -file [file join $project_dir timing.rpt]
report_drc -file [file join $project_dir drc.rpt]
report_io -file [file join $project_dir pins.rpt]
