# Windows Unattended Project Notebook

We want to create a fully unattended Windows 10 install.  This is not imaging
but instead scripted install.

## 2019-3-26

Let's checkout [unattended](http://unattended.sourceforge.net/).  It's in svn so
let's use git-svn:

    git svn clone https://svn.code.sf.net/p/unattended/code -T trunk -t branches -t tags unattended-code

John gave me the Windows 10 iso and license key I should use.  I figured I'd
test using virtualbox VM.  How do I create an answer file for Windows 10?
[This](https://www.intowindows.com/how-to-create-unattended-windows-10-usb-or-iso/) seems promising.

## 2019-3-27

I got a BSOD when trying to install Win10 on VirtualBox.  Perhaps it's an issue
with VirtualBox machine settings?  The Win10 install is in a BSOD reboot
loop.  Tried EFI... didn't work.  Tried to [change pointing device and
disable floppy](https://windowsreport.com/windows-10-virtualbox/)...didn't
work.  Deleted and recreated the VM with floppy
disabled and pointing device changed.  There's [some
indication](afn_nextgen_project.md#2017-5-2) that the issue is related
to the version of VirtualBox.  Let's upgrade and test that theory.  Ok,
Upgraded to 5.2.26.  Seems to boot into the install now.  I also installed
the [extension pack](https://download.virtualbox.org/virtualbox/5.2.26/).

## 2019-3-28

Install continuing.  Selecting "offline account" at the bottom.  Install
succeeded.  Let's try to create the answer file as above.

## 2019-4-01

Easier idea.  Let's try to find a pre-made Win10 answer file that we can just
try.  Looks like not.  So let's create one.  First we need to create a USB image
that we can use to install Win10.  The autounattend.xml file goes on that.  I'm
following [this guide](https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10) that uses the default Microsoft tools.  Wow, export of install.wim file takes a *looooooong* time.  I'm on `Setting up an answer file environment` step 6.

## 2019-4-09

I'm unable to select distribution share.  I'm restarting the program.  I had to
follow [this doc](https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/wsim/create-or-open-a-distribution-share#create-a-distribution-share-using-windowssim) to create the distribution share.  Now I'm creating the answer file.  Ok, now we're [defining the product key](https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10#definning_productkey).  I've saved the answer file.  Now I need to create the USB install media.

## 2019-6-25

I've got this new personal laptop so I need to copy over the Win10 VM from my
old laptop.  I'm going to copy over the iso and key from stark then bring it up
on libvirt instead of virtualbox.

## 2019-6-26

What about using bash for Windows do run isconf?  Can we run Windows .exe's from
bash?  It looks like [you can](https://www.howtogeek.com/285082/how-to-run-windows-programs-from-windows-10s-bash-shell/).

Ok so I'm up and runnng with a win10 KVM guest using notes from the [nextgen
project](./afn_nextgen_project.md).   Now I'm installing the [virtio drivers](https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html#virtio-win-direct-downloads).
