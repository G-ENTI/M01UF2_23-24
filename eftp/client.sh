echo "CLIENTE DE EFTP"

echo "(1). SEND"

echo "EFTP 1.0" | nc localhost 3333
echo "(2.) LISTEN"
DATA=` nc -l -p 3333 -w 0 `
sleep 1
if [ "$DATA" != "OK_HEADER" ]
then
	echo "ERROR 1: BAD_HEADER"
	exit 1
fi
echo "(5.) SEND"
echo "BOOOM" | nc localhost 3333
echo "(6.)LISTEN"
DATA=` nc -l -p 3333 -w 0 `
echo "(9).TEST"
sleep 1
if [ "$DATA" != "OK_HANDSHAKE" ]
then
	echo "ERROR 2: BAD_HANDSHAKE"
	exit 2
fi
echo "(10). SEND"
echo "FILE_NAME fary.txt" | nc localhost 3333
echo "(11). LISTEN"
DATA=`nc -l -p 3333 -w 0`
