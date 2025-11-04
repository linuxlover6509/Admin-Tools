#!/bin/env bash

getUpdate(){
	
	local tmpUpdateList=$(mktemp /tmp/update.XXXXXX)

	apt update &> /dev/null	
	apt list --upgradable > $tmpUpdateList 2> /dev/null

	grep -i "security" $tmpUpdateList

	rm $tmpUpdateList
 
}

[[ $UID == 0 ]] || { echo "You must run this script with sudo"; exit 0; }

echo "----------------------------------------------"
echo "Security Audit"
echo "----------------------------------------------"
echo "Sudo users: $(getent group sudo | cut -d: -f4 | tr "," "\n" | wc -w)"
echo -e "\n$(getent group sudo | cut -d: -f4)"
echo "----------------------------------------------"
echo -e "Security updates:\n\n$(getUpdate)"
echo "----------------------------------------------"

