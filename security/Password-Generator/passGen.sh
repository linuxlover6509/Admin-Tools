#!/bin/env bash 

LEN=$1
AMOUNT=$2

usage(){
	echo "Usage: ./passGen.sh number of characters and amount of password."
	echo "Example: ./passGen.sh 14 4"
}

passGen(){
	(tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c $LEN)
}


[[ $LEN -lt 8 ]] && { usage; exit; }


while [[ $i -lt $AMOUNT ]]; do
	i=$(($i+1))
	echo "$i: $(passGen)"
done
