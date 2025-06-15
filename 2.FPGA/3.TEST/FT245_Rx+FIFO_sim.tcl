###########################################################
##  Autor:       Christian Diego Cobos Marcos
##  Fecha:       09/06/2025
##  Descripción: ViCON - FT245 RX Interface and Rx FIFO integration sim
###########################################################

# Establecer fichero TOP de simulación.

set_property top FT245 [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Lanzar simulación.

launch_simulation

# Reinicio de la simulación.

restart

###########################################################

# Definición de CLK como reloj con periodo 10ns (100 MHz). Valor inicial -> 0.
add_force {/FT245/CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Inicialización de todas las señales de entrada a 0.
add_force {/FT245/reset}  -radix bin {0 0ns}
add_force {/FT245/DIN}    -radix hex {0 0ns}
add_force {/FT245/RXFn}   -radix bin {1 0ns}
add_force {/FT245/POP_RX} -radix bin {0 0ns}
add_force {/FT245/RDn}    -radix bin {1 0ns}


# Ejecuta la simulación por 100ns para estabilizar señales.
run 100 ns

###########################################################

# Metemos el primer dato para comprobar que llega a la FIFO:

###########################################################

# Simulamos la llegada de datos (RXFn = 0) en wait_for_RXF.
add_force {/FT245/RXFn} -radix bin {0 0ns}

# Dejamos tiempo para que el sincronizador capture la señal de RXFn (2 ciclos de reloj, 20 ns).
run 20 ns

# A este punto, RDn debería haber sido activado automáticamente por la FSM (bajo).

# **Desplazamos DIN 5 ns hacia adelante**, aplicando el primer dato justo después de RDn.
add_force {/FT245/DIN} -radix hex {0 0ns} {1 10ns}

# Dejamos tiempo para la captura del dato y transición a read_1 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_1 a read_2 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_2 a read_3 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Devolvemos RXFn a su estado de reposo (indicando que no hay más datos disponibles).
add_force {/FT245/RXFn} -radix bin {0 0ns} {1 10ns}

# Borramos el dato en DIN con el mismo retraso con el que lo aplicamos con respecto a RDn.
add_force {/FT245/DIN} -radix hex {1 0ns} {0 10ns}

# Deja tiempo suficiente para que el sistema complete la lectura y detecte que no hay más datos (6 ciclos de reloj, 60 ns).
run 60 ns

###########################################################

# Simulamos la llegada de datos (RXFn = 0) en wait_for_RXF.
add_force {/FT245/RXFn} -radix bin {0 0ns}

# Dejamos tiempo para que el sincronizador capture la señal de RXFn (2 ciclos de reloj, 20 ns).
run 20 ns

# A este punto, RDn debería haber sido activado automáticamente por la FSM (bajo).

# **Desplazamos DIN 5 ns hacia adelante**, aplicando el segundo dato justo después de RDn.
add_force {/FT245/DIN} -radix hex {0 0ns} {2 10ns}

# Dejamos tiempo para la captura del dato y transición a read_1 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_1 a read_2 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_2 a read_3 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Devolvemos RXFn a su estado de reposo (indicando que no hay más datos disponibles).
add_force {/FT245/RXFn} -radix bin {0 0ns} {1 10ns}

# Borramos el dato en DIN con el mismo retraso con el que lo aplicamos con respecto a RDn.
add_force {/FT245/DIN} -radix hex {2 0ns} {0 10ns}

run 20 ns

###########################################################

# Simulamos la llegada de datos (RXFn = 0) en wait_for_RXF.
add_force {/FT245/RXFn} -radix bin {0 0ns}

# Dejamos tiempo para que el sincronizador capture la señal de RXFn (2 ciclos de reloj, 20 ns).
run 20 ns

# A este punto, RDn debería haber sido activado automáticamente por la FSM (bajo).

# **Desplazamos DIN 5 ns hacia adelante**, aplicando el segundo dato justo después de RDn.
add_force {/FT245/DIN} -radix hex {0 0ns} {3 10ns}

# Dejamos tiempo para la captura del dato y transición a read_1 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_1 a read_2 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_2 a read_3 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Devolvemos RXFn a su estado de reposo (indicando que no hay más datos disponibles).
add_force {/FT245/RXFn} -radix bin {0 0ns} {1 10ns}

# Borramos el dato en DIN con el mismo retraso con el que lo aplicamos con respecto a RDn.
add_force {/FT245/DIN} -radix hex {3 0ns} {0 10ns}

run 20 ns

###########################################################

# Simulamos la llegada de datos (RXFn = 0) en wait_for_RXF.
add_force {/FT245/RXFn} -radix bin {0 0ns}

# Dejamos tiempo para que el sincronizador capture la señal de RXFn (2 ciclos de reloj, 20 ns).
run 20 ns

# A este punto, RDn debería haber sido activado automáticamente por la FSM (bajo).

# **Desplazamos DIN 5 ns hacia adelante**, aplicando el segundo dato justo después de RDn.
add_force {/FT245/DIN} -radix hex {0 0ns} {4 10ns}

# Dejamos tiempo para la captura del dato y transición a read_1 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_1 a read_2 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_2 a read_3 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Devolvemos RXFn a su estado de reposo (indicando que no hay más datos disponibles).
add_force {/FT245/RXFn} -radix bin {0 0ns} {1 10ns}

# Borramos el dato en DIN con el mismo retraso con el que lo aplicamos con respecto a RDn.
add_force {/FT245/DIN} -radix hex {4 0ns} {0 10ns}

run 20 ns

###########################################################

# Simulamos la llegada de datos (RXFn = 0) en wait_for_RXF.
add_force {/FT245/RXFn} -radix bin {0 0ns}

# Dejamos tiempo para que el sincronizador capture la señal de RXFn (2 ciclos de reloj, 20 ns).
run 20 ns

# A este punto, RDn debería haber sido activado automáticamente por la FSM (bajo).

# **Desplazamos DIN 5 ns hacia adelante**, aplicando el tercer dato justo después de RDn.
add_force {/FT245/DIN} -radix hex {0 0ns} {5 10ns}

# Dejamos tiempo para la captura del dato y transición a read_1 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_1 a read_2 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_2 a read_3 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Devolvemos RXFn a su estado de reposo (indicando que no hay más datos disponibles).
add_force {/FT245/RXFn} -radix bin {0 0ns} {1 10ns}

# Borramos el dato en DIN con el mismo retraso con el que lo aplicamos con respecto a RDn.
add_force {/FT245/DIN} -radix hex {5 0ns} {0 10ns}

run 20 ns

###########################################################

# Extraemos los datos de la FIFO:
add_force {/FT245/POP_RX} {1 0ns} {0 10ns}

run 10 ns

add_force {/FT245/POP_RX} {1 0ns} {0 10ns}

run 10 ns

add_force {/FT245/POP_RX} {1 0ns} {0 10ns}

run 10 ns

add_force {/FT245/POP_RX} {1 0ns} {0 10ns}

run 10 ns

###########################################################

# Volvemos a introducir un dato:

###########################################################

# Simulamos la llegada de datos (RXFn = 0) en wait_for_RXF.
add_force {/FT245/RXFn} -radix bin {0 0ns}

# Dejamos tiempo para que el sincronizador capture la señal de RXFn (2 ciclos de reloj, 20 ns).
run 20 ns

# A este punto, RDn debería haber sido activado automáticamente por la FSM (bajo).

# **Desplazamos DIN 5 ns hacia adelante**, aplicando el tercer dato justo después de RDn.
add_force {/FT245/DIN} -radix hex {0 0ns} {6 10ns}

# Dejamos tiempo para la captura del dato y transición a read_1 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_1 a read_2 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_2 a read_3 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Devolvemos RXFn a su estado de reposo (indicando que no hay más datos disponibles).
add_force {/FT245/RXFn} -radix bin {0 0ns} {1 10ns}

# Borramos el dato en DIN con el mismo retraso con el que lo aplicamos con respecto a RDn.
add_force {/FT245/DIN} -radix hex {6 0ns} {0 10ns}

run 20 ns

###########################################################

set_property top TOP [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]