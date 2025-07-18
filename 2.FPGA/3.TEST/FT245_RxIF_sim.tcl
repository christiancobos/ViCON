###########################################################
##  Autor:       Christian Diego Cobos Marcos
##  Fecha:       12/01/2024
##  Descripción: EC34 - FT245 Interface Simulation (DIN desplazado en el tiempo).
###########################################################

# Establecer fichero TOP de simulación.

set_property top FT245_RxIF [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Lanzar simulación.

launch_simulation

# Reinicio de la simulación.

restart


###########################################################

# Definición de CLK como reloj con periodo 10ns (100 MHz). Valor inicial -> 0.
add_force {/FT245_RxIF/CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Inicialización de todas las señales a 0.
add_force {/FT245_RxIF/reset} -radix bin {0 0ns}
add_force {/FT245_RxIF/DIN}   -radix hex {0 0ns}
add_force {/FT245_RxIF/rd_en} -radix bin {0 0ns}
add_force {/FT245_RxIF/RXFn}  -radix bin {1 0ns}

# Ejecuta la simulación por 100ns para estabilizar señales.
run 100 ns

###########################################################

# Habilitamos lectura, pasando de idle a wait_for_RXF (un ciclo de reloj, 10 ns).
add_force {/FT245_RxIF/rd_en} -radix bin {1 0ns}

# Deja tiempo suficiente para la transición (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos la llegada de datos (RXFn = 0) en wait_for_RXF.
add_force {/FT245_RxIF/RXFn} -radix bin {0 0ns}

# Dejamos tiempo para que el sincronizador capture la señal de RXFn (2 ciclos de reloj, 20 ns).
run 20 ns

# A este punto, RDn debería haber sido activado automáticamente por la FSM (bajo).

# **Desplazamos DIN 5 ns hacia adelante**, aplicando el primer dato justo después de RDn.
add_force {/FT245_RxIF/DIN} -radix hex {0 0ns} {1 10ns}

# Dejamos tiempo para la captura del dato y transición a read_1 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_1 a read_2 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_2 a read_3 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_3 a wait_for_not_RXF (activación de rd_en).
add_force {/FT245_RxIF/rd_en} -radix bin {1 0ns} {0 10ns}

# Devolvemos RXFn a su estado de reposo (indicando que no hay más datos disponibles).
add_force {/FT245_RxIF/RXFn} -radix bin {0 0ns} {1 10ns}

# Borramos el dato en DIN con el mismo retraso con el que lo aplicamos con respecto a RDn.
add_force {/FT245_RxIF/DIN} -radix hex {1 0ns} {0 10ns}

# Deja tiempo suficiente para que el sistema complete la lectura y detecte que no hay más datos (6 ciclos de reloj, 60 ns).
run 60 ns

###########################################################

# Simulamos la llegada de nuevos datos, forzando la señal RXFn a 0 (espera para leer).
add_force {/FT245_RxIF/RXFn} -radix bin {0 0ns}

# Dejamos tiempo para que el sincronizador capture el estado de RXFn (2 ciclos de reloj, 20 ns).
run 20 ns

# A este punto, RDn debería haberse activado automáticamente por la FSM (bajo).

# **Desplazamos DIN 5 ns hacia adelante**, aplicando el segundo dato justo después de RDn.
add_force {/FT245_RxIF/DIN} -radix hex {0 0ns} {2 10ns}

# Dejamos tiempo para la captura del segundo dato (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_1 a read_2 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_2 a read_3 (un ciclo de reloj, 10 ns).
run 10 ns

###########################################################

# Simulamos el paso de read_3 a idle (cuando se completa la lectura y RXFn vuelve a 1).
add_force {/FT245_RxIF/RXFn} -radix bin {0 0ns} {1 10ns}

# Borramos el dato en DIN para simular que el bus está inactivo.
add_force {/FT245_RxIF/DIN} -radix hex {2 0ns} {0 10ns}

# Dejamos que el sistema vuelva a estado idle y esperamos (10 ciclos de reloj, 100 ns).
run 100 ns

###########################################################

# Simulamos un reset para reiniciar el módulo.
add_force {/FT245_RxIF/reset} -radix bin {1 0ns} {0 10ns}

# Ejecutamos la simulación por 100ns para observar el comportamiento después del reset.
run 100 ns

###########################################################

set_property top TOP [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]