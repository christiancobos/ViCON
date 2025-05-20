###########################################################
##  Autor:       Christian Diego Cobos Marcos
##  DNI:         77438323Z
##  Fecha:       12/01/2024
##  Curso:       MSEEI 2023-2024
##  Descripción: EC34 - FT245 Interface Simulation.
###########################################################

# Establecer fichero TOP de simulación.

set_property top FT245_TxIF [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Lanzar simulación.

launch_simulation

# Reinicio de la simulación.

restart

###########################################################

# Definición de CLK como reloj con periodo 10ns. (100 MHz). Valor inicial -> 0.
add_force {/FT245_TxIF/CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Inicialización de todas las señales a 0.
add_force {/FT245_TxIF/reset} -radix bin {0 0ns}
add_force {/FT245_TxIF/DIN}   -radix hex {0 0ns}
add_force {/FT245_TxIF/wr_en} -radix bin {0 0ns}
add_force {/FT245_TxIF/TXEn}  -radix bin {1 0ns}

# Continúa la simulación 100ns.
run 100 ns

###########################################################

# Paso de idle a wait_for_TXE.
add_force {/FT245_TxIF/wr_en} -radix bin {1 0ns} {0 10ns} 

# Continúa la simulación 10ns.
run 10 ns

###########################################################

# Paso de wait_for_TXE a output_data.
add_force {/FT245_TxIF/TXEn} -radix bin {0 0ns}

# Añadimos primer dato.
add_force {/FT245_TxIF/DIN} -radix hex {1 0ns}

# Continúa la simulación 30ns.
run 30 ns

###########################################################

# Paso de output_data a write_1.

# Continúa la simulación 10ns.
run 10 ns

###########################################################

# Paso de write_1 a write_2.

# Borramos primer dato.
add_force {/FT245_TxIF/DIN} -radix hex {0 0ns}

# Continúa la simulación 10ns.
run 10 ns

###########################################################

# Paso de write_2 a write_3.

# Devolvemos TXEn a su estado de reposo
add_force {/FT245_TxIF/TXEn} -radix bin {1 0ns}

# Continúa la simulación 10ns.
run 10 ns

###########################################################

# Paso de write_3 a idle y tiempo de reposo.

# Continúa la simulación 30ns.
run 30 ns

###########################################################

# Paso de idle a wait_for_TXE. Mantenemos wr_en activo para hacer dos ciclos de envío seguidos.
add_force {/FT245_TxIF/wr_en} -radix bin {1 0ns}

# Continúa la simulación 10ns.
run 10 ns

###########################################################

# Paso de wait_for_TXE a output_data.
add_force {/FT245_TxIF/TXEn} -radix bin {0 0ns}

# Añadimos segundo dato.
add_force {/FT245_TxIF/DIN} -radix hex {3 0ns}

# Continúa la simulación 30ns.
run 30 ns

###########################################################

# Paso de output_data a write_1.

# Continúa la simulación 10ns.
run 10 ns

###########################################################

# Paso de write_1 a write_2.

# Borramos segundo dato.
add_force {/FT245_TxIF/DIN} -radix hex {0 0ns}

# Continúa la simulación 10ns.
run 10 ns

###########################################################

# Paso de write_2 a write_3.

# Devolvemos TXEn a su estado de reposo
add_force {/FT245_TxIF/TXEn} -radix bin {1 0ns}

# Continúa la simulación 50ns. (tiempo de reposo)
run 50 ns

###########################################################

# Paso de wait_for_TXE a output_data.
add_force {/FT245_TxIF/TXEn} -radix bin {0 0ns}

# Añadimos segundo dato.
add_force {/FT245_TxIF/DIN} -radix hex {2 0ns}

# Continúa la simulación 30ns.
run 30 ns

###########################################################

# Paso de output_data a write_1.

# Continúa la simulación 10ns.
run 10 ns

###########################################################

# Paso de write_1 a write_2.

# Borramos segundo dato.
add_force {/FT245_TxIF/DIN} -radix hex {0 0ns}

# Continúa la simulación 10ns.
run 10 ns

###########################################################

# Paso de write_2 a write_3.

# Devolvemos TXEn a su estado de reposo
add_force {/FT245_TxIF/TXEn} -radix bin {1 0ns}

# Continúa la simulación 10ns.
run 10 ns

###########################################################

# Paso de write_3 a idle.
add_force {/FT245_TxIF/wr_en} -radix bin {0 0ns}

# Continúa la simulación 100ns.
run 100 ns

###########################################################

# reset
add_force {/FT245_TxIF/reset} -radix bin {1 0ns} {0 10ns}

# Continúa la simulación 100ns.
run 100 ns

###########################################################

set_property top TOP [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
