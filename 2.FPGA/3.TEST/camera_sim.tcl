##########################################################
##  Autor:       Christian Diego Cobos Marcos
##  Fecha:       26/07/2025
##  Descripción: Camera control
###########################################################

# Establecer fichero TOP de simulación.

set_property top camera [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Lanzar simulación.

launch_simulation

# Reinicio de la simulación.

restart

###########################################################
# Solicitud de frame cuando inicia el envío desde la cámara.
###########################################################

# Definición de CLK como reloj con periodo 10ns (100 MHz). Valor inicial -> 0.
add_force {/camera/CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Definición de PIXCLK como reloj con periodo 83.33ns (12 MHz). Valor inicial -> 0.
add_force {/camera/PIXCLK} -radix bin {0 0ns} {1 41.67ns} -repeat_every 83.33ns

# Inicialización de todas las señales a su valor por defecto.
add_force {/camera/reset}         -radix bin {0 0ns}
add_force {/camera/DATA_IN}       -radix hex {0 0ns}
add_force {/camera/FRAME_VALID}   -radix bin {0 0ns}
add_force {/camera/LINE_VALID}    -radix bin {0 0ns}
add_force {/camera/IMAGE_REQUEST} -radix bin {0 0ns}

# Ejecuta la simulación por 250ns para estabilizar señales.
run 250 ns

# Ejecuta la simulación por 41.66ns para coordinar con los flancos de subida.
run 41.66ns

###########################################################

# Inicio de frame junto con request de imagen.
add_force {/camera/IMAGE_REQUEST} -radix bin {1 0ns} {0 10ns}
add_force {/camera/FRAME_VALID}   -radix bin {1 0ns}

run 83.33ns

###########################################################

# Inicio de linea y primer dato.
add_force {/camera/LINE_VALID}    -radix bin {1 0ns}
add_force {/camera/DATA_IN}       -radix hex {1 0ns}

run 83.33ns

###########################################################

# Segundo dato.
add_force {/camera/DATA_IN}       -radix hex {2 0ns}

run 83.33ns

###########################################################

# Fin de línea.
add_force {/camera/LINE_VALID}    -radix bin {0 0ns}
add_force {/camera/DATA_IN}       -radix hex {0 0ns}

run 83.33ns

###########################################################

# Inicio de línea y tercer dato.
add_force {/camera/LINE_VALID}    -radix bin {1 0ns}
add_force {/camera/DATA_IN}       -radix hex {3 0ns}

run 83.33ns

###########################################################

# Cuarto dato.
add_force {/camera/DATA_IN}       -radix hex {4 0ns}

run 83.33ns

###########################################################

# Fin de línea.
add_force {/camera/LINE_VALID}    -radix bin {0 0ns}
add_force {/camera/DATA_IN}       -radix hex {0 0ns}

run 83.33ns

###########################################################

# Fin de frame.
add_force {/camera/FRAME_VALID}    -radix bin {0 0ns}

run 250ns


###########################################################
# Solicitud de frame antes de que inicie el envío desde la cámara.
###########################################################

# Request de imagen.
add_force {/camera/IMAGE_REQUEST} -radix bin {1 0ns} {0 10ns}

run 83.33ns

###########################################################

# Inicio de frame.
add_force {/camera/FRAME_VALID}   -radix bin {1 0ns}

run 83.33ns

###########################################################

# Inicio de linea y primer dato.
add_force {/camera/LINE_VALID}    -radix bin {1 0ns}
add_force {/camera/DATA_IN}       -radix hex {1 0ns}

run 83.33ns

###########################################################

# Segundo dato.
add_force {/camera/DATA_IN}       -radix hex {2 0ns}

run 83.33ns

###########################################################

# Fin de línea.
add_force {/camera/LINE_VALID}    -radix bin {0 0ns}
add_force {/camera/DATA_IN}       -radix hex {0 0ns}

run 83.33ns

###########################################################

# Inicio de línea y tercer dato.
add_force {/camera/LINE_VALID}    -radix bin {1 0ns}
add_force {/camera/DATA_IN}       -radix hex {3 0ns}

run 83.33ns

###########################################################

# Cuarto dato.
add_force {/camera/DATA_IN}       -radix hex {4 0ns}

run 83.33ns

###########################################################

# Fin de línea.
add_force {/camera/LINE_VALID}    -radix bin {0 0ns}
add_force {/camera/DATA_IN}       -radix hex {0 0ns}

run 83.33ns

###########################################################

# Fin de frame.
add_force {/camera/FRAME_VALID}    -radix bin {0 0ns}

run 250ns

###########################################################

# Solicitud de frame después de que inicie el envío desde la cámara.

###########################################################

# Inicio de frame.
add_force {/camera/FRAME_VALID}   -radix bin {1 0ns}

run 83.33ns

###########################################################

# Inicio de linea y primer dato.
add_force {/camera/LINE_VALID}    -radix bin {1 0ns}
add_force {/camera/DATA_IN}       -radix hex {1 0ns}

run 83.33ns

###########################################################

# Request de imagen.
add_force {/camera/IMAGE_REQUEST} -radix bin {1 0ns} {0 10ns}

run 83.33ns

###########################################################

# Segundo dato.
add_force {/camera/DATA_IN}       -radix hex {2 0ns}

run 83.33ns

###########################################################

# Fin de línea.
add_force {/camera/LINE_VALID}    -radix bin {0 0ns}
add_force {/camera/DATA_IN}       -radix hex {0 0ns}

run 83.33ns

###########################################################

# Inicio de línea y tercer dato.
add_force {/camera/LINE_VALID}    -radix bin {1 0ns}
add_force {/camera/DATA_IN}       -radix hex {3 0ns}

run 83.33ns

###########################################################

# Cuarto dato.
add_force {/camera/DATA_IN}       -radix hex {4 0ns}

run 83.33ns

###########################################################

# Fin de línea.
add_force {/camera/LINE_VALID}    -radix bin {0 0ns}
add_force {/camera/DATA_IN}       -radix hex {0 0ns}

run 83.33ns

###########################################################

# Fin de frame.
add_force {/camera/FRAME_VALID}    -radix bin {0 0ns}

run 83.33ns

###########################################################

# Inicio de frame.
add_force {/camera/FRAME_VALID}   -radix bin {1 0ns}

run 83.33ns

###########################################################

# Inicio de linea y primer dato.
add_force {/camera/LINE_VALID}    -radix bin {1 0ns}
add_force {/camera/DATA_IN}       -radix hex {1 0ns}

run 83.33ns

###########################################################

# Segundo dato.
add_force {/camera/DATA_IN}       -radix hex {2 0ns}

run 83.33ns

###########################################################

# Fin de línea.
add_force {/camera/LINE_VALID}    -radix bin {0 0ns}
add_force {/camera/DATA_IN}       -radix hex {0 0ns}

run 83.33ns

###########################################################

# Inicio de línea y tercer dato.
add_force {/camera/LINE_VALID}    -radix bin {1 0ns}
add_force {/camera/DATA_IN}       -radix hex {3 0ns}

run 83.33ns

###########################################################

# Cuarto dato.
add_force {/camera/DATA_IN}       -radix hex {4 0ns}

run 83.33ns

###########################################################

# Fin de línea.
add_force {/camera/LINE_VALID}    -radix bin {0 0ns}
add_force {/camera/DATA_IN}       -radix hex {0 0ns}

run 83.33ns

###########################################################

# Fin de frame.
add_force {/camera/FRAME_VALID}    -radix bin {0 0ns}

run 250ns

###########################################################

# Prueba de reset del módulo

###########################################################

# Inicio de frame.
add_force {/camera/FRAME_VALID}   -radix bin {1 0ns}

# Request de imagen.
add_force {/camera/IMAGE_REQUEST} -radix bin {1 0ns} {0 10ns}

run 83.33ns

###########################################################

# Inicio de linea y primer dato.
add_force {/camera/LINE_VALID}    -radix bin {1 0ns}
add_force {/camera/DATA_IN}       -radix hex {1 0ns}

run 83.33ns

###########################################################

# Reset del módulo.
add_force {/camera/reset}          -radix bin {1 0ns} {0 10ns}
add_force {/camera/LINE_VALID}     -radix bin {0 0ns}
add_force {/camera/FRAME_VALID}    -radix bin {0 0ns}
add_force {/camera/DATA_IN}        -radix hex {0 0ns}

run 20ns

