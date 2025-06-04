###########################################################
##  Autor:       Christian Diego Cobos Marcos
##  DNI:         77438323Z
##  Fecha:       04/06/2025
##  Curso:       MSEEI 2024-2025
##  Descripción: ViCON - FIFO memory
###########################################################

# Para esta simulación se ha configurado B = 2

###########################################################

# Establecer fichero TOP de simulación.
set_property top FIFO [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Lanzar simulación.

launch_simulation

# Reinicio de la simulación.
restart

###########################################################

# Definición de CLK como reloj con periodo 10ns. (100 MHz). Valor inicial -> 0.
add_force {/FIFO/CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Inicialización de todas las señales a 0.
add_force {/FIFO/RST}   -radix hex {0 0ns}
add_force {/FIFO/DIN}   -radix hex {0 0ns}
add_force {/FIFO/PUSH}  -radix hex {0 0ns}
add_force {/FIFO/POP}   -radix hex {0 0ns}

# Continúa la simulación 100ns.
run 100 ns

###########################################################

# Insertar un dato con FIFO vacía.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {1 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Insertar un dato nuevo.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {2 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Insertar un dato nuevo.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {3 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Insertar un dato nuevo, llenando la FIFO.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {4 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Insertar un dato nuevo, con la FIFO llena.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {5 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Leemos un dato con la FIFO llena.
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Leemos un dato.
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Leemos un dato.
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Leemos un dato y vaciamos la FIFO.
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Leemos un dato con la FIFO vacía.
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Mostraremos ahora el funcionamiento circular de la FIFO.

# Insertar un dato nuevo.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {5 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

# Insertar un dato nuevo.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {6 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

# Insertar un dato nuevo.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {7 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

# Leemos un dato.
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

# Leemos un dato.
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

# Insertar un dato nuevo.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {8 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

# Insertar un dato nuevo.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {9 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

# Insertar un dato nuevo.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {A 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Push y pop simultáneo con FIFO llena.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {B 0ns} {0 10ns}
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

# Push y pop simultáneo con FIFO media justo en el flanco de subida de reloj.
add_force {/FIFO/PUSH}   -radix hex {0 0ns} {1 10ns} {0 20ns}
add_force {/FIFO/DIN}    -radix hex {B 0ns} {0 20ns}
add_force {/FIFO/POP}    -radix hex {0 0ns} {1 10ns} {0 20ns}

# Continúa la simulación 20ns.
run 40 ns

###########################################################

# Vaciamos FIFO.
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}
run 20 ns
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}
run 20 ns
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}
run 20 ns
add_force {/FIFO/POP}    -radix hex {1 0ns} {0 10ns}
run 20 ns

# Push y pop simultáneo con FIFO vacía.
add_force {/FIFO/PUSH}   -radix hex {0 0ns} {1 10ns} {0 20ns}
add_force {/FIFO/DIN}    -radix hex {C 0ns} {0 20ns}
add_force {/FIFO/POP}    -radix hex {0 0ns} {1 10ns} {0 20ns}

# Continúa la simulación 40ns.
run 40 ns

###########################################################

# Reseteamos.
add_force {/FIFO/RST}    -radix hex {1 0ns} {0 10ns}

# Continúa la simulación 40ns.
run 40 ns

# Añadimos un dato para comprobar que vuelve al estado inicial.
add_force {/FIFO/PUSH}   -radix hex {1 0ns} {0 10ns}
add_force {/FIFO/DIN}    -radix hex {2 0ns} {0 10ns}

# Continúa la simulación 20ns.
run 20 ns

###########################################################

set_property top TOP [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
