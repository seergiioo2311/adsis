#!/bin/bash
#873983, Isla Lasheras, Sergio, T, 1, A

crearUsuario() {
	#Comprobamos que los parametros de la funcion no son ninguno la cadena vacia
	if [ -z "$1" || -z "$2" || -z "$3" ]; then
		echo "Campo invalido" 1>&2
		exit 1
	else
		if [ id "$1" && "$1" != "root" ]; then
			echo "El usuario $3 ya existe" 1>&2
		else	
			useradd -U -m -k /etc/skel -K UID_MIN=1815 -c "$3" "$1" 2>/dev/null
			usermod -f 30 "$1"
			echo "$1:$2" | chpasswd
			echo "$3 ha sido creado"
		fi
	fi
}

borrarUsuario() {
	if [ ! -z "$1" ]; then
		homeUser="$(getent passwd $1 | cut -d: -f6)"
		tar czvf "/extra/backup/$1.tar" "$homeUser"
		userdel -r "$1" 2>/dev/null
	else
		echo "Campo invalido" 1>&2
		exit 1
	fi
}

#Comprobamos que el usuario posee privilegios de administracion
if [ "$EUID" -eq 0 ]; then
	#Comprobamos que el numero de argumentos sea 2
	if [ "$#" -eq 2 ]; then 
		#Comprobamos si se desea crear o borrar un usuario
		if [ "$1" == "-a" ]; then
			#Le pasamos a la funcion crearUsuario todos los datos del fichero de entrada
			IFS=","
			while read user passwd nom
			do
				crearUsuario "$user" "$passwd" "$nom"
			done <"$2"
		
		elif [ "$1" == "-s" ]; then
			#Comprobamos que existe el directorio /extra/backup
			if [ ! -d "/extra" ]; then
			       mkdir /extra/
		       	fi
	 
			if [ ! -d "/extra/backup" ]; then
				mkdir /extra/backup/
			fi
			
			#Le pasamos a la funcion borrarUsuario el nombre de usuario
			IFS=","
			while read user resto 
			do
				borrarUsuario "$user"
			done <"$2"
	
		else
			echo "Opcion invalida" 1>&2
		fi
	else 
		echo "Numero incorrecto de parametros" 1>&2
		exit 1
	fi
else 
	echo "Este script necesita privilegios de administracion" 1>&2
	exit 1
fi
