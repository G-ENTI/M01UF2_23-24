#!/bin/bash
echo "SERVIDOR DE EFTP"
IP=`ip address | grep inet | tail -n 2 | head -n 1 | cut -d " " -f 6 | cut -d "/" -f 1`
PORT=3333
TIMEOUT=1
echo "(0). Listen"

# Almacenamos el mensaje de netcat dentro de la variable "DATA"
DATA=` nc -l -p $PORT -w $TIMEOUT `
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
	echo "KO__HEADER" | nc $IP $PORT
	exit 1
fi
# En caso de ser correcto, continua enviando el mensaje "OK_HEADER" al cliente
echo "OK_HEADER" | nc $IP $PORT
# Ponemos el servidor en escucha
echo "(4.) LISTEN"
# Almacenamos la escucha del servidor dentro de la variable "DATA"
DATA=` nc -l -p $PORT -w $TIMEOUT `
sleep 1
# Comprobamos que el HANDSHAKE es correcto
echo "(7.) TEST & SEND"
# En caso de no ser, muestra un mensaje de error y sale con codigo 2
if [ "$DATA" != "BOOOM" ]
then
	echo "ERROR 2: BAD_HANDSHAKE"
	echo "KO_HANDSHAKE" | nc $IP $PORT
	exit 2
fi
# En caso de ser correcto enviara el mensaje "OK_HANDSHAKE al cliente"
echo "OK_HANDSHAKE" | nc $IP $PORT
# Inmediantamente despues entramos en escucha
echo "(8).Listen"
# Almacenamos la entrada de datos dentro de la variable "DATA"
DATA=` nc -l -p $PORT -w $TIMEOUT `
echo "(12).TEST & STORE & SEND"
# Cortamos el mensaje entrante por data y nos guardamos el resultado del corte dentro de la variable "PREFIX"
PREFIX=`echo $DATA | cut -d " " -f 1`
# Si el prefix es incorrecto, enviara el mensaje "KO_FILENAME" y terminara el proceso en codigo 3
if [ "$PREFIX" != "FILE_NAME" ]
then
	echo "ERROR 3: BAD FILENAME PREFIX"
	sleep 1
	echo "KO_FILE_NAME" | nc $IP $PORT
	exit 3
fi
# En caso de ser correcto, enviara el mensaje "OK_FILE_NAME"
echo "OK_FILE_NAME" | nc $IP $PORT

