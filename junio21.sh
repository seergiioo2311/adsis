#!/bin/bash

#Función encargada de enviar el mail a root 
sendMail() {
	file=$1
	cat "$file" | mail -s "usuarios con mal password" root
}
#Función que comprueba la contraseña del usuario
checkUser() {
	user=$1
	dir_IP=$2
	file=$3
	while read -r passwd; do
		sshpass -e ssh $user@$dir_IP "exit" &> /dev/null
		if [[ $? -eq 0 ]]; then 
			return 1
		fi
	done < "$file"
	return 0
}

checkParameters() {
	dir_IP=$1
	file=$2
	regex='^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$'
	if [[ -f $file ]]; then
		return 1
	fi
	if [[ $dir_IP =~ $regex ]]; then
		return 1
	fi
}

dir_IP=$1
file=$2
checkParameters $1 $2
if [[ $? -eq 1 ]]; then
	echo "Sintaxis inválida por pantalla"
	return 1
fi

fichero="prueba.txt"
touch "$fichero"
filepasswd=$(ssh $dir_IP "cat /etc/passwd")

while IFS= read -r linea; do
	user_UID=$(echo "$linea" | awk -F ":" '{print $3}')
	if [[ $user_UID -ge 1000 ]]; then
		user=$(echo "$linea" | awk F ":" '{pritn $1}')
		checkUser $user $dir_IP $file
		if [[ $? -eq 1 ]]; then
			echo "El usuario: $user posee una contraseña debil" >> $fichero
		fi
	fi
done < $filepasswd

sendMail $fichero
