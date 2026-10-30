$env:XILINX_VIVADO='C:/AMDDesignTools/2026.1/Vivado'
$env:RDI_APPROOT=$env:XILINX_VIVADO
$env:HDI_APPROOT=$env:XILINX_VIVADO
$env:RDI_PLATFORM='win64'
$env:RDI_OPT_EXT='.o'
$env:RDI_PROG='vivado'
$env:RDI_LIBDIR=$env:XILINX_VIVADO+'/lib/win64.o'
$env:RDI_JAVAROOT='C:/AMDDesignTools/2026.1/tps/win64/jre24.0.2_12'
$env:PATH=$env:RDI_JAVAROOT+'/bin/server;'+$env:RDI_JAVAROOT+'/bin;C:/AMDDesignTools/2026.1/tps/win64/python-3.13.0;'+$env:PATH
$env:RDI_BASEROOT='C:/AMDDesignTools/2026.1'
$env:RDI_BINROOT=$env:XILINX_VIVADO+'/bin'
$env:RDI_DATADIR=$env:XILINX_VIVADO+'/data'
$env:TCL_LIBRARY=$env:XILINX_VIVADO+'/tps/tcl/tcl8.6'
$env:PATH=$env:XILINX_VIVADO+'/lib/win64.o;'+$env:XILINX_VIVADO+'/bin/unwrapped/win64.o;'+$env:XILINX_VIVADO+'/bin;'+$env:PATH
& 'C:/AMDDesignTools/2026.1/Vivado/bin/unwrapped/win64.o/vivado.exe' -mode batch -source scripts/check_synthesis.tcl -log synthesis_check.log -journal synthesis_check.jou
