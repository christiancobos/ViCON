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

# Inicialización de todas las señales a sus valores iniciales.
add_force {/Control_FSM/RST}           -radix bin {0  0ns}
add_force {/Control_FSM/FIFO_RX_EMPTY} -radix bin {1  0ns}
add_force {/Control_FSM/FIFO_TX_EMPTY} -radix bin {1  0ns}
add_force {/Control_FSM/FIFO_RX_VALUE} -radix hex {0  0ns}
add_force {/Control_FSM/FRAME_END}     -radix bin {0  0ns}

# Ejecuta la simulación por 100ns para estabilizar señales.
run 100 ns

# Ejecuta la simulación por 5ns para que las señales comiencen en flanco de subida.
run 5ns

###########################################################

# Llega un dato correcto a la FIFO de recepción.

add_force {/Control_FSM/FIFO_RX_EMPTY} -radix bin {0  0ns} {1 10ns}
add_force {/Control_FSM/FIFO_RX_VALUE} -radix hex {A5 0ns} {0 10ns}

# Ejecuta la simulación por 20 ns para ver resultados.

run 20 ns

###########################################################

# Llegada de datos a la fifo de transmisión.
add_force {/Control_FSM/FIFO_TX_EMPTY} -radix bin {0 0ns}

run 60 ns

###########################################################

# Se termina la recepción de frame
add_force {/Control_FSM/FRAME_END}     -radix bin {1  0ns} {0  10ns}
run 10ns

###########################################################

# Se va el último dato de la FIFO de transmisión.

add_force {/Control_FSM/FIFO_TX_EMPTY} -radix bin {1 0ns}

# Ejecuta la simulación por 20 ns para ver resultados.

run 20 ns

###########################################################

# Llega un dato incorrecto a la FIFO de recepción.

add_force {/Control_FSM/FIFO_RX_EMPTY} -radix bin {0  0ns} {1 10ns}
add_force {/Control_FSM/FIFO_RX_VALUE} -radix hex {12 0ns} {0 10ns}

run 20 ns

###########################################################

# Llega un dato correcto a la FIFO de recepción.

add_force {/Control_FSM/FIFO_RX_EMPTY} -radix bin {0  0ns} {1 10ns}
add_force {/Control_FSM/FIFO_RX_VALUE} -radix hex {A5 0ns} {0 10ns}

# Ejecuta la simulación por 20 ns para ver resultados.

run 20 ns

###########################################################

# Llegada de datos a la fifo de transmisión.
add_force {/Control_FSM/FIFO_TX_EMPTY} -radix bin {0 0ns}

run 60 ns

###########################################################

# Reset de la FSM.
add_force {/Control_FSM/RST}           -radix bin {1 0ns} {0 10ns}

run 20ns

###########################################################

set_property top TOP [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
