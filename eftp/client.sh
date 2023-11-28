echo "CLIENTE DE EFTP"
# Conseguimos la ip de la maquina, el puerto y seteamos el timeout
IP=`ip address | grep inet | tail -n 2 | head -n 1 | cut -d " " -f 6 | cut -d "/" -f 1`
PORT=3333 
TIMEOUT=1
# Una vez el servidor puesto en escucha empezamos enviando el header
echo "(1). SEND"

echo "EFTP 1.0" | nc $IP $PORT
# Una vez enviado el header entramos en escucha
echo "(2.) LISTEN"
DATA=` nc -l -p $PORT -w $TIMEOUT `
sleep 1
# Comprobamos que el servidor ha recibido correctamente el header, en caso de no hacerlo nor dara error 1
if [ "$DATA" != "OK_HEADER" ]
then
	echo "ERROR 1: BAD_HEADER"
	exit 1
fi
# En caso de ser correcto, continuara el proceso enviando el handshake
echo "(5.) SEND"
echo "BOOOM" | nc $IP $PORT
# Una vez enviado el handshake nos ponemos en escucha
echo "(6.)LISTEN"
# Almacenamos lo escuchado dentro de la variable DATA
DATA=` nc -l -p $PORT -w $TIMEOUT `
echo "(9).TEST"
# Testeo si el servidor ha recibido correctamente el hanshake, en caso de no hacerlo nos dara el error 2
sleep 1
if [ "$DATA" != "OK_HANDSHAKE" ]
then
	echo "ERROR 2: BAD_HANDSHAKE"
	exit 2
fi
# En caso de ser correcto seguira el proceso enviando el nombre del archivo junto a el MD5 de su nombre
FILE_NAME="fary.txt"
FILE_MD5=`echo "$FILE_NAME" | md5sum  | cut -d " " -f 1`
echo "(10). SEND"
echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc $IP $PORT
echo "(11). LISTEN"
DATA=`nc -l -p $PORT -w $TIMEOUT`
