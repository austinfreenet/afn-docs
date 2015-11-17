# Austin FreeNet WAN Load Balancing

AFN has 3 DSL connections coming in.  John would like to load balance
LAN->Internet traffic across all 3 DSL lines.  I found
[http://lartc.org/howto/lartc.rpdb.multiple-links.html](a)
[https://www.pfsense.org/download/mirror.php?section=downloads](few)
[http://wiki.openwrt.org/doc/howto/mwan3](links).

I think I'm going to try debian/shorewall/webmin first.  Clonezilla
restoring my fresh jessie install to the test box.

## 2015-06-22

I'm installing shorewall now.  I'm installing
[webmin](http://www.webmin.com/deb.html) now.  Now I probably need to configure
shorewall.  I'll probably need to wait until the NICs are in place before
really doing anything.  I'm going to install nagios to monitor the outbound WAN
links.  Here's how to configure shorewall for
[multi-ISP](http://shorewall.net/MultiISP.html).

Note - Here are the passwords:

   * ssh - username: root, password: [our standard admin password]
   * webmin - username: root, password: [our standard admin password]
   * nagios - username: nagiosadmin, password: [our standard admin password]

There doesn't appear to be any webmin module for nagios :(

## 2015-07-14

So I enabled Intel Virtualization in the BIOS to get rid of a boot error
message.  I also added contrib and non-free to /etc/apt/sources.list and
apt-get installed firmware-realtek to get rid of the realtek firmware
error message on boot.

I've got the staff network plugged into the onboard eth0 and the north network
plugged into eth1(first port on the quad NIC).

I setup the /etc/shorewall/providers file with 2 providers to test.

Ok, let's backup and get the router working with only one provider first.  Ok,
so after some monkeying around with /etc/init.d/shorewall stop,start the we're
up and routing from eth4 to eth0.  Next we'll try to get the load balancing
working across 2 providers.

## 2015-07-28

Trying to get going again.  I've added sbin to user's PATH.  I had to
put a static ip on cuisine of 10.0.0.10 with a gateway of 10.0.0.1.
Then I put a static ip on the router eth4 of 10.0.0.1.  Then I had to
restart shorewall.  Routing works again.  I downed eth1 on the router
because I wasn't able to ping the gateway there.

The router is now on a KVM.  I need to make sure the monitor is in digital mode
to see stuff.

## 2015-8-4

Ok so I can't ssh into the router when the firewall is on.  I'll need to fix
that.  I added this to `policy`:

    #SOURCE         DEST            POLICY
    all             fw              ACCEPT

That seems to fix it.  So now let's follow the howto for shorewall
[multi-ISP](http://shorewall.net/MultiISP.html).  I'm using the [hot new
way](http://shorewall.net/MultiISP.html#USE_DEFAULT_RT).  With `USE_DEFAULT_RT`
it's recommended to ignore gateway from the DHCP server.  So [let's do
that](http://serverfault.com/questions/29394/debian-interfaces-file-ignore-gateway-and-dns-entries-from-dhcp).
I'm installing tcpdump so I can see packets going out each interface.
It totally works!  I'm pinging from my laptop and I've seen some ping
sessions go out eth0 and others go out eth1.  Plus I'm able to web surf
and ssh.

## 2015-9-29

I'm back on this router project today.  I'm running an `apt-get upgrade`.  Ok,
I'm connected from my laptop to the gateway via eth4.  I don't have dhcpd
running on the gw so I have a static IP set on my laptop.  I've verified that
our load balancing still works from last time so let's setup
[failover](http://shorewall.net/MultiISP.html#LinkMonitor).

Let's test reboot first.  So shorewall doesn't come up on boot yet.
After boot I had to do the following:

   1. `/etc/init.d/shorewall start`
   2. `ifconfig eth4 10.0.0.1`
   3. `ifconfig eth4 up`

That all works fine.  We can fix reboot later.  It looks like
[LSM](http://lsm.foobar.fi/) [isn't
packaged for Debian](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=518165)
so let's compile it from source.  I'm doing an `apt-get install
build-essential`.  Let's make a quick Debian package out of it using
`checkinstall`.  I changed all references to `/usr/libexec` to `/usr/lib` in the
lsm sources because `/usr/lib` is in the FHS and libexec isn't.  Ok so now lsm
is installed.  Next we need to configure it.

## 2015-10-07

Ok, so today let's get LSM configured.  Let's add varables for each wan
interface to `/etc/shorewall/params` so that we can reference them in the LSM
configs.  Ok, I have all the files setup.  Now I'm creating directories that lsm
needs.  So when an interface goes down, LSM seems to work but when it comes back
up it doesn't get put back into the rotation.  I'll have to look into that next
time.

## 2015-10-13

Well, it turns out that failback is working, it just takes a bit of time.
I think it's time for a demo.  It takes quite a while for an interface to be
added back into the rotation(~ 4 minutes or so).

## 2015-11-03

Let's get the UI up and running.  So [webmin](https://10.0.0.1:10000/)
is up and running with the shorewall module.  I also need to get shorewall
starting on boot.  Let's reboot and check the log.  So it turns out that
everything was starting correctly except for the LAN interface.  So I added a
stanza to `/etc/network/interfaces` for eth4 and rebooted.  Everything came up
fine.  So I've backed up `/etc/` as a tarball on my laptop.  Next time
let's try to add/remove interfaces using the GUI.

So when an interface is added back after remove it, the SNAT rule:

    Chain eth0_masq (1 references)
    target     prot opt source               destination
    SNAT       all  --  10.0.0.0/24          anywhere             to:192.168.0.102

...doesn't get put back into place.  We'll have to look into this.

## 2015-11-10

There was a fat finger in `/var/lib/shorewall/firewall` so I fixed that.  Now
the firewall script should work fine.  It turns out that that firewall script is
compiled at start.  The fat finger was really in `/etc/shorewall/lib.private` so
I fixed it there.  Let's reboot to test.  Well the firewall script runs fine now
but the SNAT rules still don't get put into place.

Ok so I changed the 3rd column in `/etc/shorewall/masq` from detect to
blank(nothing).  That seems to make shorewall come up at boot just fine.

Well after a bunch of plug/unplug tests, the firewall turned itself off
altogether and no packets were passing.  I'll have to figure out why.

## 2015-11-17

Well it turns out that the north network(192.168.1.0/24) is dropping packets.
So John set me up with a connection to the south network(192.168.2.0/24)
instead.  I swapped out the config in `/etc/shorewall` and things seem to be
humming along.  Now let's play around with our MASQ problem.  Well I can't seem
to recreate the MASQ problem by ifdown'ing.  Let's try unplugging the cable.

I changed the 3rd column in `/etc/shorewall/masq` from black back
to detect to see if that fixes my packet loss issue.  It doesn't
look like it.  It seems that the packet loss only happens on the
south(192.168.2.0/24) network.
