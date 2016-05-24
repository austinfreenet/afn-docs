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
