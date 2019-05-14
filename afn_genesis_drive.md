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

## 2019-4-30

Trying to mount USB drive without doing the drive hack.  No go, you need the
drive hack to **boot** from USB.  Let's just try to get something to persist on
the /partimag partition.  Ok so a normal clone worked fine.  Back to the custom
stuff.  Well the custom stuff that we did above is corrupt(zipfile).  Let's
retry and make sure the VM shuts down correctly.  The VM locked up when I tried
to shut it down.  Let's try to sync on the host before shutting down the VM.

It seem unreliable.  Let's `dd` the USB data over to a VirtualBox disk and boot
from that.  Then when we're satified with the result, we can `dd` it back.
I'm using rsync to sync the stuff back to the USB drive on the host.

Ok, I've loaded the custom clonezilla.zip on the USB drive.  Their default
`custom-ocs` script runs no problem.  Now let's modify for our needs.

## 2019-5-7

Talked with John today.  We want one option: "Restore genesis image"
that restores the image in `/partimag/genesis`.  For development I
use the clonezilla live shell and edit the script in /tmp and run it.
Then once the bugs are worked out, I copy it back to the USB drive and
build the new custom image.  Here's the current custom script:

    tubaman@stark:/media/tubaman/Disk Images/custom$ cat genesis-restore
    !/bin/bash
    # Author: Ryan Nowakowski <ryan@fattuba.com>
    # License: GPL
    # Ref: http://sourceforge.net/forum/forum.php?thread_id=1759263&forum_id=394751
    # In this example, it will allow your user to use clonezilla live to restore the image

    # When this script is ready, you can run
    # ocs-iso -g en_US.UTF-8 -k NONE -s -m ./custom-ocs
    # to create the iso file for CD/DVD. or
    # ocs-live-dev -g en_US.UTF-8 -k NONE -s -c -m ./custom-ocs
    # to create the zip file for USB flash drive.

    # Begin of the scripts:
    # Load DRBL setting and functions
    DRBL_SCRIPT_PATH="${DRBL_SCRIPT_PATH:-/usr/share/drbl}"

    . $DRBL_SCRIPT_PATH/sbin/drbl-conf-functions
    . /etc/drbl/drbl-ocs.conf
    . $DRBL_SCRIPT_PATH/sbin/ocs-functions

    # load the setting for clonezilla live.
    [ -e /etc/ocs/ocs-live.conf ] && . /etc/ocs/ocs-live.conf
    # Load language files. For English, use "en_US.UTF-8".
    ask_and_load_lang_set en_US.UTF-8

    # The above is almost necessary, it is recommended to include them in your own custom-ocs.
    # From here, you can write your own scripts.


    action_restore() {
      mkdir -p /tmp/ocsroot_bind_root
      mkdir -p $ocsroot
      if ! mountpoint $ocsroot &>/dev/null; then
        mount -o noatime,nodiratime /dev/disk/by-label/Disk\\x20Images  /tmp/ocsroot_bind_root
        mount --bind -o noatime,nodiratime /tmp/ocsroot_bind_root/partimag $ocsroot
      fi
      if mountpoint $ocsroot &>/dev/null; then
        # If you want to run it in batch mode, add option "-b" in the ocs-sr command
        # For more options about ocs-sr, run "ocs-sr -h"
        ocs-sr -q2 -c -j2 -z1 -i 4096 -sfsck -senc -p choose restoredisk genesis sda
      else
        [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
        echo "Fail to mount /partimag in /dev/disk/by-label/Disk Images as $ocsroot!"
        echo "Program terminated!"
        [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
      fi
      umount $ocsroot &>/dev/null
      umount /tmp/ocsroot_bind_root &>/dev/null
    }

    ##################
    ###### MAIN ######
    ##################

    TMP="$(mktemp /tmp/menu.XXXXXX)"
    trap "[ -f "$TMP" ] && rm -f $TMP" HUP INT QUIT TERM EXIT
    $DIA --backtitle "$msg_nchc_free_software_labs" --title  \
    "$msg_nchc_clonezilla" --menu "$msg_choose_mode:" \
    0 0 0 \
    "Restore" "Restore genesis image" \
    2> $TMP
    mode="$(cat $TMP)"
    [ -f "$TMP" ] && rm -f $TMP

    #
    case "$mode" in
      Restore)
        action_restore;;
      *)
        [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
        echo "Program terminated!"
        [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
        exit 1
    esac

John says the host hard drive always comes up as /dev/sda so let's switch our
script to that.

## 2019-5-14

Let's set the timeout for the genesis grub screen to be 5 sec instead of 30.
Trying [this](https://sourceforge.net/p/clonezilla/discussion/Clonezilla_live/thread/236b1196/#41a3).

Aside: Here's another way of customizing clonezilla live: [changing the boot parameters](https://clonezilla.org/fine-print-live-doc.php?path=./clonezilla-live/doc/99_Misc/00_live-boot-parameters.doc).  I think this is what we did a few years ago to customize clonezilla.

Well the link above works but only after you re-run grub to install it on the
USB MBR.  So here's the full procedure to adjust the boot menu timeout:

1. Create a custom `clonezilla-live-*.zip` by running the `ocs-live-dev` command
   documented above.
2. unzip the boot config files: `unzip clonezilla-live-20190514.zip boot/grub/grub.cfg syslinux/syslinux.cfg`
3. edit the boot config files to change the timeout.  Note: syslinux.cfg timeout
   is in 10ths of a second.
4. Update the zip with those newly edited boot config files: `zip --update
   clonezilla-live-20190514.zip boot/grub/grub.cfg syslinux/syslinux.cfg`
5. Install the zip on the USB drive.  Note: you can't just run unzip.  You need
   to use a tool(ex: tuxboot) that will reinstall grub to the MBR of the USB.
