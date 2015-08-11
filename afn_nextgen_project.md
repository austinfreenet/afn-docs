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

The image is back onto the client so not I'm installed XFCE, virt-manager and
lightdm.  The I need to install a Windows 7 KVM VM.  I've setup an apt proxy VM
and
[configured](https://help.ubuntu.com/community/AptGet/Howto#APT_configuration_file_method) the nextgen image to use it.  I also installed
firmware-realtek.  I'm saving the image via clonezilla again.
