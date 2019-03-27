# Windows Unattended Project Notebook

We want to create a fully unattended Windows 10 install.  This is not imaging
but instead scripted install.

## 2019-3-26

Let's checkout [unattended](http://unattended.sourceforge.net/).  It's in svn so
let's use git-svn:

    git svn clone https://svn.code.sf.net/p/unattended/code -T trunk -t tags -t branches

John gave me the Windows 10 iso and license key I should use.  I figured I'd
test using virtualbox VM.  How do I create an answer file for Windows 10?
[This](https://www.intowindows.com/how-to-create-unattended-windows-10-usb-or-iso/) seems promising.
