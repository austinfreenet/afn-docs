# AFN Yusadge Client Project

## 2015-03-08

So today I tried getting Win 10 64-bit up and running with Visual
Studio installed.  But I couldn't get the VirtualBox Guest additions
to install.  So I went and installed AFN's Win 7 64-bit ISO, then
Visual Studio.  After that I still couldn't figure out how to compile for
64-bit.  So I went back to Google and found a bunch of [options I had to
set](https://social.msdn.microsoft.com/Forums/en-US/3820a035-019b-4a11-803c-42ebffcb497f/visual-basic-2008-express-does-it-generate-32bit-or-64bit-exe-files?forum=Vsexpressvb).
That seems to work.  So now I have a 64-bit build of Yusadge.  The next
step is to see if I can add the passive mode option.


## 2015-03-29

Let's run our version of Yusadge to see if it actually sends stuff.
So I built YusadgeTimer.  Ok so the prebuilt stuff is running.  Let's try
to get it to report faster than an hour for testing purposes.

According to John Neal's README, there should be a file tranferred right when
you start Yusadge.  However, I can't see any file uploaded from my hostname.
I've got to get the current version to work before I can start making changes!
