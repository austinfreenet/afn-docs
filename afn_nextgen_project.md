# Austin Free-Net Next Gen Desktop Project

Let's migrate all the clients in the field to a linux base and run Win7
in a VM.

## 2015-04-21

Installing Debian Testing(Jessie) on a client.  I have the old Win7
image backed up on the clonezilla server.  The Debian install worked.  Now I'm
saving that Debian image to the clonezilla server.

## 2015-04-28

The image save completed.  I'm back on the VM project now.  Next for
this it to install Windows 7 in a KVM VM on top of the jessie image
I installed on the client.  Let's push the debian image back onto
the client.

## 2015-5-19

The image is back onto the client so now I'm installed XFCE, virt-manager and
lightdm.  The I need to install a Windows 7 KVM VM.  I've setup an apt proxy VM
and
[configured](https://help.ubuntu.com/community/AptGet/Howto#APT_configuration_file_method) the nextgen image to use it.  I also installed
firmware-realtek.  I'm saving the image via clonezilla again.

## 2016-5-24

Today, I'm back on the nextgen project again.  Let's get the image back on the
client.  Ok so I had to switch the monitor attached to the KVM to analog mode
and slot 4 to see the VM server.  I've started the clonezilla VM so I can pull
the client image from it.  John said I could use the client machine on the top
left for testing.  Ok so that client is our dev machine for our [load balancing
router](afn_wan_load_balancing.html).  Let's clone that so we don't lose our
work.  For some reason the PXE booted client NFS mount fails.  I removed
IPAPPEND from `/tftpboot/nbi_img/pxelinux.cfg/default` and it mounts fine now.
That's probably because there's multiple ethernet adapters in this client.
I left a note in the [clonezilla doc](afn_clonezilla_eng_log.html#section-13)
about this.

## 2016-6-21

I'm going to use the HP client machine on the wire rack as the
nextgen test client.  I'm using the clonezilla server to restore
`nextgen-dev-2016-5-19-16-img`.

## 2016-7-5

The Debian username/password is user:user.  The current term is xterm.
Yuck.  Let's install xfce4-terminal.  The root password is the normal AFN
admin/root password.  I need to install sudo also.  I don't have the apt proxy
running so let's disable it for now on the client.  So my experiments with
VirtualBox at my church went well.  I have 2 issues.

   1. The USB devices sometimes don't passthrough (you have to have them plugged
      in before boot)
   2. The Vbox bridging doesn't work with some DHCP servers.

So let's try KVM instead.  I've
[added](https://wiki.debian.org/KVM#Installation) `user` to the `kvm`
and `libvirt` groups.  I'm getting a warning that says "KVM is not
available" when I try to create a new VM.  Let's `apt-get install qemu-kvm
libvirt-bin` to see if that fixes the issue.  No joy.  I reboot.  The boot
message says "kvm: disabled by bios".  Let's try to enable it in the BIOS.  So
enabling "Virtual Machine Technology" in the BIOS fixed the warning message.

Ok so now let's get a Windows 7 image working.  I'm rsync'ing an image from my
Laptop over.  The client needs ssh and rsync installed.  The image is
tranferring now.  Install iftop to watch the speed.

Well just importing the .ova file didn't work.  Let's Google.  Let's try
[this](http://wiki.hackzine.org/sysadmin/kvm-import-ova.html).  While that's
converting, let's get [NTP
working](https://wiki.debian.org/DateTime#Set_the_time_automatically).

Ok so the conversion from ova to qcow2 went well.  I'm booting the Windows 7
guest now.  I'm uninstalling the VirtualBox guest utils since we're not going to
use them.  Ok so here some stuff we need to test:

   * ~~networking~~
   * USB pass through
   * sound
   * ~~cdrom~~

Ok, I've added /dev/sr0 as a CDROM device.  I'm out of time for today so let's
save the client image to clonezilla as `nextgen-dev-2016-07-05-16-img`.

## 2016-7-12

Let's test sound first.  pulseaudio isn't running and alsa utils aren't
installed.  Let's avoid pulse for now.  `apt-get install alsa-utils`.  I ran
`alsamixer` and turned up master.  Then I ran `aplay` on a test wave from
`/usr/share` and sound came out my headphones.  Now let's see if sound works
from the win7 guest.  When starting the guest machine, I got a network error and
the guest refused to start.  I had to go into virtual machine manager and start
the virtual network.

Note: Let's figure out how to hard-set the guest's MAC so that Windows licensing
won't freak out.

So ich6 emulation doesn't seem to work.  Let's try AC97.  No joy trying to
install the drivers from Realtek.  Let's rollback.  Argh.  I forgot to snapshot
the VM.  Let's reinstall from our import and make sure and take a snapshot this
time. I created a snapshot called "fresh clone".  So I uninstalled the
virtualbox guest extensions.  I set the display to a higher resolution and I
disconnected the vbox network drive that doesn't exist anymore.   Time to take
another snapshot.

I'm following [this
guide](http://froebe.net/blog/2013/02/10/howto-windows-7-32bit-and-64bit-sound-with-kvm-libvirt-and-the-spice-client-2/)
to get the sound to work.  I've installed the Redhat QXL windows display driver.
I still can't get the AC97 sound driver to install so let's run Windows update.
Well I've got the dreaded super slow [Windows 7 update
issue](https://www.grc.com/sn/sn-560.htm) so now I'm
downloading the new [Windows 7 convenience
rollup](http://www.howtogeek.com/255435/how-to-update-windows-7-all-at-once-with-microsofts-convenience-rollup/).

## 2016-7-26

Ok so I'm trying to solve the windows update issue again today.  Well apparently
my version of IE is so old that I can'tuse it to downloadthe updates
from microsoft.  Let's try and download them on my linux machine and scp them.
Apparently we need to install [this
update](https://download.microsoft.com/download/C/0/8/C0823F43-BFE9-4147-9B0A-35769CBBE6B0/Windows6.1-KB3020369-x86.msu)
first then the convenience rollup. Ok so the convenience rollup is installing
now.

## 2016-8-9

I'm installing more Windows updates.  I reran the convenience rollup above and
it seemed to work.  So now I'm rerunning Windows update.

## 2016-8-23

I'm trying to re-run Windows update but it's taking forever so let's bail and
try to get sound working.  So I switch to ICH6 in virt-manager and Windows sound
started working.  But it's not coming out of the physical sound card so I need
to figure out what's wrong on the linux side.... Probably pulseaudio?

## 2016-8-30

So I've installed pulseaudio and sound is happening!  However it skips :(
At this point I think I'm ready to move over to Virtualbox.  I'm `apt-get
install virtualbox` now.  I've imported my Windows 7 test VM.  We definitely
want USB 2.0 support so let's install the Virtualbox extension pack.  I'm
uninstalling iTunes from my sample image.  I've also bound the host CD drive to
the guest and setup an "Everything"(blank) USB filter so all devices get sent to
the guest.  I ran `adduser user vboxusers`.  The USB devices aren't showing up.
I need to logout and log back in to recognize my new group membership.  Now the
USB devices are showing up.  I also bumped the number of cores assigned to
the guest from 1 to 2.  USB devices passthrough works however there's no way to
pass through [everything except certain
devices](http://www.virtualbox.org/ticket/14667).  So I need to write a small
script that uses VBoxManage to watch for new devices and attach them to the
guest.

## 2016-9-6

Let's write the script.  The script is coming along nicely.  Hopefully I'll
finish it next time.

## 2016-9-13

Working on the script again.  Seems to work.  I left it running so John can play
with it.

## 2016-9-20

I've created a git repo for the afn-nextgen scripts like `watchvboxusb.py`.
Let's create a different user on the next gen machine for development and
sysadmin'ing.  I'll call it user name: ryan.
I've installed xprintidle and xautolock to play around with X idle detection.

So it looks like xautolock disconnects stdout so I'm having trouble testing with
echo.  Installing zenity to create the logout warning dialog.

This totally works:

    xautolock -nocloseout -nocloseerr -time 1 -locker 'bash -c "echo lock"' -notify 50 -notifier 'bash -c "echo logging out in 45"'

So now let's write the warning dialog script.  I'm installing `bc` for floating
point math.  I need rounding so let's use awk instead.

I can run the dialog in the user X session by doing:

    root@afn-nextgen:/home/ryan/sandboxes/afn-nextgen/root# export XAUTHORITY=~user/.Xauthority
    root@afn-nextgen:/home/ryan/sandboxes/afn-nextgen/root# export DISPLAY=:0
    root@afn-nextgen:/home/ryan/sandboxes/afn-nextgen/root# ./logoutwarningdialog.sh

I'm using `wmctrl` to keep the dialog on top.  Maybe we can use that to keep the
virtualbox window maximized?

## 2016-10-4

GTOPS hardware giveaway using the city's depreciated hardware.  nextgen might be
piloted there.  Announced in March.  Programs start in July.  Development
between March and end of June.

Refurb stickers are brown.  As long as the MS licenses follow the hardware then
licenses will transfer.

So now the logout dialog doesn't have buttons and is killed when the mouse moves
or the keyboard is tapped:

    ryan@afn-nextgen:~/sandboxes/afn-nextgen/root$ ./logoutwarningdialog.sh 30

Also this works:

    ryan@afn-nextgen:~/sandboxes/afn-nextgen/root$ TIMEOUT=50; xautolock -nocloseout -nocloseerr -time 1 -locker 'bash -c "echo lock"' -notify $TIMEOUT -notifier "./logoutwarningdialog.sh $TIMEOUT"

I need to fix the logic in logoutwarningdialog to *not* try the kill if it's naturally timeed out already.

## 2016-11-1

Whoops, we have some screen burnin on our test machine.  I guess LCDs are
susceptible to burnin.  I've enabled xscreensaver.

## 2016-11-15

Back on nextgen today.  Now I've got a daemon that monitors the user's idle time
and puts up the warning dialog.  Next we need to create the logout script that:
   1. shuts down the X session
   2. reset the home dir and VBox snapshot

## 2016-12-13

For the "login" screen I'll research existing Linux kiosk setups to see what
others are doing.  Let's use aufs or it's ilk to make it easy to wipe a session
after logout.  Here's [an
article](http://www.alandmoore.com/blog/2011/11/05/creating-a-kiosk-with-linux-and-x11-2011-edition/)
about building a kiosk from scratch with Debian.

Why have our own idle time monitoring daemon(monitoruseridletime.sh)?  Why not
use xautolock as demo'd above?

It looks like xautolock notify is not working correctly:

    xautolock -nocloseout -time 1 -locker 'bash -c "echo lock"' -notify 55 -notifier 'bash -c "echo locking in 55 secs"'

The first time, the notification happens properly but after moving the mouse
once, it doesn't notify again until 55 secs in.  Let's take a look at the
source.  I sent the author Michel and email.  It looks like it's related to
prevNotification in the source.  We could simply remove that from our version.

## 2017-1-3

I haven't received a reply from Michel.  I've submitted this as a [bug](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=850063) to Debian.  I'll try [patching the package](http://cs-people.bu.edu/doucette/xia/guides/debian-patch.txt) myself.

    tubaman@hawaiianwonder:~/build$ cat xautolock-2.2/debian/patches/14_fix_notify.patch
    Index: xautolock-2.2/src/engine.c
    ===================================================================
    --- xautolock-2.2.orig/src/engine.c
    +++ xautolock-2.2/src/engine.c
    @@ -210,7 +210,6 @@ queryPointer (Display* d)
     void
     evaluateTriggers (Display* d)
     {
    -  static time_t prevNotification = 0;
       time_t        now = 0;
     
      /*
    @@ -321,8 +320,7 @@ evaluateTriggers (Display* d)
       *  Now trigger the notifier if required. 
       */
       if (   notifyLock
    -      && now + notifyMargin >= lockTrigger
    -      && prevNotification < now - notifyMargin - 1)
    +      && now + notifyMargin >= lockTrigger)
       {
         if (notifierSpecified)
         {
    @@ -337,7 +335,6 @@ evaluateTriggers (Display* d)
           (void) XSync (d, 0);
         }
     
    -    prevNotification = now;
       }
     
      /*

Well that doesn't work... now it notifies over and over.  If I don't get an
answer back from either the Debian maintainers or the xautolock devs, I'll
switch back to using my shell script.


## 2017-1-10

Ok, we're back on the shell script today.  Let's get it running to shutdown the
session.

Here are the steps to setup the user session:

   1. root syncs the golden homedir to /home/user
   2. root switches to "user" and starts X (startx?)
   3. user's X session starts
   4. root begins monitoring idle time
      * display a warning
      * if the warning times out, root kills the user X session
   5. goto 1

Note: we should rename "user" to "client"

Next we should make sure VirtualBox auto starts and watchusb*.py starts

## 2017-1-17

So I put the following in `~user/.xessionrc`

    . ~/.profile

and this in `~user/.xession`

    pkill -9 -f watchvboxusb.py
    ~/watchvboxusb.py &
    VirtualBox --startvm "Windows 7" --fullscreen
    pkill -9 -f watchvboxusb.py

I need to copy these over to the golden homedir.  Done.  Now, let's try to run the demo.

We should also add --delete to the rsync command in root/reset*.sh so any extra
files will get deleted.  The rsync sometimes takes a long time.  Perhaps we
should use an overlay filesystem instead?

I've added a little "start working" dialog.  Figure out a way to hide virtualbox
bottom menubar.  Make the warning dialog more visible.  John's idea is to make
the windows guest tranlucent and make the dialog bigger or something.  Maybe,
animate it?  Use frozen guest instead of booting Windows everytime.

## 2017-1-24

Here's our current punch list

   1. ~~use overlay fs instead of rsync~~
   2. ~~frozen guest instead of boot~~
   3. ~~hide virtualbox bottom menubar~~
   4. ~~make the warning dialog more visible~~
      * ~~windows guest translucent?~~
      * animate warning dialog?

Let's start with the overlay fs.  Debian Jessie has aufs builtin so let's use
that.  Here's a [good overview of aufs](http://www.thegeekstuff.com/2013/05/linux-aufs/).  Wow, now it takes quite a while for the user session to start.  It seems like we've just shifted around the disk I/O from before the session starts(rsync) to during session start(aufs).  Maybe if we switch from boot to unfreeze it'll help.  Ok so unfreezing didn't help the session start speed.  I'm looking at optimization options for aufs.

## 2017-2-7

Let's try doing a fresh VBox snapshot.  Maybe that will speed things up.  That
totally worked!  Now session startup is fast!  You can [disable the mini-menu](http://askubuntu.com/questions/31798/in-virtualbox-fullscreen-mode-can-i-disable-or-move-the-popup-menu-bar) in VirtualBox fullscreen mode.

## 2017-2-14

Let's try to make the warning dialog more visible.  Starting xfwm4 helps the
warning dialog appear more obvious.  Let's try to add an image to make it
bigger.  It's not easy to add an image.

## 2017-2-28

I used the VirtualBox pause/resume feature to "dim" the Windows guest while the logout warning dialog is visible.  Now let's figure out a way to make the timeout configurable.  First let's refactor the scripts to remove duplication.  Ok, so the refactor is done.  I also made the scripts more robust so now things should work even more smoothly than before.

I'm thinking about using [Electron](https://electron.atom.io/) to make a small app to allow the proctors to be able to set the timeout values.
