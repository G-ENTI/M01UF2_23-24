#!/bin/bash

CLIENT="xx.xx.xx.xx"
PORT="3333"
TIMEOUT=1
#1 escuchar
echo "(0) Listen"
# Recibimos el mensaje del cliente el cual indica el nombre y la verison del protocolo
DATA=`nc -l -p $PORT -w $TIMEOUT`
PROTOCOL=`echo $DATA | cut -d " " -f 1`
VERSION=`echo $DATA | cut -d " " -f 2`

# Comprovamos si el mensaje recibido es correcto
echo "(3) Test & Send : HEADER"
# En caso de ser incorrecto, saldra con el codigo 1
if [ "$PROTOCOL $VERSION" != "EFTP 1.0" ]
then
	echo "Error 1 BAD_HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT 3333 
	exit 1 
fi
# Comprovamos que el campo de la ip tiene algun dato
CLIENT=`echo $DATA | cut -d " " -f 3`
if [ "$CLIENT" == "" ]
then
	echo "ERROR: IP NO PROPORCIONADA"
	exit 1
fi
sleep 1
# Una vez todo verificado correctamente, mandamos el mensaje de OK al cliente
echo "OK_HEADER" | nc $CLIENT $PORT

# Escuchamos para recibir el HANDSHAKE por parte del cliente
echo "(4) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

#Comprovamos si el HANDSHAKE es correcto

echo "(7) Test & Send : HANDSHAKE"
if [ "$DATA" != "BOOOM" ]
then
	echo "Error 2 HANDSHAKE"
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT $PORT
	exit 2
fi
sleep 1
# En caso de ser correcto, enviamos el OK al cliente
echo "OK_HANDSHAKE" | nc $CLIENT $PORT

# Ponemos el servidor en escucha
echo "(8) LISTEN"

# Llegada de prefijo, nombre del archivo y el hashMD5 del nombre del archivo
DATA=`nc -l -p $PORT -w $TIMEOUT`

# Siguiente paso
echo "(12) Test&store&send"

# Este primer bloque de variables almacena el prefix, el filename y el hashMD5 en diferentes variables
PREFIX=`echo "$DATA" | cut -d " " -f 1` 
FILE_NAME=`echo "$DATA" | cut -d " " -f 2`
FILE_MD5=`echo "$DATA" |cut -d " " -f 3`

# El segundo bloque calcula y almacena el hashMd5 del nombre del archivo que ha llegado de manera local
FILE_MD5_LOCAL=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

# Comprovamos si el Prefijo
if [ "$PREFIX" != "FILE_NAME" ]
then
	echo "ERROR 3: BAD FILE NAME PREFIX"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi
# Comrpvamos el MD5 comparandolo al calculado de manera local
if [ "$FILE_MD5" != "$FILE_MD5_LOCAL" ]
then
	echo "ERROR 3 : BAD FILE NAME MD5"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi

#En caso de ser correcto, mandamos el OK al cliente
echo "OK_FILE_NAME" | nc $CLIENT $PORT

# Siguente paso:
echo "(13) Listen"

# Guardamos el contenido del archivo mandado por el cliente dentro de un archivo de manera local en el servidor.
nc -l -p $PORT -w $TIMEOUT > inbox/$FILE_NAME
echo "Contenido del archivo guardado correctamente"

# Comprovamos si el archivo ha llegado vacio
echo "(16) STORE & SEND"
DATA=`cat inbox/$FILE_NAME`

if [ "$DATA" == "" ]
then
	echo "Error 4: EMTY_DATA"
	sleep 1
	echo "KO_DATA" | nc $CLIENT $PORT
	exit 4
fi
# En caso de no llegar vacio mandamos el OK al cliente
echo "OK_DATA" | nc $CLIENT $PORT

echo "(17) LISTEN"
# Llegada del MD5 del contenido del archivo
DATA=`nc -l -p $PORT -w $TIMEOUT`

# Dividimos la llegada de los datos entre el prefix y el md5, almacenando estos en variables.
FILE_MD5=`echo $DATA | cut -d " " -f 2`
PREFIX=`echo $DATA | cut -d " " -f 1`

# Calculamos el MD5 del contenido del archivo almacenado de manera local
FILE_MD5_LOCAL=`cat inbox/$FILE_NAME | md5sum | cut -d " " -f 1`

# VERIFICACIONES FINALES
echo "(20) TEST $ SEND"

# Comrovacion del prefix del mensaje
if [ "$PREFIX" != "FILE_MD5" ]
then 
	echo "ERROR 5: BAD FILE_MD5"
	exit 4
fi

# Comprovacion del MD5 del contenido del archivo
if [ "$FILE_MD5" != "$FILE_MD5_LOCAL" ]
then
	echo "ERROR 6: FILE_MD5"
	sleep 1
	echo "KO_FILE_MD5" | nc $CLIENT $PORT
fi
# En caso de todo haber funcionado de manera correcta, mandamos el OK al cliente
sleep 1
echo "OK_FILE_MD5" | nc $CLIENT $PORT

#terminamos el código
echo "Funciones del servidor completadas correctamente, FINAL DEL PROTOCOLO (SERVER)"
exit 0
