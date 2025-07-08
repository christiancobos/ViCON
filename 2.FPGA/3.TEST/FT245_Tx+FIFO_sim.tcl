###########################################################
##  Autor:       Christian Diego Cobos Marcos
##  Fecha:       22/06/2025
##  Descripción: ViCON - FT245 TX Interface and TX FIFO integration sim
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
add_force {/FT245/reset}   -radix bin {0 0ns}
add_force {/FT245/TXEn}    -radix bin {1 0ns}
add_force {/FT245/DATA_tx} -radix hex {0 0ns}
add_force {/FT245/PUSH_tx} -radix bin {0 0ns}
add_force {/FT245/mode}    -radix bin {1 0ns}

add_force {/FT245/RXFn}    -radix bin {1 0ns}
add_force {/FT245/POP_RX}  -radix bin {0 0ns}

# Ejecuta la simulación por 100ns para estabilizar señales.
run 100 ns

###########################################################

# Mandamos un primer dato a la FIFO para comprobar que llega y se puede enviar.

add_force {/FT245/DATA_tx} -radix hex {1 0ns}
add_force {/FT245/PUSH_tx} -radix bin {1 0ns}

run 10 ns

# Se deja de enviar el dato a la FIFO.
add_force {/FT245/DATA_tx} -radix hex {0 0ns}
add_force {/FT245/PUSH_tx} -radix bin {0 0ns}

# Iniciamos el proceso de envío de datos FT245:
run 10 ns

# Paso de wait_for_TXE a output_data.
add_force {/FT245/TXEn} -radix bin {0 0ns}

# Continúa la simulación 30ns.
run 30 ns

# Paso de output_data a write_1.

# Continúa la simulación 10ns.
run 10 ns

# Paso de write_1 a write_2.

# Continúa la simulación 10ns.
run 10 ns


# Paso de write_2 a write_3.

# Devolvemos TXEn a su estado de reposo
add_force {/FT245/TXEn} -radix bin {1 0ns}

# Continúa la simulación 10ns.
run 10 ns

# Paso de write_3 a idle y tiempo de reposo.

# Continúa la simulación 30ns.
run 30 ns

###########################################################

# Se envían múltiples datos a la FIFO para comprobar la integración con varios datos en la FIFO.

# Mandamos un segundo dato a la FIFO para comprobar que llega y se puede enviar.

add_force {/FT245/DATA_tx} -radix hex {2 0ns}
add_force {/FT245/PUSH_tx} -radix bin {1 0ns}

run 10 ns

# Se deja de enviar el dato a la FIFO.
add_force {/FT245/DATA_tx} -radix hex {0 0ns}
add_force {/FT245/PUSH_tx} -radix bin {0 0ns}

# Iniciamos el proceso de envío de datos FT245:
run 10 ns

# Paso de wait_for_TXE a output_data.
add_force {/FT245/TXEn} -radix bin {0 0ns}

# Mandamos un tercer dato a la FIFO para comprobar que llega y se puede enviar.

add_force {/FT245/DATA_tx} -radix hex {3 0ns}
add_force {/FT245/PUSH_tx} -radix bin {1 0ns}

# Continúa la simulación 10ns.
run 10 ns

# Se deja de enviar el dato a la FIFO.
add_force {/FT245/DATA_tx} -radix hex {0 0ns}
add_force {/FT245/PUSH_tx} -radix bin {0 0ns}

# Continúa la simulación 10ns.
run 10 ns

# Mandamos un cuarto dato a la FIFO para comprobar que llega y se puede enviar.

add_force {/FT245/DATA_tx} -radix hex {4 0ns}
add_force {/FT245/PUSH_tx} -radix bin {1 0ns}

# Continúa la simulación 10ns.
run 10 ns

# Paso de output_data a write_1.

# Se deja de enviar el dato a la FIFO.
add_force {/FT245/DATA_tx} -radix hex {0 0ns}
add_force {/FT245/PUSH_tx} -radix bin {0 0ns}

# Continúa la simulación 10ns.
run 10 ns

# Paso de write_1 a write_2.

# Continúa la simulación 10ns.
run 10 ns


# Paso de write_2 a write_3.

# Devolvemos TXEn a su estado de reposo
add_force {/FT245/TXEn} -radix bin {1 0ns}

# Continúa la simulación 10ns.
run 10 ns

# Paso de write_3 a idle y tiempo de reposo.

# Continúa la simulación 30ns.
run 30 ns

#############################################################

# Iniciamos el proceso de envío de datos FT245:
run 10 ns

# Paso de wait_for_TXE a output_data.
add_force {/FT245/TXEn} -radix bin {0 0ns}

# Continúa la simulación 30ns.
run 30 ns

# Paso de output_data a write_1.

# Continúa la simulación 10ns.
run 10 ns

# Paso de write_1 a write_2.

# Continúa la simulación 10ns.
run 10 ns


# Paso de write_2 a write_3.

# Devolvemos TXEn a su estado de reposo
add_force {/FT245/TXEn} -radix bin {1 0ns}

# Continúa la simulación 10ns.
run 10 ns

# Paso de write_3 a idle y tiempo de reposo.

# Continúa la simulación 30ns.
run 30 ns

##############################################################

# Iniciamos el proceso de envío de datos FT245:
run 10 ns

# Paso de wait_for_TXE a output_data.
add_force {/FT245/TXEn} -radix bin {0 0ns}

# Continúa la simulación 30ns.
run 30 ns

# Paso de output_data a write_1.

# Continúa la simulación 10ns.
run 10 ns

# Paso de write_1 a write_2.

# Continúa la simulación 10ns.
run 10 ns


# Paso de write_2 a write_3.

# Devolvemos TXEn a su estado de reposo
add_force {/FT245/TXEn} -radix bin {1 0ns}

# Continúa la simulación 10ns.
run 10 ns

# Paso de write_3 a idle y tiempo de reposo.

# Continúa la simulación 30ns.
run 30 ns
