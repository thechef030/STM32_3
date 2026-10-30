# In Vivado Tcl Console: set spi_role rx (or tx), then source this file.
set root [file normalize [file join [file dirname [info script]] ..]]
if {![info exists spi_role]} {set spi_role rx}
if {$spi_role ni {rx tx}} {error "spi_role must be rx or tx"}
set project_name stm32_spi_$spi_role
set project_dir [file join $root vivado_$spi_role]
if {[llength [get_projects -quiet]]} {error "Close the current project first (File > Close Project)."}
if {[file exists [file join $project_dir $project_name.xpr]]} {
 open_project [file join $project_dir $project_name.xpr]
} else {
 create_project $project_name $project_dir -part xc7s75fgga484-1
 set_property target_language Verilog [current_project]
 add_files -norecurse [glob [file join $root src *.v]]
 add_files -fileset constrs_1 -norecurse [file join $root xdc board_common.xdc]
 if {$spi_role eq "rx"} {
  add_files -fileset constrs_1 -norecurse [file join $root xdc receiver.xdc]
 }
 add_files -fileset sim_1 -norecurse [glob [file join $root sim *.sv]]
 set_property top spi_${spi_role}_top [get_filesets sources_1]
 set_property top tb_spi_system [get_filesets sim_1]
 set_property xsim.simulate.runtime all [get_filesets sim_1]
 update_compile_order -fileset sources_1
 update_compile_order -fileset sim_1
}
puts "SPI role=$spi_role. SCK=PORT A IO00/F8 MOSI=IO01/E8 CS=IO02/A7."
