#!/bin/bash
#927350, Lorente Pérez, Andrés, T, 1, A
#928700, Llorente Ojuel, Andrés, T, 1, A

for parametro in "$@" # Listamos por parametros
do
	if [ -f "$parametro" ] # ¿El parámetro es un fichero?
	then
		more -e $parametro # Si lo es, ejecutamos: more -e <parametro>
	else
		echo "$parametro no es un fichero"
	fi
done
