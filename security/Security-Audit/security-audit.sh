#!/bin/env bash

getUpdate(){
	
	local tmpUpdateList=$(mktemp /tmp/update.XXXXXX)

	apt update &> /dev/null	
	apt list --upgradable > $tmpUpdateList 2> /dev/null

	grep -i "security" $tmpUpdateList

	rm $tmpUpdateList
 
}


getSSH(){
	
	[[ $(ss -tulpn | grep "ssh") ]] || { echo "There is no ssh or it is disabled"; return 0; }

	local rootLogin=$(grep "PermitRootLogin" /etc/ssh/sshd_config | head -n1 | awk '{print $2}')
	local passAuth=$(grep "PasswordAuthentication" /etc/ssh/sshd_config | head -n1 | awk '{print $2}')
	local emptyPasswords=$(grep "PermitEmptyPasswords" /etc/ssh/sshd_config | head -n1 | awk '{print $2}')
	local bruteForceCheck=$(journalctl -S -2h -u ssh | grep "Invalid user" | wc -w)

	local condition_met=1





	if [[ $rootLogin == "prohibit-password" ]];then
		echo "Critical: PermitRootLogin = prohibit-password"
		condition_met=0
	fi

	if [[ $passAuth == yes ]];then
		echo "Warning: PasswordAuth = yes"
		condition_met=0
	fi

	if [[ $emptyPasswords == yes ]];then
		echo "Critical: PermitEmptyPasswords = yes"
		condition_met=0
	fi

	if [[ $BruteForceCheck -gt 100 ]]; then
		echo -e "\n"
		echo "Critical: Brute-force attack detected. You better set up firewall or fail2ban."
		condition_met=0
	fi

	if [[ $condition_met == "1" ]];then
		echo "No warnings"
	fi

	

}



[[ $UID == 0 ]] || { echo "You must run this script with sudo"; exit 1; }

echo "----------------------------------------------"
echo "Security Audit"
echo "----------------------------------------------"
echo -e "SSH issues: \n"
echo "$(getSSH)"
echo "----------------------------------------------"
echo "Sudo users: $(getent group sudo | cut -d: -f4 | tr "," "\n" | wc -w)"
echo -e "\n$(getent group sudo | cut -d: -f4)"
echo "----------------------------------------------"
echo -e "New security updates:\n\n$(getUpdate)"
echo "----------------------------------------------"

