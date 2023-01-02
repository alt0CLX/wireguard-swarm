#!/bin/bash

# colors definitions #
ESC=$(printf '\033') RESET="${ESC}[0m" BLACK="${ESC}[30m" RED="${ESC}[31m"
GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m"

# color functions #
greenprint() { printf "${GREEN}%s${RESET}\n" "$1"; }
blueprint() { printf "${BLUE}%s${RESET}\n" "$1"; }
redprint() { printf "${RED}%s${RESET}\n" "$1"; }
yellowprint() { printf "${YELLOW}%s${RESET}\n" "$1"; }
magentaprint() { printf "${MAGENTA}%s${RESET}\n" "$1"; }
cyanprint() { printf "${CYAN}%s${RESET}\n" "$1"; }

# check if file exist and not empty
fn_check_data()
	{
	if [ ! -f $1 ];
	then
		echo -e "\n\n\t\t$(redprint "$1 does not exist. Check brain, eyes, hands, spelling, etc... and try again")"; sleep 4; clear; $2
	elif [ ! -s $1 ];
	then
		echo -e "\n\n\t\t$(redprint "$1 is empty. Check brain, eyes, hands, spelling, etc... and try again")"; sleep 4; clear; $2
	else
		:
	fi
	}

fn_check_folder()
	{
	if [[ -d $1 ]];
	then
		:
	else
		mkdir $1
	fi
	}

fn_inordl()
	{
	if [ -z $1 ]
	then
		sed -i "/$2/d" $4
	else
		sed -i "s/$3/& $1/" $4
	fi
	}

fn_in()
	{
	sed -i "s/$1/& $2/" $3
	}

fn_msg_don()
	{
	echo -e "\t\t$(greenprint "Files $1 successfully created in the current batch folder\n\t\t$2\n")"	
	}

# create private and public keys
fn_keys()
	{
	umask 077
	fn_check_folder $keys_folder 
	privkeyfilename="privkey_$( date '+%Y-%m-%d_%H-%M-%S' ).txt"
	pubkeyfilename="pubkey_$( date '+%Y-%m-%d_%H-%M-%S' ).txt"
	echo -e "\n"
	read -p $'\t\tAmmount of keys pairs to be generated (default 1): ' pairsa
	pairsa=${pairsa:-1}
	touch $keys_folder/${privkeyfilename}
	touch $keys_folder/${pubkeyfilename}
		for ((i=1; i<=$pairsa; i++))
		do
			client_priv_key=$(wg genkey)
			client_pub_key=$(echo "${client_priv_key}" | wg pubkey)
			echo "$client_priv_key" >> $keys_folder/$privkeyfilename
			echo "$client_pub_key" >> $keys_folder/$pubkeyfilename
		done
	fn_msg_don $privkeyfilename $keys_folder
	fn_msg_don $pubkeyfilename $keys_folder
	sleep 2
	clear
	}

# create psk
fn_psk()
	{
	umask 077
	fn_check_folder $keys_folder
	pskfilename="psk_$( date '+%Y-%m-%d_%H-%M-%S' ).txt"
	echo -e "\n"
	read -p $'\t\tAmmount of psk to be generated (default 1): ' pska
	pska=${pska:-1}
	touch $keys_folder/${pskfilename}
		for ((i=1; i<=$pska; i++))
		do	
			wg genpsk >> $keys_folder/$pskfilename
		done
	fn_msg_don $pskfilename $keys_folder
	sleep 2
	clear
	}

# create servers conf files
fn_srv()
	{
	fn_check_folder $servers_conf_folder
	echo -e "\n\t\tIf file is not in the same folder as the script, path must be given.\n"
	read -e -p $'\t\tName of the csv file (default servers-example.csv) : ' csvname
	csvname=${csvname:-examples/servers-example.csv}
	modelname=conf_model/base.conf
	fn_check_data $modelname "submenu 2"
	fn_check_data $csvname "submenu 2"
			sed -i '/^$/d' $csvname
			while IFS="µ"
			read -r confname srvprivkey address listen table mtu preup postup predown postdown saveconf dns
			do
				confnameresult=$confname.conf
				conf_destination=$servers_conf_folder/$confnameresult
				if [ -z $saveconf ];
				then
					saveconf=""
				else
					saveconf="True"
				fi

# server conf file generation
				cp $modelname $conf_destination; sed -i '/\[Peer\]/,$d' $conf_destination

				fn_in "PrivateKey =" "${srvprivkey//\//\\/}" "$conf_destination"

				fn_in "Address =" "${address//\//\\/}" "$conf_destination"
				
				fn_inordl "$listen" Listen "ListenPort =" "$conf_destination"

				fn_inordl "$table" Table "Table =" "$conf_destination"

				fn_inordl "$mtu" MTU "MTU =" "$conf_destination"

				fn_inordl "${preup//\//\\/}" PreUp "PreUp =" "$conf_destination"

				fn_inordl "${postup//\//\\/}" PostUp "PostUp =" "$conf_destination"

				fn_inordl "${predown//\//\\/}" PreDown "PreDown =" "$conf_destination"

				fn_inordl "${postdown//\//\\/}" PostDown "PostDown =" "$conf_destination"

				fn_inordl "$saveconf" SaveConfig "SaveConfig =" "$conf_destination"

				fn_inordl "$dns" DNS "DNS =" "$conf_destination"

			done < <(tail -n +2 $csvname)
	fn_msg_don $servers_conf_folder
	sleep 2
	clear
	}

