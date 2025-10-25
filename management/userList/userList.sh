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
	echo "Hint: if you wanted to block or remove inative users just use -rm arg"
	echo "Example: ./userList -rm"
	echo -e "\nATTENTION! You must me ROOT to start this script with -rm arg!"
	echo "----------------------------------------------"
}

lsInactive(){

	local days=$1
	local date=$(date -d "$days days ago" +%Y-%m-%d)
	local tmpAll=$(mktemp /tmp/all.XXXXXX)
	local tmpActive=$(mktemp /tmp/active.XXXXXX)

	last -s "$date" 2>/dev/null | \
		awk '$1 != "wtmpdb" && $1 != " " && $1 != "reboot" {print $1}' | sort -u > $tmpActive

	getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' | sort > $tmpAll
		

	comm -23 $tmpAll $tmpActive

	rm -f $tmpAll $tmpActive	

}


delUsr(){
	clear
	echo "----------------------------------------------"
	echo -e "Choose option:\n"
	echo "1) Delete user with /home"
	echo "2) Delete user with /home backup"
	echo -e "3) Delete user whithout /home\n"

	until [[ $backup =~ ^[1-3]$ ]]; do
		read -rp "Option choise [1-3]: " backup
	done
	

	echo "----------------------------------------------" 
	echo -e "Users to delete:\n\n$(lsInactive $days)"
	echo "----------------------------------------------"
	echo -e "\n\nWARNING! THIS OPERATION WILL ERASE THESE USERS FROM THE SYSTEM. ARE YOU SURE? (verify)"
	
	until [[ $check =~ ^[YN]$ ]]; do
		read -rp "Action choise [Y/N]: " check
	done
	
	[[ $check == "Y" ]] || { echo "Aborting..."; exit; }

	
	#Erase user with /home without backup
	if [[ $backup == "1" ]]; then		
		for usr in $(lsInactive $days); do
			echo "Removing $usr..."
			userdel -r $usr || { echo -e "Error when removing $usr.\nTry to check the running processes for this user"; exit 1; }
		done

		echo "Complete."

	#Erase user with /home with backup
	elif [[ $backup == "2" ]]; then
		
		backDir="/var/backups/userList"
		echo "Using /var/backups/userList"

		[[ -d $backDir ]] || mkdir -pv $backDir
					
		for usr in $(lsInactive $days); do
			uniq=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 6)
			backName="backup_${usr}_${uniq}.tar.gz"
			usrDir=/home/$usr/

			echo -e "\nPacking $usrDir"

			tar -czf $backDir/$backName $usrDir &> /dev/null
			tar -xzf $backDir/$backName -O > /dev/null || { echo "Cant create archive on $usr, aborting operation..."; exit 1; }

			echo "Removing $usr..."
			echo "Backup: $backDir/$backName"
			userdel -r $usr || { echo -e "Error when removing $usr.\nTry to check the running processes for this user"; exit 1; }
		done
		
		echo -e "\nComplete"

	#Erase user without /home
	else
		for usr in $(lsInactive $days); do
			echo "Removing $usr..."
			userdel $usr || { echo -e "Error when removing $usr.\nTry to check the running processes for this user"; exit 1; }
		done
		
		echo "Complete"
	fi
}



[[ $REMOVAL == "-rm" ]] && [[ $UID == "0" ]] || { usage; exit; }

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

