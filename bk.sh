#! /bin/bash

# Ejecutar bash bk.sh ip_maquina cod_maquina cod_cliente

DATE=$(date "+%d%h%Y%H%M")
TO="/root/bk/$3/$2/rsync"
FROM="root@$1:/root/copias/$2/"

if test ! -d /root/bk/$3
then
	mkdir /root/bk/$3
fi

if test ! -d /root/bk/$3/$2
then
	mkdir /root/bk/$3/$2
fi

if test ! -d /root/bk/$3/$2/rsync
then
	mkdir /root/bk/$3/$2/rsync
fi

if rsync --delete -avb $FROM $TO
then
	cd /root/bk/$3/$2/rsync/
	PAQ="BACKUP-$2-$DATE.tar"
	tar cf ../$PAQ *
	echo "OK" > /root/temp
	echo $PAQ >> /root/temp
else
	echo "no" > /root/temp
fi
