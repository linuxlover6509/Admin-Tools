#!/bin/env bash

REMOVAL=$1

lsUser(){
	local=$1


	case $1 in

	sudoUsers)
		sudoUsr=$(getent group sudo | cut -d: -f4)
        	echo $sudoUsr ;;

	sudoTotal)
		sudoTot=$(getent group sudo | cut -d: -f4 | tr "," "\n" | wc -w)
		echo $sudoTot ;;
	
	userTotal)
		userTot=$(cat /etc/passwd | grep '/home/' | cut -d: -f1 | wc -w)
		echo $userTot ;;

	esac
}

lsInfo(){
	echo "----------------------------------------------"
	echo "Users: $(lsUser userTotal)"
	echo "----------------------------------------------"
	echo -e "Sudo users: $(lsUser sudoTotal)\n"
	echo "$(lsUser sudoUsers | tr "," "\n")"
	echo "----------------------------------------------"
	echo -e "Hint: if you wanted to block or remove incative users just use -rm arg.\n"
	echo "Example: ./userList -rm"
	echo "----------------------------------------------"
}

lsInactive(){

	local days=$1
	local date=$(date -d "$days days ago" +%Y-%m-%d)

	last -s "$date"


}


[[ $REMOVAL == "-rm" ]] || { lsInfo; exit; }

lsInactive 15
