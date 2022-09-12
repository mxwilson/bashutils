## Openfortivpn client wrapper

This is a Bash wrapper script to start and stop the Openfortivpn Linux client (https://github.com/adrienverge/openfortivpn). Tested on Rocky Linux 8.6 but should work for most distros. Requires sudo.


# Usage

To start:

$ vpn 

To stop:

$ vpn --kill


# How to install

Adjust your Openfortivpn config file at: /etc/openfortivpn/config

Copy vpn.sh to: /usr/bin/ and create a link to the file: 

$ sudo ln -s vpn.sh vpn

Add the following entries to sudoers file with your username and host:

$ sudo visudo 

youusername yourhostname = (root) NOPASSWD: /usr/bin/openfortivpn


yourusername yourhostname  = (root) NOPASSWD: /usr/bin/kill

And create a logfile:

$ sudo touch /var/log/vpn_log.log


## License

GNU General Public License v3.0
