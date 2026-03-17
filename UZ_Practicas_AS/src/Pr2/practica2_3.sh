#!/bin/bash
#927350, Lorente Pérez, Andrés, T, 1, A
#928700, Llorente Ojuel, Andrés, T, 1, A

if [ $# -ne 1 ] # Comprobamos el numero de argumentos
then
    echo "Sintaxis: practica2_3.sh <nombre_archivo>"
else
    if [ -f "$1" ] # Comprobamos que es un archivo
    then
        chmod u+x,g+x "$1" # Aniadimos los permisos
        stat --format=%A "$1" # Imprimimos los permisos
    else
        echo "$1 no existe"
    fi
fi