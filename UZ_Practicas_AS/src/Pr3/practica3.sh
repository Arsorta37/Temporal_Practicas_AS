#!/bin/bash
#927350, Lorente Pérez, Andrés, T, 1, A
#928700, Llorente Ojuel, Andrés, T, 1, A

if [ $EUID -ne 0 ] # Comprobamos que el usuario tiene privilegios de administracion
then
    echo "Este script necesita privilegios de administracion"
    exit 1
fi

if [ $# -ne 2 ] # Comprobamos el número de argumentos
then
    echo "Número incorrecto de párametros"
    exit 0
fi

if [ $1 != "-a" -a $1 != "-s" ] # Comprobamos que el primer argumento sea válido
then
    echo "Opción invalida" >&2
    exit 0
fi

if [ ! -f "$2" -o ! -r "$2" ] # Comprobamos que el archivo existe y se puede leer
then
    echo "El fichero no existe o no se puede leer"
    exit 2
fi

if [ $1 = "-a" ]
then
    fich_log=$(date '+%Y_%m_%d')"_user_provisioning.log"
    if [ ! -f $fich_log ] # Comprobamos que el archivo de log existe
    then
        touch $fich_log # Si no, lo creamos vacío
    fi

    caducidad=$(date -I --date "+30 days")
    OLDIFS=$IFS
    IFS=$',\n'
    cat "$2" | while read usuario contrasenia nombre_completo
    do
        if [ "$usuario" = "" -o "$contrasenia" = "" -o "$nombre_completo" = "" ]
        then
            echo "Campo invalido"
	    continue
        fi

        if cat /etc/passwd | grep -q "$usuario:"
        then # Usamos grep para ver si está en el archivo de usuarios
            echo El usuario "$usuario" ya existe
            echo El usuario "$usuario" ya existe >> "$fich_log"
        else
            useradd -m -k "/etc/skel" -e $caducidad -K UID_MIN=1815 -U "$usuario"
            echo "$usuario:$contrasenia" | chpasswd
            chage -M 30 "$usuario"
            echo "$usuario" ha sido creado
            echo "$usuario" ha sido creado >> "$fich_log"
        fi
	done
    IFS=$OLDIFS

fi

if [ $1 = "-s" ]
then
    if [ ! -d /extra/backup/ ] #Comprobamos si existe el directorio backup
    then
        mkdir -p /extra/backup #Creamos el directorio de backup
    fi

    OLDIFS=$IFS
    IFS=$','
    cat "$2" | while read usuario cosas
    do
        if cat /etc/passwd | grep -q "$usuario:" #Comprobamos si existe el usuario
        then
            tar -cf "/extra/backup/$usuario.tar" -C /home "$usuario" #Hacemos tar

            if [ $? -eq 0 ]; then #Comprobamos si el anterior comando ha salido bien
               userdel -r "$usuario" #Borramos
            fi
        fi
    done
	IFS=$OLDIFS
fi
