#!/bin/bash

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

#BASHCRYPT 0.1 ENCRYPT OR DECRYPT FILES USING SSL AND AES-256 
#(C)2014 MWILSON
#TESTED ON BASH 4.3.30 / UBUNTU 14

clear

echo "bashcrypt 0.1"
while [ -z "$bigquestion" ]
do
echo "Encrypt or Decrypt? (e/d) " ; read -r bigquestion
done

if [[ $bigquestion = "e" || $bigquestion = "E" ]] ; then 

	while [ -z "$filetoenc" ]
	do
	echo "Name of file to encrypt: " ; read -r filetoenc
	done

	if [ -a "${filetoenc}.enc" ] ; then
	echo "${filetoenc}.enc already exists."
	echo "Overwrite? (y/n)"
	read -r owq 

	if [[ $owq = "y" || $owq = "Y" ]] ; then
	openssl aes-256-cbc -a -salt -in ${filetoenc} -out ${filetoenc}.enc
	echo "${filetoenc} encrypted as ${filetoenc}.enc"

	else
		exit
	fi

	elif [ ! -f "${filetoenc}" ] ; then
	echo "File does not exist"
	exit

	elif [ -a "${filetoenc}" ] ; then
	openssl aes-256-cbc -a -salt -in ${filetoenc} -out ${filetoenc}.enc
	echo "${filetoenc} encrypted as ${filetoenc}.enc"
	exit

	else
		exit
fi

elif [[ $bigquestion = "d" || $bigquestion = "D" ]] ; then

	while [ -z "$filetodec" ]
	do
	echo "Name of file to decrypt? " ; read -r filetodec
	done

	if [ ! -f "$filetodec" ] ; then
	echo "File does not exist"
	exit

	elif [ -a "$filetodec" ] ; then
	openssl aes-256-cbc -d -a -in ${filetodec} -out ${filetodec}.new
	echo "${filetodec} decrypted as ${filetodec}.new"
	
	else
	exit

	fi

else
exit

fi