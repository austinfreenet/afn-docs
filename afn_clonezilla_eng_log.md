# Austin FreeNet(AFN) Clonezilla Engineering Log

## 2014-07-08

I've resurrected the clonezilla project using the [old VM and
doc](https://drive.google.com/#folders/0B9PvuYOYLXoTb3NYZ21kZ212Nkk).
I've mounted the old BTOPS image and am imaging a client right now to
make sure everything still works.  I read about proxydhcp last night.
Let's use that so we don't have to run our own DHCP server.  The plan
was to get it working with a USB key but with proxydhcp I don't think
we need to do that.  Let's jump right to PXE boot.

So the test imaging went perfectly. Now to knock out these:

### TODO

   1. <del>Image a client to make sure everything still works</del>
   1. <del>Put back in the menu so admins can select the image they want</del>
   1. <del>get proxydhcp working</del>
      * <del>remove dhcpd and install dnsmasq</del>
      * <del>configure dnsmasq for proxydhcp</del>
      * <del>test using an existing DHCP server</del>

Run `dcs` to try to setup a menu to select images.  Total fail.  Now the client
doesn't even boot all the way.  Running `drblpush -i` to try to recover.  Ok the
recovery went well.  Now I'm trying to figure out how to add the menu.  Trying
to use the [Clonezilla Live option in
DRBL](http://clonezilla.org/clonezilla-SE/use_clonezilla_live_in_drbl.php).


## 2014-07-15

Doing a test clone to see where I left off.  It's still using the old Debian
image that auto clones.  Rerunning `drblpush -i`.  So now clonezilla live is
booting but I don't get a menu, just a unix login prompt.

## 2014-7-22

Looking for clonezilla alternatives.  Found Mondo Rescue.
Nope... looks like clonezilla is the magic.  Change `ocs_live_run` in
`/tftpboot/nbi_image/pxelinux.cfg/default` to ocs-live-general.  Can't get the
Clonezilla Live UI to start.  The boot is failing at the end with an error about
sudo and mkpasswd.  I'm googling trying to fix it now.  Let's try upgrading the
whole image to latest.  Stopped the upgrade.  I added `live-config` to the boot
params and that worked!  Now let's figure out how to preseed the config options.

## 2014-7-29

I think we have to tweak the pxeloader boot parameters to set the menu
the way we want.  Setting `ocs_live_run` to `ocs-sr...` with `ask_user` where
we should pause and ask the user seems to do the trick.  Now let's get dhcpproxy
working.

## 2014-8-12

Googling dhcpproxy drbl to see if I can get it working.  Following these steps:
[http://sourceforge.net/p/drbl/discussion/Open_discussion/thread/fe0626d0](http://sourceforge.net/p/drbl/discussion/Open_discussion/thread/fe0626d0).  I had
to not use the IPAPPEND 1 option because it messes up the boot.  I removed
isc-dhcp-server and tftpd-hpa since dnsmasq provides tftp now.  Put wildcard
host match in /etc/exports so that the exported filesystems would be
available to all clients.

So the client boots but can't get an IP address.  Played around with IPAPPEND
[1|2] which appends stuff to the boot params but still nothing.  udhcpc in the
initramfs gets an IP address but doesn't set the IP on eth0.  Not sure what's
going on.

## 2014-8-19

Time to debug proxy DHCP and debian-live IP address stuff.
It looks like we can toggle between save and restore
using the boot menu(cool)!  Here's a [guy with the same
issue](https://lists.debian.org/debian-live/2012/04/msg00032.html).

I modified Clonezilla-live-initrd.img like this:

    diff -Naur Clonezilla-live/lib/live/boot/9990-networking.sh Clonezilla-live_new/lib/live/boot/9990-networking.sh
    --- Clonezilla-live/lib/live/boot/9990-networking.sh  2014-08-19 12:23:06.000000000 -0500
    +++ Clonezilla-live_new/lib/live/boot/9990-networking.sh  2014-08-19 12:20:52.000000000 -0500
    @@ -109,7 +109,11 @@
        done
      else
        for interface in ${DEVICE}; do
    -     ipconfig -t "$ETHDEV_TIMEOUT" ${interface} | tee /netboot-${interface}.config
    +     if [ -n "${STATICIP}" ]; then
    +       ipconfig -t "$ETHDEV_TIMEOUT" ${interface} ip="${STATICIP}" | tee /netboot-${interface}.config
    +     else
    +       ipconfig -t "$ETHDEV_TIMEOUT" ${interface} | tee /netboot-${interface}.config
    +     fi
    
          # squeeze
          [ -e /tmp/net-${interface}.conf ] && . /tmp/net-${interface}.conf

## 2014-8-26

I setup the save menu and fixed the timeout on boot so now you can save and
restore images.  Next I should get the IP for pxelinux.cfg/default to change
when eth0 gets a new dhcp address.  Also auto reboot at the end.

## 2015-03-03

Exporting the virtualbox image as an appliance.

## 2015-06-22

John asked me to set the boot screen timeout to nothing so you have to choose.

## 2015-08-11

John asked me to have flamethrower(multicast) cloning working be the end of next
week.  I found a [really good
article](http://oakdome.com/k5/tutorials/computer-cloning/free-computer-cloning-step-4-2.php)
on clonezilla multicast restore.  It seems pretty simple.  The first thing is
snapshotting our current clonezilla server image.  Next I need to find a test
client.  I'm using one of the Thinkpad T61's on the desk here.  John asked me to
save the current image and use that for my restore test.
