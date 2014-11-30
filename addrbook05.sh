#!/bin/bash
#ADDRBOOK 0.5 - (c) 2014 MWILSON 

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

#ADDRBOOK - SIMPLE FLAT FILE ADDRESS MANAGER
#TESTED ON BASH 4.3.30 / UBUNTU 14



#read contacts file - or create if not exist
[ -f "./pbook.data" ] && contacts_number="$(sed -n '$=' pbook.data)" || touch ./pbook.data

#FOR CONFIRMATION WHEN ADDING CONTACTS
function NAMECONF () {
  clear
  while [ -z "$first_name" ]
  do
  echo "First name?"
  read -r  first_name
  done

  while [ -z "$last_name" ]
  do
  echo "Last name?"
  read -r last_name
  done

  while [ -z "$ph_num" ]
  do
  echo "Phone number? (10 digits, no dashes)"
  #THE -E BELOW ALLOWS BACKSPACE ON READING A NUMBER WITH -N
  read -r -n 10 -e ph_num
  done

  #CONFIRM IF INFO IS CORRECT
  clear
  echo "$last_name, $first_name, $ph_num"
  echo " "
  read -r -p "Is this correct? (y/n)" response

  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
  then
      #NOW APPEND IT TO THE FILE
      echo "$last_name, $first_name, $ph_num" >>  pbook.data
      unset -v last_name first_name ph_num
  else
      #CALL THE FUNCTION IF NOT CORRECT
      unset -v last_name first_name ph_num
      #unset -f NAMECONF
      NAMECONF
  fi

  }

#FOR CONFIRMATION WHEN UPDATING CONTACTS
 
function UPDATECONTACTCONF () {
    
  while [ -z "$Nfirst_name" ]
  do
  printf "\nOld first name:"
  ofn="$( cut -d ',' -f 2 <<< "$yoyo" )"; echo "$ofn"
  printf "\nNew first name? "
  read -r  Nfirst_name
  done

  while [ -z "$Nlast_name" ]
  do
  printf "\nOld last name:"
  oln="$( cut -d ',' -f 1 <<< "$yoyo" )"; echo " $oln"
  printf "\nNew last name? "
  read -r Nlast_name
  done

  while [ -z "$Nph_num" ]
  do
  printf "\nOld phone number:"
  olphn="$( cut -d ',' -f 3 <<< "$yoyo" )"; echo "$olphn"
  printf "\nNew phone number? (10 digits, no dashes) "
  read -r -n 10 -e Nph_num
  done
  
  #CONFIRM IF INFO IS CORRECT
  clear
  printf "$Nlast_name, $Nfirst_name, $Nph_num\n\n"
  read -r -p "Is this correct? (y/n) " response

  	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
  		then
  		#NOW APPEND IT TO THE FILE
  		printf "\nOK. So: Updating contact from: "
  		echo "$yoyo"	    
  		printf "To: $Nlast_name, $Nfirst_name, $Nph_num\n"
  		echo " "
  		sed -i "/$yoyo/c $Nlast_name, $Nfirst_name, $Nph_num" ./pbook.data
  		echo " "
      
  	else
  		#CALL THE FUNCTION IF NOT CORRECT
  		unset -v Nlast_name Nfirst_name Nph_num
  		UPDATECONTACTCONF
  	fi
      }
    
  
clear

PS3="ADDRBOOK 0.5 -- OPTION SELECTOR: "

options=('LIST CONTACTS ALPHABETICALLY' 'ADD CONTACT' 'REMOVE CONTACT' 'UPDATE CONTACT' 'QUIT')
	  
  	 
select opt in "${options[@]}"
          do    	       
                # options[5]="q" - assign something to array 
                #possible quit - not sure yet
       
          if [ "$opt" = "QUIT" ]; then
            echo done
            exit

          elif [ "$opt" = "LIST CONTACTS ALPHABETICALLY" ]; then
            somevar="$(cat ./pbook.data | sort -f )"
            #echo ${options[5]}
            clear
            
            contacts_number="$(sed -n '$=' pbook.data)"

            if [[ $contacts_number -ge "1" ]] ; then
            		printf "Number of contacts: $contacts_number\n\n"
    		else 
    			echo No contacts :/
    		fi
    		
            echo "$somevar"
            echo " "
            
          elif [ "$opt" = "ADD CONTACT" ]; then

            NAMECONF

          elif [ "$opt" = "REMOVE CONTACT" ]; then

            echo "Enter name of contact to delete:"

            read -r cont_to_del
            somenewvar="$(grep -i $cont_to_del ./pbook.data)"
            echo " "
            printf "$somenewvar"
            echo " "
            echo " "
            printf "Is this correct to delete? (y/n)"
            read -r -n 1 big_question

            if [ "$big_question" = "y" ] ; then
            sed -i "/$somenewvar/d" ./pbook.data
            echo " "
            echo "OK. $somenewvar deleted."
            fi
    
          elif [ "$opt" = "UPDATE CONTACT" ]; then
            clear
            echo "Enter name of contact to update"
            read -r cont_to_update
            yoyo="$(grep -i $cont_to_update ./pbook.data)"
            echo " "
            echo "$yoyo"
            echo " "
            echo "Is this correct? (y/n)"
            echo " "
            read -r -n 1 -s bigger_question
            
            	if [ "$bigger_question" = "y" ] ; then
            	    UPDATECONTACTCONF 
            	fi
    	
          elif [ "$opt" = "q"]; then
            exit

          else
            clear
            echo bad option
           fi
       done
