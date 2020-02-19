# PXE boot server

John wants to create a RPi-based PXE boot server so that you can launch
unattended Windows install from the network instead of just a USB drive.

## 2019-10-8

I've installed Raspbian Buster on the Pi John gave me.

## 2019-10-10

So I can work remote, let's setup Rasbpian [as a qemu
VM](https://azeria-labs.com/emulate-raspberry-pi-with-qemu/).  I can
mount the Pi img now like this:

    sudo mount -v -o offset=$(echo "$(fdisk -l 2019-09-26-raspbian-buster-lite.img | grep img2 | awk '{ print $2 }') * 512" | bc) -t ext4 ~/Downloads/2019-09-26-raspbian-buster-lite.img /mnt/rasbian/

Hrmm... it seems like the mods to the root drive might not be necessary for
buster.

This seems to work: https://github.com/dhruvvyas90/qemu-rpi-kernel
...along with [this fix](https://github.com/dhruvvyas90/qemu-rpi-kernel/issues/75#issuecomment-482880164).  I'm able to login but don't have network.  Probably want to try the [libvirt option](https://github.com/dhruvvyas90/qemu-rpi-kernel#using-kernel-images-with-libvirt) next.

## 2019-10-15

Ok, let's boot the Pi with the Rasbian SD card I loaded.  Ok Pi is up and
booted.  Let's install tftpd and dhcp-proxy now like we did for the
[clonezilla server project](./afn_clonezilla_eng_log.md).  Let's first get
[proxy dhcp working](https://wiki.fogproject.org/wiki/index.php?title=ProxyDHCP_with_dnsmasq).

Let's change the keyboard and timezone to US using `sudo raspi-config`

I've changed the pi password to our usual password.  I guess dnsmasq provides
tftp now so we don't have to install a seperate tftp server.

I've configured dnsmasq to be a DHCP proxy in /etc/dnsmasq.d/proxydhcp.
Let's try to PXE boot one of the client machines on the same network.

Ok so PXE boot worked up to TFTP.  So now we need to load the Windows auto
install stuff into the tftpboot directory so that PXE can find it.

Ok so I'm trying to get it setup to [install
windows](https://www.tecmint.com/installing-windows-7-over-pxe-network-boot-in-centos/).
Looks like we need pxelinux so I'm [setting that
up](https://www.theurbanpenguin.com/pxelinux-using-proxy-dhcp/).
Now I've got a pxelinux menu coming up.  Next I need to [generate a WinPE
image](https://ahmermansoor.blogspot.com/2018/11/configure-centos-7-pxe-server-install-windows-10.html)
to boot from.

## 2020-1-14

I found [this guide](https://github.com/thurstylark/win-netinstall) that seems
to contain all the steps for netinstalling Win10.

This might be a [point-n-click](https://www.aioboot.com/en/about/) option to get
a PXE server up and running.

## 2020-2-4

Wow!  [This](https://docs.j7k6.org/windows-10-pxe-installation/) looks
super simple and straight forward.  Let's try it.  I'm not sure where the
Raspberry Pi is so I'll just do this from my laptop for now.  tftpd-hpa is
already installed.  I need to remember to shut it off after the fact.
I'm following the [prereq](https://docs.j7k6.org/raspberry-pi-pxe-server/)
now on my laptop.

I've temporarily [disabled dnsmasq from
NetworkManager](https://askubuntu.com/a/233223) to make it easy to run
my own.

So dnsmasq has it's own little tftp server so removing tftpd-hpa.

Ok so proxydhcp starts now: `systemctl start dnsmasq.service` and runs alongside
the dnsmasq that NetworkManager runs.  I've figured out how to [enable PXE
boot](https://www.dell.com/community/Desktops-General-Read-Only/UEFI-PXE-boot-not-available-in-OptiPlex-9020-AIO-A09-for-Win7/td-p/4485207).  Forgot to symlink memdisk.  Now that that's done, winPE boots!  Now let's try to do the net use and setup.exe stuff.

So there are no network interfaces when I run `ipconfig /all`.  It's probably a
driver issue.  Let's try to use the winpe.iso Patrick created.  That boots and
has network!  However it says can't run setup.exe because the version isn't
compatible with the version of Windows we're running.

Patrick regenerated the winpe.iso for x64 and not it works and setup
is running!

Note: We'll need to script the IP range of the proxydhcp server so that it will
work in any DHCP environment.

As an aside I ran `mkwinpeimg --iso --windows-dir=/home/tubaman/.gvfs/smb-share:server=taradinas.plni.info,share=boot /tmp/winpe_win10.iso` which may have created a network-enabled winpe image also.  We may want to test that later.

Next we need to move this from my laptop to the Pi.

## 2020-2-18

With Patrick's help I'm copying all the config from /etc/dnsmasq.d and /srv/tftp
to the Raspberry Pi.  I've also enabled ssh on the Pi to help with
debugging.

Note: the dnsmasq config file on the Pi in actually `/etc/dnsmasq.conf` *not*
`/etc/dnsmasq.d/*`.
