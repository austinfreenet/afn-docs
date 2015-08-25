# Austin Free-Net VM Project

This is my engineering notebook for the VM project

## 2014-04-22

I need to reset the Buffalo Router to the default settings so I can login and
flash with OpenWRT.  I downloaded
[OpenWRT](http://downloads.openwrt.org/attitude_adjustment/12.09/brcm47xx/generic/openwrt-wrt54g-squashfs.bin)
and flashed.  I figure I'll have to route over wifi so I setup the WAN to [use
the wifi as a
client](http://wiki.openwrt.org/doc/recipes/routedclient#using.routing).

The OpenWRT username:password is root:admin

## 2014-04-30

John set me up in the closet with a network managed powerstrip and an ethernet
drop.  I need to configure OpenWRT to use the ethernet as WAN now.  I reset to
factory defaults which was dumb because I lost my VPN setup :(.
Recreating now.  I had to convert the openssh key to dropbear key format by
installing the dropbear convert opkg.

Here's the little vpn script I'm using.

    #!/bin/sh
    
    while true; do
      ssh -T -N -i /root/.ssh/id_rsa  -R 2224:localhost:22 secvpn@fattuba.com
    done

That's run from rc.local like `/usr/bin/vpn_to_fattuba &`.

I'm having trouble getting the vpn to come up on boot in rc.local.  I've added
logging: `/usr/bin/vpn_to_fattuba > /var/log/vpn_to_fattuba.log 2>&1 &`.

It's a known\_hosts problem.  For some reason, when running from rc.local ssh
doesn't recognize /root/.ssh/knowwn\_hosts.  I've copied it to /etc/dropbear to
see if that works.  That didn't work.  I found /.ssh.  That's probably it.  I'll
copy known\_hosts there.  That looks like it.  Rebooting the router to do a
final test.

The powerswitch is setup as 192.168.1.10 and the server as 192.168.1.11

## 2014-05-06

John had to reboot the router this morning for some reason.  I've put
/etc/hosts entries on the router for both the powerstrip and the server
I logged into the powerstrip and started the server.  It came up with no issues.
I was able to login.

## 2014-05-13

I added a keepalive(15 sec) and an idle timeout(3 min) to the ssh tunnel.
Hopefully that will keep it up.

    root@afn-ryan-vpn:~# cat /usr/bin/vpn_to_fattuba
    #!/bin/sh
    
    while true; do
      ssh -T -N -R 2224:localhost:22 -i /root/.ssh/id_rsa -K 15 -I 120 secvpn@fattuba.com
    done
    
    root@afn-ryan-vpn:~#

I configure static hostnames for the server and powerstrip via the
OpenWRT webgui.  That way I can ping "powerstrip" or "server" by name.
I went into the server BIOS and set the power state to "on".  That way,
anytime we turn the power on to the server using the power strip, the
server will boot.

I'm trying to figure out how to remotely login to the already running
X session.  I'll probably use x11vnc.  `zypper` is the apt-get of the
OpenSuSE world.  Who knew?  I need to make sure that when the server
reboots, it auto starts an X session.  That seems to work.

I'm installing VirtualBox.  Although KVM is trendier, VirtualBox will be much
easier to get started with.

Hey I found this virtual machine manager that's already installed and it uses
libvirt to create VMs for KVM!  I'm using that to install Windows 2008.  By
default, the disks are stored in `/var/lib/libvirt/images`.  I'll need to
move them to `/home`.  Done.

I'm not quite sure what version of Win2008 I'm supposed to install so I guess
I'll just pick "Standard".  There are 2 VM creator tools.  One for just KVM
and one for libvirt that can do either QEMU or KVM.  I'm using libvirt.

I moved the IP address to br1.  That will be the bridge interface that all the
VMs will bridge to.

Windows is now installed.

I've port forwarded 3389 for RDP so you should be able to get to it at
the router's external IP: 192.168.2.144:3389.


## 2014-09-16

The server is super slow to boot.  The RAID status said "verify".
Booting into the RAID config to see what's up.  It's still booting slowly.
Let's try spinrite to check the drives.  I've changed the SATA controller
mode from RAID to AHCI in the BIOS so that spinrite can see the individual
drives.  I've changed the BIOS to boot from the CD first.  Spinrite is
booted and running on the first 3 drives(that was all that I could see).
I left John a note about the status.

## 2014-11-04

We're going to re-create the RAID and re-install SuSE.  Disk 1(the second
one) was throwing a smart error during boot so I swapped it out with
another disk John gave me.  I'm not trying to boot from the SuSE install
DVD.  I'm installing SuSE with pretty much all the default options.  I've
configured networking.  The display is off center.  The googles say that it'll
probably be fixed by patching so I'm running the updater for SuSE.
I've enabled remote desktop administration(VNC) at port 5901.  I noticed
that ssh service isn't running.  We'll have to add that at some point.
SuSE is really a desktop OS.  Perhaps next time we can use another more
server-centric distro?

## 2014-12-02

I've rebooted the server after running the updater.  The display
is *still* off center.  The graphics card is a Matrox MGA G200eW
WPCM450(rev 0a).  John says I can try a different distro.  I'm going to
install Debian.

I'm downloading [Debian Jessie netinst installer Beta
2](https://www.debian.org/devel/debian-installer/).  I'm using unetbootin
on my laptop to put the installer iso on a USB drive.  Well the
[install doc](http://d-i.debian.org/manual/en.i386/ch04s03.html)
says I can just cp the iso to the drive(/dev/sdb).  I'm going
to try that.  Couldn't find an easy way to include the [non-free
firmware](http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/jessie/current/).
I hope we don't need it.

Normal user: afn
password: afn

Whew!  The ethernet devices gets an IP from DHCP just fine so we can
download the non-free firmware over the network if needed.  The installation is
proceeding.  Right now it's formatting the /home partition for ext4.  This takes
a while.

## 2015-01-27

Well the install hangs formatting the big home partition.  Let's try the install
without that partition.  Hrmm... looks like the disks are configured as non-RAID
in the BIOS.  I'm tempted to continue and use Linux soft RAID but I'll hold off
on that.  Let's re-configure the disks for RAID in the BIOS.  It looks like
Intel's RST RAID is [just a firmware based software
RAID](http://forums.linuxmint.com/viewtopic.php?f=49&t=129866) so it'll
work with mdadm.

I'm trying install without home partition.  We can always add that later.
I had some issues installing grub but I finally got it installed on the
second(root) RAID partition.  Well it's not booting.  It's just sitting at
a blinking cursor on a black screen.  Perhaps it's a UEFI vs legacy thing.
I can't find the UEFI options in the BIOS.  Perhaps I need to create a
tiny partition for grub.  Retrying with the default partition settings minus
/home.  I'm also downloading Debian Installer Jessie RC1 that was released
yesterday.  I'll try that next if this doesn't work.


## 2015-02-03

I tried the Debian Jessie RC1 installer and it couldn't even detect the
RST RAID 5 disk.  So I reported that bug to Debian.  I've download the
Debian Wheezy install disk but instead I'm just going back to OpenSuSE
12.3.  Well the display is off center as before.  Let's try installing
Wheezy and doing an upgrade.  It looks like Wheezy detected the OpenSUSE
configured RAID array.  I'm also downloading the latest OpenSuSE(13.2)
to try if the Wheezy install doesn't work.  Well that didn't work(boot
media not found).  Ok, so I'm back on the Jessie RC1 installer.  I'm using
straight Linux software RAID(I've disabled the Intel RST RAID).  That worked.
We're up and the RAID is syncing now.  I've confirmed that I have access through
my little VPN.

## 2015-02-10

Logged in remotely today through the VPN.  I'm installing libvirt tools to get
the Windows guest installed and running.  `apt-get install libvirt-clients` for
virsh.  I'm trying to follow this
[guide](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Virtualization_Host_Configuration_and_Guest_Installation_Guide/sect-Virtualization_Host_Configuration_and_Guest_Installation_Guide-Windows_Installations-Installing_Windows_XP_as_a_fully_virtualized_guest.html) but I'm missing virt-install.  Intalling apt-file so I can search for it.

It's in virtinst package so `apt-get install virtinst`.  The windows CD is
already in the drive so `sudo mount /media/cdrom`.

## 2015-03-03

Installed the Windows server in a VM and started to move over the clonezilla
image.

## 2015-03-24

rsync'ing the clonezilla image over.  apt-get dist-upgraded and rebooted.
I set the 'default' virtual network to start at boot.  To start the
win2k8 VM, go to `Application Menu->System->Virtual Machine Manager`. I set the
win2k8 administrator password to be the usual.  The matrox graphics card has
attrocious performance which is fine since it's a server.  However that
means that the VMs should be managed over RDP/VNC rather than on the
desktop.  Otherwise, the display will be really slow.

I took a snapshot of the win2k8 server VM right after install.

I'm trying to run the clonezilla vm.  Using virt-convert to convert
the ova file to a KVM-supported image.  Ok, so the clonezilla VM is up
and running.  I'm going to shut it down for now.

## 2015-04-07

Don't know what happened to the clonezilla image.  I think I deleted it.
Trying to convert and get the clonezilla VM up and running again.
Running `tar xvf austin_freenet_clonezilla.ova` to untar the ova to get
to the vmdk files.  It looks like virt-convert is an easier way to do this so
running `sudo virt-convert -D qcow2 austin_freenet_clonezilla.ova`.  Wow that
was the magic!  It's up and running now.

I've installed samba on the VM host.  I've configured it to serve home
directories.

I've added another VM as a clone target.  I set it to boot from PXE
and set the network up as bridge to eth0.  I changed the network
config on the clonezilla server to also bridge to eth0.  Finally I
changed the IP address of the tftpserver on the clonezilla server in
`/tftpboot/nbi_img/pxelinux.cfg/default`.  Cloning is working!

Well the clone didn't boot into Windows.  I got a BSOD.  I changed
the disk config from IDE to SATA and restarted the cloning process.
In any case, the cloning completed so I think we're ready to try it on
real hardware.

## 2015-04-14

So I need to set up a real bridge on the VM server to allow the bridged VMs to
communicate with the server.  Changing /etc/network/interfaes to add br0.
Following this
[guide](http://wiki.libvirt.org/page/Networking#Altering_the_interface_config).

That worked.  I also add the following $HOME/.xsessionrc file:

    . $HOME/.profile

... so that my PATH would be setup correctly.

I'm now testing a restore on a real client.  It bombed because this
client's hard drive is too small.  So let's save it's existing image
and restore that.  We're running out of space on /home for clonezilla
so I need to use NFS for that.  I remember why we didn't do that
initially.  It's because you can't NFS share an NFS mounted partition.
So instead.  I'm just going to share it directly from the VM server.
Or maybe I can attach it to the guest using some kind of KVM magic.
Yup let's try that second one.  I'm growing the small partition using this
[guide](http://geekpeek.net/resize-filesystem-fdisk-resize2fs/) right now.
The resize was successful.  Ok, so let's retry the client image save.

Note: we should probably create a VM that has gparted to make it easier
to resize these disks.

Ok, the test client image save is happening now.

## 2015-04-21

So the test client save completed from last time.  I did a test client
restore and it worked!  John asked me to expand the image partition from
500GB to 1 TB.

## 2015-04-28

I shutdown the clonezilla VM.  I ran `sudo qemu-img resize
Austin_Free-Net_Clonezilla-disk2.qcow2 +500GB`.  Then I removed the
disk via virt-manager and reattached it.  Now virt-manager says the
disk is 1000GB instead of the old 500GB.  I booted the clonezilla VM and
unmounted the disk so I can resize it.  I had to stop the nfs server to
unmount the disk.  Then I followed the steps in the resize guide above.
The disk resize finished.  Now I'm copying over the images from the USB
drive John gave me.  It looks like the clonezilla VM is bottlenecked
by the processor when restoring an image and rsyncing simultaneously.
We should allocate more processors to the
clonezilla VM.  It also might help to [tune the RAID
setup](https://raid.wiki.kernel.org/index.php/Performance) a bit.
I'm also building a disk editing VM to make it easy to resize disks.

## 2015-05-19

Today I'm showing John how we do VM stuff.  I setup the disk-editor VM
auto-login for "user".  I also added "user" as a sudoer with no password.  Next
I need to install gparted.  I was getting "ERST: Failed to get Error Log
Address Range" during linux boot so I [disabled WHEA in the
BIOS](http://www.supermicro.com/support/faqs/faq.cfm?faq=15594) as recommended
by our motherboard manufacturer, SuperMicro. There's a [critical bug in
KVM](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2015-3456) that is fixed
in the latest apt-get upgrade.  I need to figure out why NOPASSWD isn't working
in sudoers.  I think I [got
it](http://askubuntu.com/questions/504652/adding-nopasswd-in-etc-sudoers-doesnt-work).  I increased the clonezilla VM's processor allocation from 1 to 4 and did the same for disk-editor.  Since gparted is started with policy kit and not sudo, I had to add a policy to [not require password auth](http://askubuntu.com/questions/98006/how-do-i-prevent-policykit-from-asking-for-a-password).  I set gparted to start upon login.

## 2015-08-25

In order to get cloning working between the clonzilla server vm and a
test client vm, I had to set `bridge_fd 2` in `/etc/network/interfaces`.
0 was "out of bounds".  Now I can PXE boot a test client VM from the
clonezilla server.

I also set the desktop wallpaper for root so that a logged in user knows
they're root.
