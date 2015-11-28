#!/bin/bash

Trapper () {
	trap ':' INT EXIT TSTP TERM HUP
}
Color() {
        Print_Red () {
        echo  -e  "\033[40;31m $1  \033[0m "
        }
        Print_Green () {
        echo -e  "\033[40;32m $1 \033[0m "
        }
        Print_Yellow () {
        echo -n -e  "\033[40;33m $1 \033[0m "
        }
        Print_Purple () {
        echo -e  "\033[40;35m $1 \033[0m "
        }

}
Check_Variable () {
        Display_Result () {
        if [[ -z $Result ]]; then
                Print_Red "Nothing Host or Nothing Group"
        else
                Print_Green "$Result"
        fi
        }
	Check_Input () {
	DB_Info
	
        Group=`$Con -e " select Groups from sadb.user where Name='$User' and Status='enable'" | sed "1d"`
	if [[ -z $Group ]]
	    then
		Print_Red "Your Count is disable"
		break
	else
        Host_List=`$Con -e "select IP,Hostname from sadb.host where Groups='$Group'" | sed "1d"`
	echo "Host_List" | grep -w  "$rs" >/dev/null
	[ $? -ne 0 ] && Print_Red "You do not have permission to login"
	break
	fi
	}
}
Menue() {
Print_Green "
*************************************************
*   User:$User					*	
*   Date:$Date		*
*************************************************

"

cat  << menue
         `Print_Purple "
        1) L, l      Select Host List
        2) G, g      Select Host Group
        3) E, e      Batch Send Commond
        4) H, h      Get Some Help
        5) Q, q      Exit This Login 
"`
menue
}
DB_Info () {
	User=`whoami`
        Date=`date`
	DB_User="guest"
	DB_Passwd="guest"
        Host="192.168.254.5"
        Port="3306"
        Con="mysql -u $DB_User -p$DB_Passwd -h $Host -P $Port"

}
Jumper() {
	DB_Info
	List () {
		Group=`$Con -e " select Groups from sadb.user where Name='$User'" | sed "1d"`
		Host_List=`$Con -e "select IP,Hostname from sadb.host where Groups='$Group'" | sed "1d"`
		Result="$Host_List"
		Display_Result
	}
	Group () {
		Group=`$Con -e " select Name,Groups from sadb.user where Name='$User'" | sed "1d"`
		Result="$Group"
		Display_Result
	}
	Commond () {
		Print_Yellow "Host: "   ;  read -p "" host
		Print_Yellow "Commond: " ; read -p "" comm
		for i in `echo $host` ; do 
		   ssh $User@$i "$comm"
		done
	}
}

Obey() {
	clear
	Color
	Check_Variable
	Jumper
	Menue
while true
do
 #       Trapper
        Print_Yellow  "IP or Option:" ; read -p "" rs
        case $rs in
                L|l)
                        List
                        ;;
                G|g)
                        Group
                        ;;
                E|e)
                        Commond
                        ;;
                H|h)
                        break
                        ;;
                Q|q)
                        exit
                        ;;
                *)
			if [ -z $rs ]
			   then
				List
			else
				Check_Input
				ssh $User@$rs
			fi
                esac
done

}
while true 
do
Obey
done
