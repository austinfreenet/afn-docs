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
