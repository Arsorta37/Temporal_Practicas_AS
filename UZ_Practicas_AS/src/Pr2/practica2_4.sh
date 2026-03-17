#!/bin/bash
#927350, Lorente Pérez, Andrés, T, 1, A
#928700, Llorente Ojuel, Andrés, T, 1, A

echo "Introduzca una tecla: "
read caracter
case "$caracter" in
	[a-zA-Z]*)
		echo "$caracter es una letra" ;;
	[0-9]*)
		echo "$caracter es un número" ;;
	*)
		echo "$caracter es un carácter especial" ;;
esac
