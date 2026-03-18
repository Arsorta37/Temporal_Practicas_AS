#!/bin/bash
#927350, Lorente Pérez, Andrés, T, 1, A
#928700, Llorente Ojuel, Andrés, T, 1, A

if [ $EUID -ne 0 ] # Comprobamos que el usuario tiene privilegios de administracion
then
    echo "Este script necesita privilegios de administracion"
    exit 1
fi

if [ $# -ne 3 ] # Comprobamos el número de argumentos
then
    echo "Número incorrecto de párametros"
    exit 0
fi

if [ $1 != "-a" -a $1 != "-s" ] # Comprobamos que el primer argumento sea válido
then
    echo "Opción invalida" >&2
    exit 0
fi

if [ ! -f "$2" -o ! -r "$2" ] # Comprobamos que el fichero_usuarios existe y se puede leer
then
    echo "El fichero $2 no existe o no se puede leer"
    exit 2
fi

if [ ! -f "$3" -o ! -r "$3" ] # Comprobamos que el fichero_máquinas existe y se puede leer
then
    echo "El fichero $3 no existe o no se puede leer"
    exit 2
fi

OLDIFS=$IFS
IFS=$',\n'
if [ $1 = "-a" ]  #Si se usa el parámetro "-a"
then
    fich_log=$(date '+%Y_%m_%d')"_user_provisioning.log"
    if [ ! -f $fich_log ] # Comprobamos que el archivo de log existe
    then
        touch $fich_log # Si no, lo creamos vacío
    fi

    cat "$3" | while read ip # Leemos las ips de las máquinas
    do
        if ssh -i ~/.ssh/id_as_ed25519 -o ConnectTimeout=5 as@$ip exit 0 # Solo lo ejecutamos si conseguimos conectarnos a la máquina
        then
            caducidad=$(ssh -i ~/.ssh/id_as_ed25519 as@$ip date -I --date "+30 days") # La fecha actual puede ser distinta para cada máquina

            cat "$2" | while read usuario contrasenia nombre_completo
            do
                if [ "$usuario" = "" -o "$contrasenia" = "" -o "$nombre_completo" = "" ]
                then
                    echo "Campo invalido"
                    continue
                fi
                    # Enviamos todo el código a una bash creada en la máquina
                    log=$(ssh -i ~/.ssh/id_as_ed25519 as@$ip bash -c "
                            if grep -q "^$usuario:" /etc/passwd
                            then
                                echo "El usuario $usuario ya existe en $ip"
                            else
                                useradd -m -k /etc/skel -e "$caducidad" -K UID_MIN=1815 -U "$usuario"
                                echo "$usuario:$contrasenia" | chpasswd
                                chage -M 30 "$usuario"
                                echo "$usuario ha sido creado en $ip"
                            fi
                        ")

                    # Mostramos por pantalla y en fich_log el resultado
                    echo "$log"
                    echo "$log" >> "$fich_log"
                fi

            done
        else
            echo “$ip no es accesible”
        fi
    done
    
else #Si se usa el parámetro "-s"

    cat "$3" | while read ip # Leemos las ips de las máquinas
    do
        # Solo lo ejecutamos si conseguimos conectarnos a la máquina
        if ssh -i ~/.ssh/id_as_ed25519 -o ConnectTimeout=5 as@$ip exit 0
        then
            # Comprobamos si existe el directorio backup
            if ssh -i ~/.ssh/id_as_ed25519 as@$ip test ! -d /extra/backup/
            then
                ssh -i ~/.ssh/id_as_ed25519 as@$ip mkdir -p /extra/backup #Creamos el directorio de backup
            fi

            cat "$2" | while read usuario cosas
            do
                # Comprobamos si existe el usuario
                if ssh -i ~/.ssh/id_as_ed25519 as@$ip grep -q "^$usuario:" /etc/passwd
                then
                    ssh -i ~/.ssh/id_as_ed25519 as@$ip tar -cf "/extra/backup/$usuario.tar" -C /home "$usuario" #Hacemos tar

                    if [ $? -eq 0 ] #Comprobamos si el anterior comando ha salido bien
                    then
                        ssh -i ~/.ssh/id_as_ed25519 as@$ip userdel -r "$usuario" #Borramos
                    fi
                fi
            done
        fi
    done
fi
IFS=$OLDIFS
