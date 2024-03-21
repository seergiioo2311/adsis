#!/bin/bash
#873983, Isla Lasheras, Sergio, T, 1, A

#Comprobamos que el usuario sea privilegiado
if [ $EUID -ne 0 ]; then
	echo "Este script necesita privilegios de administracion"
	exit 1
fi

crearUsuario() {
	#Comprobamos que los parÃmetros de la funciÃn no son ninguno la cadena vacÃa
	if [ -z $1 || -z $2 || -z $3 ]; then
		echo "Campo invalido"
		exit 1
	else
		if [ id "$1" >/dev/null 2>&1]; then
			echo "El usuario $1 ya existe"
		else
			useradd -U -m -k /etc/skel -K UID_MIN=1815 -K PASS_MAX_DAYS=30 -c "$1" "$3" &> /dev/null
			echo "$1:$2" | chpasswd
			echo "$3 ha sido creado"
			usermod -aG 'sudo' $1
		fi
	fi
}

borrarUsuario() {
	homeUser="$(getent passwd $1 | cut -d: -f6)"
	tar czvf "/extra/backup/$1.tar" "${homeUser}" &> /dev/null
	userdel -f "$1" &> /dev/null
}

#Comprobamos que el nÃºmero de argumentos sea 2
if [ $# -ne 2 ]; then 
	echo "Numero incorrecto de parametros"

else
	#Comprobamos si se desea crear o borrar un usuario
	if [[ $1 == "-a" ]]; then
		#INTRODUCIR CODIGO CORRESPONDIENTE A LA CREACION DE USUARIOS
		#Le pasamos a la funciÃn crearUsuario todos los datos del fichero de entrada
		while IFS=, read -r user passwd nom
		do
			crearUsuario "$user" "$passwd" "$nom"
		done
		
	elif [[ $1 == "-s" ]]; then
		#Comprobamos que existe el directorio /extra/backup
		if [ ! -d "/extra" ]; then 
			mkdir -p /extra/backup
		elif [ ! -d "/extra/backup" ]; then
			mkdir /extra/backup
		fi
		
		#Le pasamos a la funciÃn borrarUsuario el nombre de usuario
		while IFS=, read -r user resto 
		do
			borrarUsuario "$user"
		done

	else
		echo "Opcion invalida" 1>&2
	fi
fi
