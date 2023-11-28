echo "CLIENTE DE EFTP"
IP=`ip address | grep inet | tail -n 2 | head -n 1 | cut -d " " -f 6 | cut -d "/" -f 1` 
TIMEOUT=1
echo "(1). SEND"

echo "EFTP 1.0" | nc $IP 3333
echo "(2.) LISTEN"
DATA=` nc -l -p 3333 -w $TIMEOUT `
sleep 1
if [ "$DATA" != "OK_HEADER" ]
then
	echo "ERROR 1: BAD_HEADER"
	exit 1
fi
echo "(5.) SEND"
echo "BOOOM" | nc $IP 3333
echo "(6.)LISTEN"
DATA=` nc -l -p 3333 -w $TIMEOUT `
echo "(9).TEST"
sleep 1
if [ "$DATA" != "OK_HANDSHAKE" ]
then
	echo "ERROR 2: BAD_HANDSHAKE"
	exit 2
fi
FILE_NAME="fary.txt"
FILE_MD5=`echo "$FILE_NAME" | md5sum  | cut -d " " -f 1`
echo "(10). SEND"
echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc $IP 3333
echo "(11). LISTEN"
DATA=`nc -l -p 3333 -w $TIMEOUT`
