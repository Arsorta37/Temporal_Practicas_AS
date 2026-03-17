#!/bin/bash
#927350, Lorente Pérez, Andrés, T, 1, A
#928700, Llorente Ojuel, Andrés, T, 1, A

raiz="$(cd;pwd)" # Vamos al directorio raiz del user y asignamos el directorio (mostrandolo)
movidos=0

if ! ls "$raiz"/bin??? # Si no existe un fichero binXXX
then # Lo creamos

	destino="$(mktemp -d "${raiz}/binXXX")"
	echo "Se ha creado el directorio $destino"
else # Ya existe el directorio, buscamos el mas antiguo
	destino="$(stat -c %n,%Y "$raiz"/bin??? | sort -t',' -k2 -n | cut -d',' -f1 )"
fi

echo "Directorio destino de copia: $destino"

for fichero in ./* # Para cada fichero en el directorio actual
do
if [ -f "$fichero" -a -x "$fichero" ] # Comprobamos que sea un fichero y no un directorio

then # Copiamos al destino
	cp "$fichero" "$destino"
	movidos=$((movidos+1))	
fi
done

if [ $movidos -eq 0 ]
then
	echo "No se ha copiado ningun archivo"
else
	echo "Se han copidao $movidos archivos"
fi
