#!/bin/bash

#SQLADDRBOOK - (c) 2014 MWILSON
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#GNU General Public License for more details.
#You should have received a copy of the GNU General Public License
#along with this program. If not, see <http://www.gnu.org/licenses/>.
#SQLADDRBOOK - SIMPLE MYSQL ADDRESS MANAGER

#TESTED ON BASH 4.3.30 / UBUNTU 14 / MYSQL 5.5.40

user=YOURUSERNAME # USERNAME OF MYSQL USER
psw=YOURPASSWORD  # PASSWORD FOR MYSQL USER
database="ADDRBOOKDB" # THIS DB WILL BE CREATED
query3="SELECT CONCAT(firstname, ',', lastname, ',', phnum) FROM contacts;"  # list all
query4='SELECT COUNT(*) FROM contacts;' # get number of contacts

#DELETING A CONTACT PROCEDURE

function DELETECONTACT () {

clear

contacts_number=$(mysql -u${user} -p${psw} ${database} -N -e "${query4}")

if [[ $contacts_number -lt "1" ]] ; then
        echo No contacts :/
        return 0

	else
	while [ -z "$cont_to_del" ]
	do
	echo "First name of contact to delete?" ; read -r cont_to_del
	done

query5="SELECT CONCAT(firstname, ',', lastname, ',', phnum) FROM contacts WHERE firstname='$cont_to_del'"

# load query into array

while read namelist
do
myarray+=("$namelist")
done < <(mysql -u${user} -p${psw} ${database} -N -e "${query5}")

#print the concatenated array as a numbered list

for i in "${!myarray[@]}"; do
printf "%s\t%s\n" "$i" "${myarray[$i]}"
done
echo " "
echo "Number of entries matching: ${#myarray[@]}" # GETS NUMBER OF ITEMS IN AN ARRAY
fi

if [ ${#myarray[@]} -eq 0 ] ; then
echo "!! WARN: No matching contacts :/"
unset cont_to_del
return 0
fi

#DELETE JUST SINGLE CONTACT
unset rresponse

if [ ${#myarray[@]} -eq 1 ] ; then

	while [ -z "$rresponse" ]
	do
	printf "\n\nIs this correct? (y/n)" ; read -r rresponse
	done

if [[ $rresponse =~ ^([yY][eE][sS]|[yY])$ ]] ; then
printf '\n!! ALERT: DELETING CONTACT\n'
mysql --user="$user" --password="$psw" --database="$database" <<EOF
DELETE FROM contacts WHERE firstname='$cont_to_del';
EOF
unset cont_to_del rresponse myarray
return 0

else
unset cont_to_del rresponse myarray
return 0

fi

fi

#IF IT IS GREATER THAN ONE, SPECIFY A LAST NAME, THEN PRINT BOTH TO CONFIRM
unset response

if [ ${#myarray[@]} -gt 1 ] ; then
echo " "
echo "Multiple matching contacts. Please specify last name:"

while [ -z "$lastname_search" ]
do
read -r lastname_search
done

query6="SELECT CONCAT(firstname, ',', lastname, ',', phnum) FROM contacts WHERE firstname='$cont_to_del' AND lastname='$lastname_search'"
lastnameq=$(mysql -u${user} -p${psw} ${database} -N -e "${query6}")

#DO A CUT OF THE QUERY OUTPUT IN 2ND SLOT AND COMPARE WITH LASTNAME SEARCHED

lncompare="$( cut -d ',' -f 2 <<< "$lastnameq" )"; echo "$lncompare"

if [ "$lastname_search" = "$lncompare" ] ; then
    while [ -z "$response" ]
    do
      printf "\n\nIs this correct? (y/n)" ; read -r response
    done

        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]] ; then
          printf '\n!! ALERT: DELETING CONTACT\n'
          mysql --user="$user" --password="$psw" --database="$database" <<EOF
          DELETE FROM contacts WHERE firstname='$cont_to_del' AND lastname='$lastname_search';
EOF

          unset cont_to_del lastname_search myarray lastnameq lncompare query6

          else
            unset cont_to_del lastname_search myarray lastnameq lncompare query6
            return 0
          fi

else
unset cont_to_del lastname_search myarray lastnameq lncompare query6
echo "!! WARN: No matching contacts :/"
return 0
fi

fi
}

###### ADDING NEW CONTACT PROCEDURE

function NAMECONF () {

clear

while [ -z "$fn" ]
do
echo "First name?"
read -r fn
done

while [ -z "$ln" ]
do
echo "Last name?"
read -r ln
done

while [ -z "$pn" ]
do
echo "Phone number?"
read -r -e pn
done

#CONFIRM IF INFO IS CORRECT
clear
echo "$ln, $fn, $pn"
echo " "
read -r -p "Is this correct? (y/n)" response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
    #NOW ADD TO SQL
mysql --user="$user" --password="$psw" --database="$database" << EOF
INSERT INTO contacts (firstname,lastname,phnum) values('$fn','$ln','$pn');
EOF
unset -v ln fn pn

else
    #CALL THE FUNCTION IF NOT CORRECT
    unset -v ln fn pn
    NAMECONF
fi

}

clear

DBEXISTS=$(mysql -u $user -p$psw --batch --skip-column-names -e "SHOW DATABASES LIKE '"$database"';" | grep "$DBNAME" > /dev/null; echo "$?")

#DETERMINE IF DB EXISTS. IF NOT, WILL CREATE ONE USING $DATABASE VARIABLE AT TOP

if [ $DBEXISTS -ne 0 ] ; then

mysql --user="$user" --password="$psw" << EOF
CREATE DATABASE $database;
USE $database;
CREATE TABLE contacts (firstname VARCHAR(20), lastname VARCHAR(20), phnum VARCHAR(20));
EOF

fi

#MAIN MENU

PS3="SQLADDRBOOK -- OPTION SELECTOR: "

options=('LIST CONTACTS' 'ADD CONTACT' 'REMOVE CONTACT' 'QUIT')

select opt in "${options[@]}"
do

if [ "$opt" = "LIST CONTACTS" ]; then
	#LIST ALL CONTACTS
	printf "\033c"
	printf "Listing all contacts\n\n"
	unset myarray

	while read namelist
	do
	myarray+=("$namelist")
	done < <(mysql -u${user} -p${psw} ${database} -N -e "${query3}")
        echo ${myarray[@]} | sed 's/ /\n/g' | sort  # <<<-alpha sort and echo
        contacts_number=$(mysql -u${user} -p${psw} ${database} -N -e "${query4}")

        	if [[ $contacts_number -ge "1" ]] ; then
        		printf "\nNumber of contacts: $contacts_number\n\n"
              		unset myarray
		else
               		echo No contacts :/
             	fi

             	elif [ "$opt" = "ADD CONTACT" ]; then
             		NAMECONF

             	elif [ "$opt" = "REMOVE CONTACT" ]; then
             		DELETECONTACT

             	elif [ "$opt" = "QUIT" ]; then
             		exit
             	else
             		clear
             		echo bad option
             	fi
       done
