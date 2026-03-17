#!/bin/bash
#927350, Lorente Pérez, Andrés, T, 1, A
#928700, Llorente Ojuel, Andrés, T, 1, A

echo -n "Introduzca el nombre de un directorio: "
read dir
if [ -d "$dir" ]
then

    numFiles=0
    numDirs=0

    for file in $dir/*  # Se usa * en vez de ls por los espacios
    do
        if [ -f "$file" ]
        then
            numFiles=$(( $numFiles + 1 )) # Aumentamos el contador de archivos

        elif [ -d "$file" ]
        then
            numDirs=$(( $numDirs + 1 )) # Aumentamos el contador de directorios
        fi
    done

    echo "El numero de ficheros y directorios en $dir es de $numFiles y $numDirs, respectivamente"
else
    echo "$dir no es un directorio"
fi