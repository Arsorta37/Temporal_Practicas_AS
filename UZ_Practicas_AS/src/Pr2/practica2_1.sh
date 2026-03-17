#!/bin/bash
#927350, Lorente Pérez, Andrés, T, 1, A
#928700, Llorente Ojuel, Andrés, T, 1, A

echo -n "Introduzca el nombre del fichero: "
read file
if [ -f "$file" ] # Comprobamos que es un archivo
then

    if [ -r "$file" ] # Comprobamos si se puede leer
    then
        r="r"
    else
        r="-"
    fi

    if [ -w "$file" ] # Comprobamos si se puede escribir
    then
        w="w"
    else
        w="-"
    fi

    if [ -x "$file" ] # Comprobamos si es ejecutable
    then
        x="x"
    else
        x="-"
    fi

    echo "Los permisos del archivo $file son: $r$w$x"
else
    echo "$file no existe"
fi