#import peer into server conf file
fn_imp_peers()
	{
	echo -e "\n\t\tIf file is not in the same folder as the script, path must be given.\n"
	read -e -p $'\t\tName of the txt file holding the clients list (default list001-example.csv) : ' listname
	listname=${listname:-examples/list001-example.csv}
	fn_check_data $listname "submenu 2"
	read -e -p $'\t\tName of the target server conf file (default Angmar.conf) : ' targetconf
	targetconf=${targetconf:-$servers_conf_folder/Angmar.conf}
	fn_check_data $targetconf "submenu 2"
	sed -i '/^$/d' $listname
	while IFS="µ"
	read -r peerfilename
	do
	cat $peer_file_folder/$peerfilename >> $targetconf; sed -i '/^\[Peer\]/i \\' $targetconf
	done < <(tail -n +2 $listname) 
	echo -e "\n\n\t\tConfiguration files have been updated in the current batch folder\n\t\t$servers_conf_folder"
	sleep 2	
	}

# create clients conf file and peer file
fn_conf()
	{
	fn_check_folder $clients_conf_folder
	fn_check_folder $peer_file_folder
	echo -e "\n\t\tIf file is not in the same folder as the script, path must be given.\n"
	read -e -p $'\t\tName of the csv file (default clients-example.csv) : ' csvname
	csvname=${csvname:-examples/clients-example.csv}
	modelname=conf_model/base.conf
	fn_check_data $csvname mainmenu
	fn_check_data $modelname mainmenu
			sed -i '/^$/d' $csvname
			while IFS="µ"
			read -r confname clprivkey address listen table mtu preup postup predown postdown saveconf dns srvpubkey allowedips  srvpubip port psk keepalive clpubkey clpubip
			do
				confnameresult=$confname.conf
				peer_file_name=$confname-peer_file.txt
				conf_destination=$clients_conf_folder/$confnameresult
				peer_file_destination=$peer_file_folder/$peer_file_name
				srvchan="${srvpubip}:${port}"
				clpubip="${clpubip}:${listen}"
					if [[ "$allowedips" == 0.0.0.0/0 ]];
					then
						allowedipsresult="0.0.0.0/0"
					else
						allowedipsresult="${address}, ${allowedips}"
					fi

# create conf file
				cp $modelname $conf_destination

				fn_in "PrivateKey =" "${clprivkey//\//\\/}" "$conf_destination"

				fn_in "Address =" "${address//\//\\/}" "$conf_destination"

				fn_inordl "$listen" Listen "ListenPort =" "$conf_destination"

				fn_inordl "$table" Table "Table =" "$conf_destination"

				fn_inordl "$mtu" MTU "MTU =" "$conf_destination"

				fn_inordl "${preup//\//\\/}" PreUp "PreUp =" "$conf_destination"

				fn_inordl "${postup//\//\\/}" PostUp "PostUp =" "$conf_destination"

				fn_inordl "${predown//\//\\/}" PreDown "PreDown =" "$conf_destination"

				fn_inordl "${postdown//\//\\/}" PostDown "PostDown =" "$conf_destination"

				fn_inordl "$saveconf" SaveConfig "SaveConfig =" "$conf_destination"

				fn_inordl "$dns" DNS "DNS =" "$conf_destination"

				fn_in "PublicKey =" "${srvpubkey//\//\\/}" "$conf_destination"

				fn_in "AllowedIPs =" "${allowedipsresult//\//\\/}" "$conf_destination"

				fn_in "Endpoint =" "${srvchan//\//\\/}" "$conf_destination"

				fn_inordl "${psk//\//\\/}" PresharedKey "PresharedKey =" "$conf_destination"

				fn_inordl "$keepalive" PersistentKeepalive "PersistentKeepalive =" "$conf_destination"

# create peer file
				cp $modelname $peer_file_destination

				if [[ "$allowedips" == 0.0.0.0/0 ]];
				then
					allowedipsresult="${address}"
				else
					allowedipsresult="${address}, ${allowedips}"
				fi

				sed -i '/\[Peer\]/,$!d' $peer_file_destination

				fn_in "PublicKey =" "${clpubkey//\//\\/}" "$peer_file_destination"

				fn_in "AllowedIPs =" "${allowedipsresult//\//\\/}" "$peer_file_destination"

				fn_inordl "$clpuip" Endpoint "Endpoint =" "$peer_file_destination"

				fn_inordl "${psk//\//\\/}" PresharedKey "PresharedKey =" "$peer_file_destination"

				fn_inordl "$keepalive" PersistentKeepalive "PersistentKeepalive =" "$peer_file_destination"

			done < <(tail -n +2 $csvname)
			ls $peer_file_folder > $peer_file_folder/list.csv; sed -i '/list/d' $peer_file_folder/list.csv; sed -i '1ipeerfilename' $peer_file_folder/list.csv
			fn_msg_don $clients_conf_folder
			fn_msg_don $peer_file_folder
			fn_msg_don list.csv
			sleep 2
			clear
	}

