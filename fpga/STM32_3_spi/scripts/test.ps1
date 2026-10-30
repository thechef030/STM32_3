$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
    $sources = @(Get-ChildItem -LiteralPath src -Filter *.v | ForEach-Object FullName)
    & iverilog -g2012 -Wall -s tb_spi_system -o sim/spi_tests.vvp @sources sim/tb_spi_system.sv
    if ($LASTEXITCODE -ne 0) { throw 'Verilog compile failed' }
    & vvp sim/spi_tests.vvp | Tee-Object -FilePath sim/test_result.txt
    if ($LASTEXITCODE -ne 0) { throw 'SPI simulation failed' }
} finally { Pop-Location }
