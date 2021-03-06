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

## 2017-3-7

We can try to use a [Windows logoff
script](https://technet.microsoft.com/en-us/library/cc753583%28v=ws.11%29.aspx) to kill the VM.  I've [disabled the shutdown menu items](http://mintywhite.com/windows-7/7customization/remove-options-windows-7-shutdown-menu/).  Now let's add the logoff script.  I've added a simple logoff.bat that runs `shutdown /p /f`.  I've take a new VM snapshot with these new changes.  We need to [hide the "switch user" menu item](http://www.addictivetips.com/windows-tips/how-to-enable-disable-fast-user-switching-in-windows-xp-and-windows-vista/).


## 2017-3-14

3 things left on the list:

   1. ~get handleclientsession to run on boot~
   2. create app to allow proctors to modify session timeout
   3. ~~fix the hardware video disabled warning when starting solitare~~


There's [some indication](https://forums.virtualbox.org/viewtopic.php?f=8&t=62541) that I need to reinstall the guest utils in safe mode to get 3D acceleration to work.  Ok so when it asks to install WDDM support or basic Direct 3D support, I chose WDDM.  Solitaire seems to work well now.   I *didn't* have to install it in safe mode either.

Let's disable lightdm on boot so that handleclientsession manages it instead:

    sudo systemctl disable lightdm


Whoops... wait.  It looks like we need to [disable
`graphical.target`](http://unix.stackexchange.com/a/140551) instead of just
disabling lightdm.  I've reenabled lightdm and instead will mess with
graphical.target.

I'm trying this: `systemctl set-default multi-user.target`

That worked!

Let's figure out to run a the handleclientsession.sh shell script as a daemon.

## 2017-3-21

When I came in this morning the dev machine was acting weird.  It would freeze
occassionally both in Windows and Linux.  I'm running SpinRite on level 2.  That
seemed to help a little.  Now I'm running on level 4.

Brian at Qualcomm says that Qualcomm uses [OSD to do Windows imaging](https://blogs.technet.microsoft.com/gborger/2010/10/11/getting-started-capturing-a-windows-7-image-with-sccm-osd-using-a-task-sequence/).

## 2017-4-4

I'm going to do the lab monitor app in [Electron](https://electron.atom.io/).  I'm starting with [electron-boilerplate](https://github.com/szwacz/electron-boilerplate) as recommended by my buddy Welsh.  I'll probably use Angular for the app framework because that's what I'm use to.

## 2017-4-11

Let's get `handleclientsession.sh` to run as a daemon.  systemd can [do this](https://learn.adafruit.com/running-programs-automatically-on-your-tiny-computer/systemd-writing-and-enabling-a-service) for us.

Ok, I've added `handleclientsession.service` to our repo.  Then you can run `sudo systemctl enable ~ryan/sandboxes/afn-nextgen/root/handleclientsession.service` and `sudo systemctl start handleclientsession.service`.

WinSAT was running and comsuming quite a bit of CPU.  Apparently it's a hardware benchmark utility.  I've remove the task from Task Scheduler.

So it turns out that I need to copy handleclientsession.service over to `/etc/systemd/system/` then run enable and start.  Otherwise on reboot, systemd thinks the service is broken.  It probably has something to do with the fact that a service file can't be on a non root partition.

I've confirmed with John that github is a good place to store all our code.
I'll create an austinfreenet org on github and push all the code there.

## 2017-4-25

We're going to roll this out for the PC loan program first so let's focus on that.  Here's the current punch list:

   1. Windows 10 VM
   2. ???
   3. Reproducible recipe that John can execute

## 2017-5-2

Current punch list:

   * fix weird freeze after VM startup
   * setup nextgen system management (isconf?)
   * add yusadge-like thing to track nextgen usage

Let's try to fix the freeze when the VM starts up.  How about upgrading
VirtualBox?  I'm downloading the debian x64 package for 5.2.22 along with the
extension pack.

I'm installing it now.

## 2017-5-16

Well the newer virtualbox was crashy.  Let's downgrade.

Ok, the lightdm session used for autologin is stored in `~/.dmrc`.  Delete the
session var to use the default session.

We're downgraded and working as before.  Perhaps next time we can trying
disabling aufs and see if that's what's causing the freezing.

I'm removing libvirt and crew since it's taking up RAM.  I've also remove
modemmanager for the same reason.

I've increased the video RAM to 128 MB for the guest.  Maybe that will help with
the hang.

## 2017-5-23

It's still a little "hangy" but not as bad.  Maybe we need to bump the video RAM to 256 MB?  The freezing seems worse when I'm running another X session.

Ok, so John and I talked and we decided to setup and walkthrough isconf 2i as a
candidate for the nextgen management platform.

## 2017-5-30

I've setup a base isconf 2i and installed a base Debian VM with it.  The next
step is to get it up on the internet.  Perhaps another DO VM.

## 2017-6-20

We've decided to use fattuba.com as the base domain for the nextgen
infrastructure for now.  Just to make things easy.

## 2017-7-11

John has created a Win10 VM on the HP pro in the middle of the wire rack or he
has one on a USB that he can give me.  Let's setup afn.fattuba.com subdomains.

I setup the following CNAMES:

   * isconf.afn.fattuba.com -> baadsvik.fattuba.com
   * gold.afn.fattuba.com -> baadsvik.fattuba.com
   * image.afn.fattuba.com -> baadsvik.fattuba.com

I setup an afn-isconf user on baadsvik and clone the afn-isconf repo there.
The next step is to create a base Debian Jessie image on the HP pro(backup Win10
VM first?)

## 2017-7-18

Booting up the HP pro in the middle of the middle rack to see what we've got.
Reset the root password to our usual one.  Looked at the Win10 VM.  We'll
probably have to start fresh and disable a bunch of services.  Let's not bother
backing it up.  Wiping the HP pro and starting with a fresh Debian Jessie
install.

Installed via Jessie live CD booted into Live mode.  This installs a full
desktop environment <- boo.  Let's try again booted into text-based installer
mode.  Same full desktop setup!  Perhaps it's because there was already a Debian
Jessie XFCE setup on there before?  Let's try formatting the drive.  That didn't
seem to work.  Trying the netinst iso image instead of the live one.

## 2017-7-25

netinst worked!  Now let's backup the base image using clonezilla.

Using our clonezilla vm on the vm server to save the freshly installed bare
Jessie.

## 2017-8-8

I'm installing isconf prereqs(make, rsync, resolvconf, etc) on the client host.  I installed fakeroot and rsync on the gold server.  I've added the following to /etc/dhcp/dhclient.conf to make sure our domain is set correctly:

    supersede domain-name "afn.fattuba.com";

I'm installing openssh-server on the client host.

Note: lock down the server to only allow rsync/scp.

## 2017-8-15

Looks like the clonezilla backup went well.  Let's try to install
stuff to get the user signon VM startup working.  We should get the
packages.list off of the hand built client.  Also /etc and /usr/local.
Nothing in /usr/local or /opt.  afn-nextgen hand built client is at
192.168.1.115.  I ended up locking down the server to rsync only using
rrsync from /usr/share/doc/rsync/scripts.  That way the hosts in the field
will only be able to read via rsync(no writes or other remove commands).

## 2017-9-12

Let's start adding packages.  Ok so lightdm and virtualbox are installed.
I think the next step is copying over the /home/user data and setting up the
aufs overlay.

## 2017-9-19

The tools for the overlay are up and running.  We need to copy over the data.

BTW, you'll also need the `/root/.ssh/id_rsa*` ssh keys on the client in order
to run rc.isconf the first time.

Next time, remove unused stanzas from isconf for clarity to avoid confusion.

## 2017-10-10

Copied John's Win10 VM over.  Don't know VM password for user "John".  I'll get
that from John so I can mess with the image.

## 2017-10-24

It looks like the virtualbox 4 guest additions hang Windows 10.  Let's try
upgrading to virtualbox 5 to see if we can get that to work.  I'm downloading
5.2 amd64 for debian.  Ok, let's use the [apt method
instead](https://www.virtualbox.org/wiki/Linux_Downloads#Debian-basedLinuxdistributions).

Ok, the Win 10 VM is up.  Let's play with it and see how it performs.  I need to
fixup the following:

   1. ~the guest clock is off~
   2. ~the mini bar needs to be hidden~

## 2017-11-7

~We also need to get the "log out" menu item working like it was in Win7.~

Here's how to update/modify the VM:

   1. login as root in a virtual terminal (ctrl-alt-1)
   1. `sudo systemctl stop handleclientsession`
   1. `sudo systemctl stop lightdm`
   1. `sudo pkill -u user`
   1. `sudo umount /home/user`
   1. `sudo mv /home/user /home/user_ootw`
   1. `sudo mv /home/gold/user /home/user`
   1. `sudo -u user sed -i '/^Language.*/a Session=xfce' /home/user/.dmrc`
   1. `sudo systemctl start lightdm`
   1. start virtual box
   1. modify stuff
   1. power down the VM
   1. delete the current "saved state" snapshot
   1. boot the VM
   1. set it to full screen mode
   1. save the state: `sudo -u user VBoxManage controlvm "Windows 10" savestate`
   1. `sudo systemctl stop lightdm`
   1. `sudo -u user sed -i '/^Session=/d' /home/user/.dmrc`
   1. `sudo mv /home/user /home/gold/user`
   1. `sudo mv /home/user_ootw /home/user`
   1. `sudo systemctl start handleclientsession`

I've enabled 3D/2D video acceleration and set the virtualization method to
"default" which ends up being hyper V.

I don't have a CD/DVD to test with so I'll need to find one.  I'm testing the
USB stuff now.  It looks like watchusb is watching the Win7 VM.  Let's switch
that over.  Audio works fine.  CD works fine.  Haven't testing CD/DVD burning
yet.  Next we should jump back on management(isconf) since that's what
John wants us to do.

## 2017-11-14

It looks like the disk filled up.  It was probably on the edge before I left
last week.  I've deleted the old Windows 7 VM to make space.  Let's shift back
over to working on isconf.  I'm copying over the VM now.  Let's research
bittorrent to make the VM distribution more efficient.

## 2017-11-28

I've upgraded virtualbox to 5.2 using isconf.  I've installed afn-nextgen
via isconf.  Now the Windows lightdm session isn't starting.  I need
to log in to the hand-built box to see how I did that.  I checked
/home/client/.xsession-errors.  It turns out that I still had virtualbox
config references to /home/user.  I switched those to /home/client.
I also need to install zenity.  Now virtualbox won't start.  It recommends a
reinstall so doing that now.  I had to change /home/user to /home/client in
/home/gold/client/Virtual*/*.vbox.  Now I need to install the virtualbox
extension pack

## 2017-12-5

It's up now.  Seems like it works!  Time to try to install on the optiplex.

## 2017-12-19

make was helpfully deleting intermediate files.... which of course breaks
things.  I've made a change to the main.mk file to fix this.  I also started
imaging the optiplex.  If that works, then we're ready for:

   1. a small local test rollout on Optiplexes probably in the cave
   2. a documented way to update the VM
   3. a way to log client sessions(yusadge, etc)

## 2018-1-9

The optiplex clone finished.  /etc/rc.isconf failed though.  I copied rc.isconf
over from the gold server and then started it.  That runs fine.  So it looks
like the version of /etc/rc.isconf in the clonezilla image is too old.  We
should probably update it and save a new image.  John's ultimate goal is to make
this optiplex "the gold server".

Let's start copying over the gold VM from the existing nextgen server.  I port
scanned the network looking for it like this: `nmap -p22 192.168.1.0/24`.
I tried to scp it but I can't scp as root.  Let's manually mod the `sshd_config`
to allow that temporarily.  It turns out that it's already enabled key-only.  So
let's copy a key over there.  Ok, now an rsync is in process.

There was an error message during virtualbox 5.x install.  It couldn't find the
kernel headers to build against.  Perhaps we need a reboot somewhere?

## 2018-1-30

Ok, retrying isconf to see if we can get past the vbox 5.x install issue.  If
this works, we still need to try a fresh install again to debug things.

## 2018-2-6

It ended up being a mismatch between the running kernel and the installed
headers.  It looks like we need to apt-get upgrade before installing
virtualbox-5.2.  Alternatively let's make sure we have headers for the currently
running kernel installed.

It looks like a VM in saved state can't be moved from machine to machine.  So
we'll have to do a one-time full boot when updating the VM then save state.

There are still some graphics glitches on the solitaire startup screen.

## 2018-2-13

Ok, let's try a fresh install on the dell to make sure the virtualbox upgrade
works.

## 2018-2-27

Ok, the restore worked.  Now running isconf.

## 2018-3-13

I've ordered a 128 GB usb 3.0 flash drive for the Win10 image.

I've crossed over the host with the Win10 VM and the target to copy over
/home/gold.  The switch is only fast ethernet and this method allows gig.

Ok so the HP Pro standing up has a very old version of /home/gold.  Let's try
getting it from the HP pro that's laying down.

Ok, that seems to be working.

## 2018-3-27

I'm copying /home/gold onto my 128 GB flash drive.  I had to reformat it from
fat32 to ntfs because the files are bigger than 4G.

## 2018-4-10

It seems like Windows 10 really wants to update itself.  Let's do that today
before copying.  Well doing the update will take awhile.  Let it run until next
Tuesday.  John is moving the stuff so I'll put it back the way it was.  We can
continue this later.

## 2018-4-17

I copied the Windows VM onto my USB drive after John disabled some stuff in the
image to make it faster.  Next we should script the VM update.

Ugh, the Win10 Guest is unusable for 5 min after restore.  Various processes are
consuming 100% disk:

   * Service Host...
   * Antimalware Service Executable
   * (others)

After that, Microsoft Malware Protection Command Line Utility consumes
100% CPU.  How do we disable that?

Ok, the scripts to update the VM are written.  I need to do more testing with
them.

## 2018-5-01

Found a bug in afn-nexgen vm update scripts.  Fixed that.  Windows 10 is still
trying to run updates/malware scans/etc that consume all our disk I/O.  We need
to shut that stuff down.

## 2018-5-8

Let's turn all that Windows 10 junk off.  First: `Antimalware Service
Executable`  Let's try [this](https://blog.emsisoft.com/en/28620/antimalware-service-executable/).  Rebooting now.

Ok, now let's disable automatic updates.  Try [this](https://www.easeus.com/todo-backup-resource/how-to-stop-windows-10-from-automatically-update.html).  Rebooting now.  That seems to have fixed it!  We'll see next week.

## 2018-5-22

"Windows 10 Upgrade Helper" is still running.  Let's try to disable it with
[this](https://social.technet.microsoft.com/Forums/en-US/b4216132-56c8-4a26-a9ba-aaed31686775/how-can-i-block-windows-10-upgrade-assistant-from-reinstalling-itself?forum=win10itprogeneral).

## 2018-6-5

The VM seems to be locking up.  Let's go back to the last snapshot and see if
that fixes it.  Yup, that seems to work


## 2018-6-12

The VM seems to still be working great!  I see an item in the start menu
that says "Update Pending.  Install the Update"

## 2018-7-24

git-annex can use bittorrent as a source!  Perhaps we should use git-annex to
manage images in general for that reason.

I need to ask John for a test lab at this point I think.

## 2018-8-14

Let's try overlayfs instead of aufs.  It's only available on stretch and not
jessie AFAIK.  Perhaps we can use the kernel from jessie-backports?

Also there are some indications that KVM can run Windows 10 with [great graphics performance now](https://heiko-sieger.info/running-windows-10-on-linux-using-kvm-with-vga-passthrough/).  Perhaps if/when we upgrade to Debian Stretch we can try KVM again?

More [Linux KVM Windows 10 hackery](https://medium.com/@dubistkomisch/gaming-on-arch-linux-and-windows-10-with-vfio-iommu-gpu-passthrough-7c395dde5c2)

## 2018-9-25

I've now got a box with Debian Stretch(9) and KVM with virt-manager installed.
I ran:

    adduser client libvirt
    adduser client libvirt-qemu

So that "client" can manage VMs without room permissions.

I'm exporting the VM from the Debian 8 Virtualbox test machine so I can import
it.  I ran out of disk on the Debian 8 machine so I rsync'd the stuff over to
the new Debian 9 host.  I've install virtualbox there and have started the
export.  Once that's done, I'll try importing via virt-manager.

## 2018-10-2

The ova has been exported from VirtualBox.  Now I need to [import it into
kvm](https://access.redhat.com/articles/1351963).  It seems like virt-v2v needs
to be run as root so that it can access the system storage pools.  Got the
following error:

    root@nextgen-2:/home/client/Documents# virt-v2v -i ova Windows\ 10.ova -o libvirt -of qcow2 -os default
    [   0.0] Opening the source -i ova Windows 10.ova
    virt-v2v: warning: could not parse ovf:Name from OVF document
    virt-v2v: warning: ova disk has an unknown VMware controller type (20),
    please report this as a bug supplying the *.ovf file extracted from the ova
    [ 455.4] Creating an overlay to protect the source from being modified
    [ 457.9] Initializing the target -o libvirt -os default
    [ 457.9] Opening the overlay
    [ 509.8] Inspecting the overlay
    [ 513.3] Checking for sufficient free disk space in the guest
    [ 513.3] Estimating space required on target for each disk
    [ 513.3] Converting Windows 10 Pro to run on KVM
    virt-v2v: warning: Neither rhev-apt.exe nor vmdp.exe can be found.  Unable
    to install one of them.
    virt-v2v: error: libguestfs error: mkdir_p: /Windows/Drivers/VirtIO:
    Read-only file system

    If reporting bugs, run virt-v2v with debugging enabled and include the
    complete output:

      virt-v2v -v -x [...]

Need to figure out how to get past this

## 2018-10-16

I'm running virt-v2v with debugging enabled as requested above.  I'm having
trouble using virt-v2v to import the ova.  So trying 2 things instead:
   1. untarring the .ova manually
   2. cloning the VirtualBox VM so that it'll squash all the snapshots

Then I'm going to take the results of 1 of those 2 and convert that .vdi to a
qcow2 disk and create a new KVM VM using that disk image.

## 2018-10-30

I'm using `qemu-img` to [convert the cloned vdi file](https://computingforgeeks.com/how-to-convert-virtualbox-disk-image-vdi-and-img-to-qcow2-format/).  It should take a while so I'll pick this back up next Tuesday.

I'm interested in trying ZFS instead of an overlay FS someday also.

## 2018-11-06

So I've created a new KVM VM from that qcow image but the boot gets stuck at
"booting from hard disk".  Maybe [this is the problem](https://serverfault.com/questions/899290/kvm-gets-stuck-at-booting-from-hard-disk).

Ok I ran `apt-get install ovmf` so that I could use UEFI to boot the image.
Then I clicked "configure before installation" so I can switch to boot from BIOS
to UEFI and chipset to Q35.  This also required me to switch from IDE to SATA
disk controller.

So Windows boots now and of course it's trying to install updates.  Also the
display size is 800x600 so I'll have to figure that out.

## 2018-11-27

It looks like Windows is updated now but it needs to be activated.  Let's try
[this](http://bart.vanhauwaert.org/hints/installing-win10-on-KVM.html) to fix
the video resolution.  Ok so that worked.  Now for auto resizing to work I need
to [install the spice tools](https://www.felso.net/running-windows-on-linux-with-qemukvm-using-virtual-machine-manager/) in windows.  I think those tools include the QXL driver so I probably don't need to install that in the future.

Now we need to test:

   * audio
   * USB devices
   * CDrom access

## 2019-6-27

I'm playing around with this again on my new personal laptop since I need a
win10 VM for [automated windows install](./afn_windows_unattended.md) anyway.
Ok so [these](https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe) are the spice tools I'm installing on the win10
guest.  Now the guest resolution automatically adjusts to the host virt-manager
window!

I've installed the [spice webdavd](https://www.spice-space.org/download/windows/spice-webdavd/)
for [folder sharing between host and guest](https://www.spice-space.org/spice-user-manual.html#_folder_sharing). Now I'm trying [this](http://nts.strzibny.name/how-to-set-up-shared-folders-in-virt-manager/)
to see if I can get it to work.  Now I'm trying [this](https://www.guyrutenberg.com/2018/10/25/sharing-a-folder-a-windows-guest-under-virt-manager/).  No-go.  I'm getting `The network name cannot be found`.  I'll probably bail and just setup Samba on the host.

## 2019-6-30

We should [try the bridge helper](https://blog.wikichoon.com/2016/01/qemusystem-vs-qemusession.html?m=1).

## 2019-7-9

Wow, this could still work.  [PCI passthrough with KVM](https://www.jupiterbroadcasting.com/132466/the-one-about-gpu-passthrough-linux-unplugged-308/) is a thing now.

Trying to replace the user-mode networking with the [bridged network](https://jonaspfannschmidt.com/libvirt_session.html).  Ok that
seems to work.  I got virbr0 going on qemu://system and am bridge to
that using the bridge helper now.  I've also setup samba locally and
can reach my home dir on the host using `\\potts\tubaman`.  I had to set my smb
password using `sudo smbpasswd -a tubaman`.

I tried switch video to virtio but it ruined my display scaling.  Going back
to QXL.  I've mapped `\\potts\tubaman` to the Z: drive and set it to
autoreconnect at boot.  I'll probably want to map Documents, Pictures, etc to
those directories in my host Linux home dir.
