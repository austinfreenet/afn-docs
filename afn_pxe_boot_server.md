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
