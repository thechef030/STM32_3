# USB-to-Serial TX, not RS232 DB9. Receiver project only.
set_property PACKAGE_PIN F6 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]
set_property PULLUP true [get_ports spi_cs_n]
set_property PULLDOWN true [get_ports {spi_sck spi_mosi}]
# Asynchronous inputs terminate at explicit two-stage synchronizers.
set_false_path -from [get_ports {spi_sck spi_mosi spi_cs_n}]
