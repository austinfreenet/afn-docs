# Genesis Drive Engineering Log

This is the genesis drive project engineering notebook.  The genesis drive is a
bootable clonezilla USB drive containing a number of images to select from.

## 2019-4-16

We had this working a few years ago but can't remember how to recreate.  So
let's start from scratch.  Let's download [Clonezilla stable(based on Debian)](https://clonezilla.org/downloads/download.php?branch=stable).

Let's verify the image using the [checksum](https://clonezilla.org/downloads/stable/data/CHECKSUMS.TXT) and [signature](https://clonezilla.org/downloads/stable/data/CHECKSUMS.TXT.gpg).

    gpg --verify CHECKSUMS.TXT.gpg CHECKSUMS.TXTgpg: Signature made Thu 10 Jan 2019 05:32:45 AM CST
    gpg: Signature made Thu 10 Jan 2019 05:32:45 AM CST
    gpg:                using RSA key 54C0821A48715DAFD61BFCAF667857D045599AFD
    gpg: Good signature from "DRBL Project (Diskless Remote Boot in Linux)
    <drbl@clonezilla.org>" [ultimate]
    gpg:                 aka "DRBL Project (Diskless Remote Boot in Linux)
    <drbl@nchc.org.tw>" [ultimate]

It looks like [that fingerprint is correct](https://www.google.com/search?q="54c0+821a+4871+5daf+d61b+fcaf+6678+57d0+4559+9afd").  The image checks out.  Let's burn it to the USB flash drive using dd:

    dd if=~/Downloads/clonezilla-live-2.6.0-37-amd64.iso of=/dev/sdb bs=4M
    sudo sync

That didn't work.  The [clonezilla site recommends](http://www.clonezilla.org/liveusb.php#windows-method-a)
that you create a bootable USB by formatting it to fat32 or ntfs first.
I used gparted to do this.  Then use tuxboot to install the files.

That seems to work. Let's try to boot it using a VM.  Here's [instructions on how to get VirtualBox to boot from a real USB drive](https://askubuntu.com/a/693729).

Maybe [this is the next step](https://clonezilla.org/advanced/customized-clonezilla-live.php)?

## 2019-4-23

We also need to figure out how to host the images on the Clonezilla Live
USB drive.  It looks like we need to [create a second partition on the USB drive](https://drbl.org/faq/fine-print.php?path=./2_System/120_image_repository_on_same_usb_stick.faq#120_image_repository_on_same_usb_stick.faq).
Ok, I used gparted to shrink the clonezilla live partition and add a
"disk images" partition.  Let's try to clone our Win10 virtualbox install.

So it looks like I can boot from the clonezilla USB disk in EFI mode but
not if I don't have that checked.  Is it because my live partition is NTFS
instead of fat32?  Looks like this is only an issue in VirtualBox since
John can boot this fine on a host.  So I can boot John's sample live USB
if I use the method above and I use an IDE controller instead of SATA.
Let's see if it's the NTFS vs fat32 thing.  That seems to do it!  Now I
have a drive with one fat32 parition with clonezilla live and one NTFS
partition for disk images.

Now let's add an IDE controller to our Win10 guest and boot into clonezilla
live.  Ok so I'm now cloning my Win10 guest as a test.

Here's the command to run directly next time:

    /usr/sbin/ocs-sr -q2 -c -j2 -z1 -i 4096 -sfsck -senc -p choose savedisk win10_2019-04-23-09-img sdb

So I've gone through the [customize docs](https://clonezilla.org/advanced/customized-clonezilla-live.php).  Let's load that zip on the USB and see what it does.
I think I killed the guest VM too soon.  Nothing was persisted on the partimag
partition.
