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

usage(){
	echo "----------------------------------------------"
	echo "Users: $(lsUser userTotal)"
	echo "----------------------------------------------"
	echo -e "Sudo users: $(lsUser sudoTotal)\n"
	echo "$(lsUser sudoUsers | tr "," "\n")"
	echo "----------------------------------------------"
	echo -e "Hint: if you wanted to block or remove inative users just use -rm arg.\n"
	echo "Example: ./userList -rm"
	echo "----------------------------------------------"
}

lsInactive(){

	local days=$1
	#local date=$(date -d "$days days ago" +%Y-%m-%d)
	local tmpAll=$(mktemp /tmp/all.XXXXXX)
	local tmpActive=$(mktemp /tmp/active.XXXXXX)
	local date="2025-10-24"


	last -s "$date" 2>/dev/null | \
		awk '$1 != "reboot" && $1 != " " && $1 != "wtmpdb" {print $1}' | sort -u > $tmpActive

	getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' > $tmpAll
		

	comm -23 $tmpAll $tmpActive

	rm -f $tmpAll $tmpActive	

}


delUsr(){

	echo "amogus"	

}



[[ $REMOVAL == "-rm" ]] || { usage; exit; }


echo -e "\nHow many days has the user been inactive?"

until [[ $days =~ ^[1-9][0-9]?[0-9]?$ ]] && [[ $days -le 365 ]]; do
	read -rp "Day choise [1-365]: " days
done

echo "----------------------------------------------"
echo "Inactive total: $(lsInactive $days | wc -w)"
echo "----------------------------------------------"
echo -e "Inactive users:\n\n$(lsInactive $days) "
echo "----------------------------------------------"
echo -e "Do you want to delete or block these users?\n"
echo "1) Delete users"
echo "2) Block users"

until [[ $action_choise =~ ^[1-2]$ ]]; do
	read -rp "Action choise [1-2]: " action_choise
done

[[ $action_choise == "1" ]] && delUsr || echo "block"
