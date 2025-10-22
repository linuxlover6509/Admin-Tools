#!/bin/env bash 

LEN=$1
AMOUNT=$2

usage(){
	echo ""
	echo "Usage: ./passGen.sh number of characters amd amount of password."
	echo "Example: ./passGen.sh 14 4"
}

passGen(){
	(tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c $LEN) || echo "Something went wrong..."
}


if [[ $LEN -lt 8 ]]; then
	usage 
	exit 0
fi

while [[ $i -lt $AMOUNT ]]; do
	i=$(($i+1))
	echo "$i: $(passGen)"
done
