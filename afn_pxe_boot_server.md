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
