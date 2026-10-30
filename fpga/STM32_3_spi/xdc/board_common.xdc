# Combo II-DLD S75, xc7s75fgga484-1, 50 MHz.
set_property PACKAGE_PIN B6 [get_ports clk_50mhz]
set_property PACKAGE_PIN K4 [get_ports rst_p]
set_property PACKAGE_PIN L4 [get_ports {led[7]}]
set_property PACKAGE_PIN M4 [get_ports {led[6]}]
set_property PACKAGE_PIN M2 [get_ports {led[5]}]
set_property PACKAGE_PIN N7 [get_ports {led[4]}]
set_property PACKAGE_PIN M7 [get_ports {led[3]}]
set_property PACKAGE_PIN M3 [get_ports {led[2]}]
set_property PACKAGE_PIN M1 [get_ports {led[1]}]
set_property PACKAGE_PIN N5 [get_ports {led[0]}]
# Textbook p73: PORT A / BDIO_00=F8, BDIO_01=E8, BDIO_02=A7.
set_property PACKAGE_PIN F8 [get_ports spi_sck]
set_property PACKAGE_PIN E8 [get_ports spi_mosi]
set_property PACKAGE_PIN A7 [get_ports spi_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports *]
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]
set_false_path -from [get_ports rst_p]
# PORT A ENABLE switch OFF => BD_SEL1 low => PI3C3245 /BE active.
