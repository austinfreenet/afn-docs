## 2023-2-21


The NAS should be accessible from the internet but isn't currently.  I've got
some notes from John regarding IPs, ports and logins.  I'm using 101BGuest AP
downstairs(no WPA2 key).  I've added my home IP to the whitelist for the NAS on
the pfSense firewall.  I get this from home:

    tubaman@hawaiianwonder:~$ smbclient '\\*************\****'
    do_connect: Connection to ************* failed (Error NT_STATUS_IO_TIMEOUT)

But I'm able to login from my laptop:

    tubaman@potts:~$ smbclient -U '************' '\\*************\****'
    Enter ************** password:
    Try "help" to get a list of possible commands.
    smb: \> ls
      .                                   D        0  Fri Sep  9 13:48:05 2022
      ..                                  D        0  Sat Feb  4 18:57:20 2023
      WINshares                           D        0  Fri Oct 28 09:56:01 2022
      .windows                           AH        0  Fri Nov 20 18:11:34 2020
      iocage                              D        0  Sun Sep  4 07:57:33 2022
    
    		3766996224 blocks of size 1024. 2399728691 blocks available
    smb: \>

## 2023-2-28

I'm running tcpdump from hawaiianwonder to see what packets are getting blocked.
Looks like syns to both 139 and 445 are not getting ack'd.  Let's try enabling
"log packets" for that rule in pfSense to see if it's even hitting the rule.
