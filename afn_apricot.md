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
