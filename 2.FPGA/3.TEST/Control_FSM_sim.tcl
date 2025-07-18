##########################################################
##  Autor:       Christian Diego Cobos Marcos
##  Fecha:       14/07/2025
##  Descripción: Control FSM
###########################################################

# Establecer fichero TOP de simulación.

set_property top Control_FSM [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Lanzar simulación.

launch_simulation

# Reinicio de la simulación.

restart

###########################################################

# Definición de CLK como reloj con periodo 10ns (100 MHz). Valor inicial -> 0.
add_force {/Control_FSM/CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Inicialización de todas las señales a 0.
add_force {/Control_FSM/RST}         -radix bin {0 0ns}
add_force {/Control_FSM/FIFO_RX_EMPTY} -radix bin {1 0ns}
add_force {/Control_FSM/FIFO_TX_EMPTY} -radix bin {1 0ns}

# Ejecuta la simulación por 100ns para estabilizar señales.
run 100 ns

###########################################################

# Llega un dato a la FIFO de transmisión.

add_force {/Control_FSM/FIFO_TX_EMPTY} -radix bin {0 0ns}

# Ejecuta la simulación por 20 ns para ver resultados.

run 20 ns

###########################################################

# Se va el dato de la FIFO de transmisión.

add_force {/Control_FSM/FIFO_TX_EMPTY} -radix bin {1 0ns}

# Ejecuta la simulación por 20 ns para ver resultados.

run 20 ns

###########################################################

set_property top TOP [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
