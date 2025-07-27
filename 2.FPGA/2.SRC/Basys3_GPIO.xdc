###########################################################
##  Autor:       Christian Diego Cobos Marcos
##  DNI:         77438323Z
##  Fecha:       17/12/2023
##  Curso:       MSEEI 2023-2024
##  Descripción: Basys3 General Purpose I/O
###########################################################


## 	Switches: Configuración de las entradas. (PIN y estándar eléctrico)

set_property PACKAGE_PIN V17 [get_ports {SW[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[0]}]
set_property PACKAGE_PIN V16 [get_ports {SW[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[1]}]
set_property PACKAGE_PIN W16 [get_ports {SW[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[2]}]
set_property PACKAGE_PIN W17 [get_ports {SW[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[3]}]
set_property PACKAGE_PIN W15 [get_ports {SW[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[4]}]
set_property PACKAGE_PIN V15 [get_ports {SW[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[5]}]
set_property PACKAGE_PIN W14 [get_ports {SW[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[6]}]
set_property PACKAGE_PIN W13 [get_ports {SW[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[7]}]
set_property PACKAGE_PIN V2 [get_ports {SW[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[8]}]
set_property PACKAGE_PIN T3 [get_ports {SW[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[9]}]
set_property PACKAGE_PIN T2 [get_ports {SW[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[10]}]
set_property PACKAGE_PIN R3 [get_ports {SW[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[11]}]
set_property PACKAGE_PIN W2 [get_ports {SW[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[12]}]
set_property PACKAGE_PIN U1 [get_ports {SW[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[13]}]
set_property PACKAGE_PIN T1 [get_ports {SW[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[14]}]
set_property PACKAGE_PIN R2 [get_ports {SW[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[15]}]


## 	LEDs: Configuración de las salidas. (PIN y estándar eléctrico)

set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
set_property PACKAGE_PIN W18 [get_ports {LED[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
set_property PACKAGE_PIN U15 [get_ports {LED[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
set_property PACKAGE_PIN U14 [get_ports {LED[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
set_property PACKAGE_PIN V14 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
set_property PACKAGE_PIN V13 [get_ports {LED[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]
set_property PACKAGE_PIN V3 [get_ports {LED[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
set_property PACKAGE_PIN W3 [get_ports {LED[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
set_property PACKAGE_PIN U3 [get_ports {LED[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
set_property PACKAGE_PIN P3 [get_ports {LED[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]
set_property PACKAGE_PIN N3 [get_ports {LED[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]
set_property PACKAGE_PIN P1 [get_ports {LED[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]
set_property PACKAGE_PIN L1 [get_ports {LED[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]


##  Display 7 segmentos: Configuración de los cátodos. (PIN y estándar eléctrico)

set_property PACKAGE_PIN W7 [get_ports {CAT[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[0]}]
set_property PACKAGE_PIN W6 [get_ports {CAT[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[1]}]
set_property PACKAGE_PIN U8 [get_ports {CAT[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[2]}]
set_property PACKAGE_PIN V8 [get_ports {CAT[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[3]}]
set_property PACKAGE_PIN U5 [get_ports {CAT[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[4]}]
set_property PACKAGE_PIN V5 [get_ports {CAT[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[5]}]
set_property PACKAGE_PIN U7 [get_ports {CAT[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[6]}]
set_property PACKAGE_PIN V7 [get_ports {CAT[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[7]}]

##  Display 7 segmentos: Configuración de los ánodos. (PIN y estándar eléctrico)

set_property PACKAGE_PIN U2 [get_ports {AN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[0]}]
set_property PACKAGE_PIN U4 [get_ports {AN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[1]}]
set_property PACKAGE_PIN V4 [get_ports {AN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[2]}]
set_property PACKAGE_PIN W4 [get_ports {AN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[3]}]

## Botones: Configuración de las entradas. (PIN y estándar eléctrico)

# Configuración del botón izquierdo.
set_property PACKAGE_PIN W19 [get_ports {BTN[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[4]}]

# Configuración del botón inferior.
set_property PACKAGE_PIN U17 [get_ports {BTN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[3]}]

# Configuración del botón derecho.
set_property PACKAGE_PIN T17 [get_ports {BTN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[2]}]

# Configuración del botón superior.
set_property PACKAGE_PIN T18 [get_ports {BTN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[1]}]

# Configuración del botón central.
set_property PACKAGE_PIN U18 [get_ports {BTN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BTN[0]}]

## Configuración de reloj y restricciones de temporización.

set_property IOSTANDARD LVCMOS33 [get_ports CLK]
set_property PACKAGE_PIN W5 [get_ports CLK]
# Restricciones del dominio de reloj
create_clock -period 10.000 -name CLK -waveform {0.000 5.000} [get_ports CLK]

## Configuración ajena a entradas y salidas.
###########################################################
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
###########################################################

## Configuración de señales de datos de FT245
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[0]}]
set_property PACKAGE_PIN A14 [get_ports {DATA[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[1]}]
set_property PACKAGE_PIN A15 [get_ports {DATA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[2]}]
set_property PACKAGE_PIN A16 [get_ports {DATA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[3]}]
set_property PACKAGE_PIN A17 [get_ports {DATA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[4]}]
set_property PACKAGE_PIN B15 [get_ports {DATA[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[5]}]
set_property PACKAGE_PIN C15 [get_ports {DATA[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[6]}]
set_property PACKAGE_PIN B16 [get_ports {DATA[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {DATA[7]}]
set_property PACKAGE_PIN C16 [get_ports {DATA[7]}]

## Configuración de señales de control de FT245
set_property PACKAGE_PIN K17 [get_ports RXFn]
set_property IOSTANDARD LVCMOS33 [get_ports RXFn]
set_property PACKAGE_PIN L17 [get_ports TXEn]
set_property IOSTANDARD LVCMOS33 [get_ports TXEn]
set_property PACKAGE_PIN M18 [get_ports RDn]
set_property IOSTANDARD LVCMOS33 [get_ports RDn]
set_property PACKAGE_PIN M19 [get_ports WRn]
set_property IOSTANDARD LVCMOS33 [get_ports WRn]
set_property PACKAGE_PIN N17 [get_ports SIWUn]
set_property IOSTANDARD LVCMOS33 [get_ports SIWUn]
set_property PACKAGE_PIN P17 [get_ports CLKOUT]
set_property IOSTANDARD LVCMOS33 [get_ports CLKOUT]
set_property PACKAGE_PIN P18 [get_ports OEn]
set_property IOSTANDARD LVCMOS33 [get_ports OEn]
set_property PACKAGE_PIN R18 [get_ports PWRSAVn]
set_property IOSTANDARD LVCMOS33 [get_ports PWRSAVn]

## Configuración de señales de control de MT9V111
set_property PACKAGE_PIN G3 [get_ports SDA]
set_property IOSTANDARD LVCMOS33 [get_ports SDA]
set_property PACKAGE_PIN G2 [get_ports SCL]
set_property IOSTANDARD LVCMOS33 [get_ports SCL]
set_property PACKAGE_PIN H2 [get_ports HREF]
set_property IOSTANDARD LVCMOS33 [get_ports HREF]
set_property PACKAGE_PIN J2 [get_ports VSYNC]
set_property IOSTANDARD LVCMOS33 [get_ports VSYNC]
set_property PACKAGE_PIN K2 [get_ports XCLK]
set_property IOSTANDARD LVCMOS33 [get_ports XCLK]
set_property PACKAGE_PIN J1 [get_ports PCLK]
set_property IOSTANDARD LVCMOS33 [get_ports PCLK]
set_property PACKAGE_PIN K3 [get_ports RSTn]
set_property IOSTANDARD LVCMOS33 [get_ports RSTn]


## Configuración de señales de datos de MT9V111
set_property PACKAGE_PIN L2 [get_ports {CAMERA[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports CAMERA[7]]
set_property PACKAGE_PIN H1 [get_ports {CAMERA[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports CAMERA[6]]
set_property PACKAGE_PIN N2 [get_ports {CAMERA[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports CAMERA[5]]
set_property PACKAGE_PIN N1 [get_ports {CAMERA[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports CAMERA[4]]
set_property PACKAGE_PIN M2 [get_ports {CAMERA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports CAMERA[3]]
set_property PACKAGE_PIN M1 [get_ports {CAMERA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports CAMERA[2]]
set_property PACKAGE_PIN L3 [get_ports {CAMERA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports CAMERA[1]]
set_property PACKAGE_PIN M3 [get_ports {CAMERA[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports CAMERA[0]]
