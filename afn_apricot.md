# AFN Apricot Integration

## 2016-10-4

Apricot doesn't want to budge on the VPN solution.  They must have got hit hard.
John wants to figure out how to make it work today.  John will setup a machine
with Debian stable and I'll start work on it next week.

## 2016-10-11

I have the creds for the DO box.  Let's get a linux tunnel up and running from a
VM to make sure I can do it without borking the networking.

## 2016-10-12

Got the VM up and running... now installing Vbox guest additions.  Running
`apt-get build-dep virtualbox-guest-dkms`.  So it's working and I have a
snapshot.  I'm installing network-manager-vpnc to try to setup the vpn from
network-manager.  Ok so vpnc is for Cisco.  I think we need to find ipsec.
I'm trying strongswan-nm.

Ok so that didn't work.  Let's try
[l2tp](http://sysadmin.compxtreme.ro/setting-up-a-l2tp-over-ipsec-vpn-on-debian-on-10-steps/)

[This](http://www.jasonernst.com/2016/06/21/l2tp-ipsec-vpn-on-ubuntu-16-04/) seems the most promising.  However QC is filtering VPN traffic on Hydra.  I was able to UDP port scan(`sudo nmap -sU odbc.apricot.info`) from home and see port 500(the ipsec port) but it didn't show up when I scanned from stark on Hydra.  So let's move the VM home and continue from there.

## 2016-10-18

Ok so it's up and running using [these
instructions](http://www.jasonernst.com/2016/06/21/l2tp-ipsec-vpn-on-ubuntu-16-04/)!  However, the mysql connection is failing with access denied:

    tubaman@debian-vm:~$ mysql -uAFN --password=[password] -h Apridbro1.ec2.internal
    ERROR 1045 (28000): Access denied for user 'AFN'@'10.35.2.21' (using password: YES)

John is checking with apricot support to make sure our credentials are
correct.  Perhaps I need to actually use ODBC instead of raw mysql?

Login to mysql like this: `mysql -uodbc_1643 -p[password] -h Apridbro1.ec2.internal apricot_1643`

FYI: here's the VPN login info:

    * Username: AFN
    * Password: [password]
    * Server: Apridbro1.ec2.internal

Now let's get it working on DO.  Note: *DO NOT* change the default route!
You'll lock yourself out of ssh.

Ok so I copied all of the files from my VM to the DO droplet and followed the
blog entry above and we're up.  I've run `apt-get install mysql-client` so I can
test the mysql connection.

Well I hooked my `start_vpn` script into /etc/network/interfaces on "up".  Now
the machine is deadlocked at boot.  I've had John recreate the droplet.

## 2016-10-22

I logged into the new droplet that John created.  I got the VPN up and running.
I
[modded](http://askubuntu.com/questions/293705/how-do-i-control-the-order-of-nameserver-addresses-in-resolv-conf)
the order of the intefaces in resolvconf so that the vpn DNS server would take
precedence.  Now Apridbro1.ec2.internal resolves.  I put the following in root's crontab so this should keep the vpn up:

    SHELL=/bin/bash
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

    # m h  dom mon dow   command
    */5 *   *   *   *    vpn status || vpn reset

`apt-get install socat` so I can use that to port forward instead of
iptables.  I'm less likely to lock myself out that way.

Here's our `/usr/local/bin/vpn` script:

    #!/bin/bash

    function start() {
    	mkdir -p /var/run/xl2tpd
    	touch /var/run/xl2tpd/l2tp-control
    	echo "starting ipsec"
    	ipsec up apricot-odbc
    	echo "starting l2tp"
    	echo "c apricot-odbc AFN [vpnpassword]" > /var/run/xl2tpd/l2tp-control

    	echo "waiting 30 secs for ppp interface to come up"
    	START=$(date +%s)
    	while [ $(date +%s) -lt $(($START + 30)) ]; do
    		if ifconfig | grep ppp; then
    			route add -net 10.0.0.0/8 gw 10.254.128.254
    			nohup socat TCP-LISTEN:3306,fork TCP:Apridbro1.ec2.internal:3306 > /dev/null &
    			break
    		fi
    		sleep 1
    	done
    }

    function stop() {
    	pkill socat
    	route del -net 10.0.0.0/8 gw 10.254.128.254
    	ifconfig ppp0 down
    	ipsec down apricot-odbc
    	service xl2tpd restart
    	service strongswan restart
    }

    function status() {
    	if echo 'show tables;' | mysql -uodbc_1643 -p'[password]' -h Apridbro1.ec2.internal apricot_1643 > /dev/null && pgrep socat > /dev/null; then
    		echo "up"
    		return 0
    	else
    		echo "down"
    		return 2
    	fi
    }

    case $1 in
    	start )
    		start
    		;;
    	stop )
    		stop
    		;;
    	restart | reset )
    		stop
    		start
    		;;
    	status )
    		status
    		;;
    esac

## 2016-11-1

This is how to use the new mysql apriocot VPN:

    echo 'show tables;' | mysql -uodbc_1643 -p'[password]' -h 45.55.133.102 apricot_1643

Let's create a log file to keep track of when the VPN is up and when it's down.
We might also want to setup split DNS in the future.

We should also add a IP whitelist on port 3306.

## 2016-11-8

I'm using logger in the /usr/local/bin/vpn script now to log stuff to
syslog(/var/log/syslog).

We should be able to use [this
technique](http://unix.stackexchange.com/questions/145929/how-to-ensure-ssh-port-is-only-open-to-a-specific-ip-address)
to whitelist our IP only for port 3306.

I've installing fail2ban to prevent brute force attacks on ssh and mysql.

To edit the IP whitelist:

   1. Comment out the cronjob: `sudo crontab -e`
   2. Run `sudo vpn stop`
   3. Edit `/usr/local/bin/vpn` and add/change the IPs in the `ALLOWED_IPS` at
      the top of the script.  `ALLOWED_IPS` should be a quoted list of
      space-delimited IP addresses.
   4. Run `sudo vpn start`
   5. Uncomment the cronjob: `sudo crontab -e`
