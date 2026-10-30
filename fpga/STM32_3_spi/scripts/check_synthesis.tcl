set root [file normalize [file join [file dirname [info script]] ..]]
file mkdir [file join $root validation]
foreach role {rx tx} {
 create_project -in_memory -part xc7s75fgga484-1
 read_verilog [glob [file join $root src *.v]]
 read_xdc [file join $root xdc board_common.xdc]
 if {$role eq "rx"} {read_xdc [file join $root xdc receiver.xdc]}
 synth_design -top spi_${role}_top -part xc7s75fgga484-1
 report_utilization -file [file join $root validation ${role}_utilization.rpt]
 report_drc -file [file join $root validation ${role}_drc.rpt]
 puts "SYNTHESIS_PASS $role"
 close_project
}