fn_bye()
	{
	echo -e "$(cyanprint '\n\n\t\tChuuuusss !')"; sleep 1; clear; exit 0;
	}

fn_fail()
	{
	echo -e "\n\n\t\t$(redprint 'Invalid choice')\n"; sleep 1; clear;
	}


submenu()
	{
	clear
	if [ $1 = 1 ]
	then
		echo -ne "
		$(cyanprint 'KEYS MENU\n')
		$(greenprint '\t(1)') Create keys pairs
		$(greenprint '\t(2)') Create psk
		$(magentaprint '\t(3)') Go Back to Main Menu
		$(redprint '\t(0)') Exit
		$(yellowprint '\n\t\tChoose an option:  ')"
    		read -r ans
    		case $ans in
    			1)
        			fn_keys
        			submenu 1
        		;;
    			2)
        			fn_psk
        			submenu 1
        		;;
    			3)
        			mainmenu
        		;;
    			0)
        			fn_bye
        		;;
    			*)
        			fn_fail
        		;;
		esac
	elif [ $1 = 2 ]
	then
		echo -ne "
		$(cyanprint 'SERVER MENU\n')
		$(greenprint '\t(1)') Create server conf files
		$(greenprint '\t(2)') Import peers
		$(magentaprint '\t(3)') Go Back to Main Menu
		$(redprint '\t(0)') Exit
		$(yellowprint '\n\t\tChoose an option:  ')"
    		read -r ans
    		case $ans in
    			1)
        			fn_srv
        			submenu 2
        		;;
    			2)
        			fn_imp_peers
        			submenu 2
        		;;
    			3)
        			mainmenu
        		;;
    			0)
        			fn_bye
        		;;
    			*)
        			fn_fail
        		;;
		esac
	else
	mainmenu
	fi
	}

mainmenu()
	{
	clear
	echo -ne "
	$(cyanprint '\tMAIN MENU\n')
	$(greenprint '\t\t(1)') Keys menu
	$(greenprint '\t\t(2)') Create server conf files
	$(greenprint '\t\t(3)') Create clients conf files
	$(redprint '\t\t(0)') Exit
	$(yellowprint '\n\t\tChoose an option:  ')"
    	read -r ans
    	case $ans in
		1)
			submenu 1
			mainmenu
 		;;
 		2)
 			submenu 2
			mainmenu
		;;
 		3)
 			fn_conf
			mainmenu
		;;
		0)
			fn_bye
		;;
		*)
			fn_fail
			mainmenu
		;;
		esac
	}

# set the output folder
clear
echo -e "$(cyanprint '\n\t\tSETTINGS\n')"
echo -e "\n\t\tCreate a new batch folder, use an existing one or use default generated name\n"
read -e -p $'\t\tEnter folder name (Enter for default): ' batch_dir
batch_dir=${batch_dir:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/batch_$( date '+%Y-%m-%d_%H-%M-%S' )"}
keys_folder=$batch_dir/keys_files
clients_conf_folder=$batch_dir/clients_conf_files
peer_file_folder=$batch_dir/clients_peer_files
servers_conf_folder=$batch_dir/srv_conf_files
fn_check_folder $batch_dir

# main  menu display
clear
mainmenu
