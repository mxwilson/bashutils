#!/bin/bash

#email-sig-generator.sh
#Generates an e-mail signature for use in an e-mail client like Thunderbird.

# (c) 2017 MWILSON - <http://www.github.com/mxwilson/>
#License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

thecompanyname="Company Limited"
theaddress="123 Rue Saint-Denis, Montréal, Québec H0H-0H0"
thephonenum="514-900-9000"

while [ -z "$thename" ] ; do
	read -p "Name?: " thename
done

while [ -z "$postitle" ] ; do
	read -p "Position/Title?: " postitle
done

while [ -z "$telextension" ] || ! [[ "$telextension" =~ ^[0-9]+$ ]] ; do
	read -p "Phone extension?: " telextension
done

outputfile=$( cat << EOF
<meta charset="utf-8">
<p style="font-family:Helvetica,Arial,sans-serif;font-size:9pt;line-height:=1.3;">
$thename
<br>
$postitle<br>
<br>
<strong>$thecompanyname</strong><br>
$theaddress
<br>
Tel: $thephonenum ext. $telextension
<br>
<br>
<table border="0" cellspacing="0">
<tbody>
<tr>

<td>
<a href="http://www.$thecompanyname.com" target="_blank" title="$thecompanyname"><img src="http://www.$thecompanyname.com/image.jpg" width="25" height="25" border="0" alt="$thecompanyname"></a>
</td>

<td>
<a href="http://twitter.com/$thecompanyname" target="_blank" title="Twitter"><img src="http://www.$thecompanyname.com/twitter.jpg" width="25" height="25" border="0" alt="Twitter"></a>
</td>

<td><a href="http://www.facebook.com/$thecompanyname" target="_blank" title="Facebook"><img src="http://www.$thecompanyname.com/facebook.jpg" width="25" height="25" border="0" alt="Facebook"></a>
</td>

<td><a href="http://www.linkedin.com/company/$thecompanyname" target="_blank" title="LinkedIn"><img src="http://www.$thecompanyname.com/linkedin.jpg" width="25" height="25" border="0" alt="LinkedIn"></a>
</td>

<td>
<a href="http://www.$thecompanyname.com/news.rss" target="_blank" title="RSS news feed"><img src="http://www.$thecompanyname.com/rss.jpg" width="25" height="25" border="0" alt="RSS feed"></a>
</td>
</td>
</tr>

</tbody>
</table>
</p>
EOF
)

if [ -e ./"$thename".htm ]; then
	echo "ERROR: ./$thename.htm exists. Exiting."
	exit 1
else
	printf "$outputfile" > ./"$thename".htm
	echo "SAVING SIGNATURE FILE FOR: ./$thename.htm"
fi

exit 0
