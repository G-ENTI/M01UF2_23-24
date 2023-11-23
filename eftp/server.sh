#!/bin/bash
echo "SERVIDOR DE EFTP"

echo "(0). Listen"

# Almacenamos el mensaje de netcat dentro de la variable "DATA"
DATA=` nc -l -p 3333 -w 0 `
# Mostramos por la salida estadar lo almacenado en la variable "DATA"
echo "$DATA"
sleep 1
# Cooldown de 1 segundo tras mostrar el mensaje

# Comprovamos si el mensaje enviado es el que tiene que ser
echo "(3). TEST & SEND"
# En caso de no ser, muestra un mensaje de error y sale con codigo 1
if [ "$DATA" != "EFTP 1.0" ]
then
	echo "ERROR!!!"
	echo "KO__HEADER" | nc localhost 3333
	exit 1
fi
# En caso de ser correcto, continua enviando el mensaje "OK_HEADER" al cliente
echo "OK_HEADER" | nc localhost 3333
# Ponemos el servidor en escucha
echo "(4. LISTEN)"
# Almacenamos la escucha del servidor dentro de la variable "DATA"
DATA=` nc -l -p 3333 -w 0 `
sleep 1
# Comprobamos que el HANDSHAKE es correcto
echo "(7.) TEST & SEND"
# En caso de no ser, muestra un mensaje de error y sale con codigo 2
if [ "$DATA" != "BOOOM" ]
then
	echo "ERROR 2: BAD_HANDSHAKE"
	echo "KO_HANDSHAKE" | nc localhost 3333
	exit 2
fi
echo "OK_HANDSHAKE" | nc localhost 3333
echo "(8).Listen"
DATA=` nc -l -p 3333 -w 0 `
echo "(12).TEST & STORE & SEND"
PREFIX=`echo $DATA | cut -d " " -f 1`
if [ "$PREFIX" != "FILE_NAME" ]
then
	echo "ERROR 3: BAD FILENAME PREFIX"
	sleep 1
	echo "KO_FILE_NAME" | nc localhost 3333
	exit 3
fi

FILE_NAME=` echo $DATA | cut -d " " -f 2 `




