# Reinicio
restart
# Lanzar simulación
#launch_simulation

# Reloj de 100 MHz
add_force {/TOP/CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Inicializar señales
add_force {/TOP/SW}   -radix hex {0 0ns}
add_force {/TOP/BTN}  -radix hex {0 0ns}
add_force {/TOP/DATA} -radix hex {ZZ 0ns} ;# Z por ser inout
add_force {/TOP/RXFn} -radix bin {1 0ns}
add_force {/TOP/TXEn} -radix bin {1 0ns}

# Esperar estabilización
run 500 ns

#########################################
# Simulación de recepción de dato 0x07
#########################################

# -------------------------------
# Simulación de recepción: PC envía 0x12
# -------------------------------
add_force {/TOP/RXFn} -radix bin {0 0ns}
run 40 ns

# PC pone el dato
add_force {/TOP/DATA} -radix hex {7 0ns} -cancel 30ns
run 30 ns

add_force {/TOP/RXFn} -radix bin {1 0ns}

# -------------------------------
# Tiempo de procesado
# -------------------------------

run 50 ns

# -------------------------------
# Simulación de transmisión: FPGA responde con 0x12
# -------------------------------

# FTDI indica que puede recibir
add_force {/TOP/TXEn} -radix bin {0 0ns} {1 90ns}
run 100 ns


#########################################
# Segundo dato: 0x12
#########################################

# -------------------------------
# Simulación de recepción: PC envía 0x12
# -------------------------------
add_force {/TOP/RXFn} -radix bin {0 0ns}
run 40 ns

# PC pone el dato
add_force {/TOP/DATA} -radix hex {12 0ns} -cancel 30ns
run 30 ns

add_force {/TOP/RXFn} -radix bin {1 0ns}

# -------------------------------
# Tiempo de procesado
# -------------------------------

run 50 ns

# -------------------------------
# Simulación de transmisión: FPGA responde con 0x12
# -------------------------------

# FTDI indica que puede recibir
add_force {/TOP/TXEn} -radix bin {0 0ns} {1 90ns}
run 100 ns

