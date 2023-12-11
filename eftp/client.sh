#!/bin/bash

# Variables iniciales
SERVER=`ip address | grep inet | tail -n 2 | head -n 1 | cut -d " " -f 6 | cut -d "/" -f 1`
PORT="3333"
TIMEOUT=1

# Enviamos el nombre y la version del protocolo al servidor
echo "(1) Send"
echo "EFTP 1.0"
sleep 1
echo "EFTP 1.0 $IP" | nc $SERVER $PORT

# Escuchamos la respuesta del servidor
echo "(2) LISTEN"
# Se almacena la respuesta en la variable DATA
DATA=`nc -l -p $PORT -w $TIMEOUT`

# Verificamos que todo ha marchado de manera correcta dentro del servidor
echo "(5) TEST & SEND" 
if [ "$DATA" != "OK_HEADER" ]
then
	echo "ERROR 1: BAD_HEADER"
	exit 1
fi

# En caso de que todo haya marchado de manera correcta, mandamos el handshake al servidor.
sleep 1
echo "BOOOM" | nc $SERVER $PORT

# Con el handshake ya enviado esperaremos la respuesta del servidor en la variable DATA (sobreescrita)
echo "(6) LISTEN"
DATA=`nc -l -p $PORT -w $TIMEOUT`

# Verificamos que todo haya marchado de manera correcta dentro del servidor
echo "(9) TEST"
if [ "$DATA" != "OK_HANDSHAKE" ]
then
	echo "ERROR 2 : BAD_HANDSHAKE"
	exit 2
fi
# En caso de ser correcto, mostramnos un mensaje que indica que se ha realizado correctamente.
echo "Connexion correctamente establecida con el servidor..."

# Almacenamos dentro de variables el nombre del archivo asi como el hash MD5 del nombre del archivo.
FILE_NAME="fary1.txt"
FILE_MD5=`echo fary1.txt | md5sum | cut -d " " -f 1`

# Siguiente paso
echo "(10)SEND FILENAME"
echo "Sending: Filename & HashMD5"
sleep 1
# Enviamos el mensaje en formato (PREFIX) (FILE_NAME) (HASH_MD5)
echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc $SERVER $PORT

# Escuchamos si todo ha ido de manera correcta dentro del servidor
echo "(11)Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

# Comrpvamos si todo ha ido correctamente en el servidor
echo "(14) Test&send"
if [ "$DATA" != "OK_FILE_NAME" ] 
then
	echo "ERROR 3: BAD FILE_NAME"
	exit 3
fi

# En caso de todo ir de manera correcta continuamos con el protocolo
sleep 1

# Mandamos el contenido del archivo al servidor
cat imgs/fary1.txt | nc $SERVER $PORT

# Escuchamos el mensaje de comprovacion del servidor.
echo "(15) LISTEN"
DATA=`nc -l -p $PORT -w $TIMEOUT`

# Verificamos que todo ha ido correctamente dentro del servidor
if [ "$DATA" != "OK_DATA" ]
then
	echo "ERROR 4: EMPTY_DATA"
	sleep 1
	echo "KO_DATA"
	exit 4
fi

# En caso de ser correcto continuamos el protocolo
echo "(18) SEND"

# Calculamos el MD5 del contenido del archivo, lo almacenamos en una variable y lo mandamos.
FILE_MD5=`cat imgs/$FILE_NAME | md5sum | cut -d " " -f 1`
sleep 1
echo "FILE_MD5 $FILE_MD5" | nc $SERVER $PORT
sleep 1


echo "(19) LISTEN"

DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA
echo "(21) TEST"
if [ "$DATA" != "OK_FILE_MD5" ]
	then
	echo "ERROR: FILE_ MD5"
	exit 5
fi

echo "Archivo mandado de manera correcta, FINAL DEL PROTOCOLO (CLIENT)"
exit 0
