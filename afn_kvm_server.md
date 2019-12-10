# Linux KVM Server Project Engineering Notes

## 2019-12-10

John has a little server that he's installed Debian on + KVM.  We're trying to
get the VMs to run well.  The goal is to use the machine as a teaching platform
using the Windows VMs as clean base images for which to run testing software.

Right now the disk I/O on this server is a little lack-luster.  It may be the
disk itself.  Maybe we can tune things?

Here's an idea: https://serverfault.com/questions/407842/incredibly-low-kvm-disk-performance-qcow2-disk-files-virtio

First let's test the host disk I/O.  I've run `apt-get install lshw` to inspect
the type of disk.  `lsscsi` says that sda is an [ST3250312AS](https://www.newegg.com/p/N82E16822148699).  It's 7200 RPM SATA 6Gb/s with NCQ.  Let's run an actual [throughput test](https://www.cyberciti.biz/faq/howto-linux-unix-test-disk-performance-with-dd-command/).  The first dd test showed 68.1 MB/s which is 544 Mb/s.

The hdparm read tests showed:

    ryan@debianTaradi00:~$ sudo hdparm -tT /dev/sda

    /dev/sda:
     Timing cached reads:   26224 MB in  1.98 seconds = 13227.32 MB/sec
     Timing buffered disk reads: 366 MB in  3.01 seconds = 121.44 MB/sec
    ryan@debianTaradi00:~$ sudo hdparm -tT /dev/sda

    /dev/sda:
     Timing cached reads:   26194 MB in  1.98 seconds = 13211.55 MB/sec
     Timing buffered disk reads: 364 MB in  3.00 seconds = 121.33 MB/sec

It seems low.  According to a [benchmarking site](https://hdd.userbenchmark.com/SpeedTest/2897/ST3250312AS), we're in the ballpark.

Now let's move on to KVM guest performance.  We need a way to measure Windows 10
I/O performance first.  [DiskSpd](https://gallery.technet.microsoft.com/DiskSpd-A-Robust-Storage-6ef84e62) feels promising.  Ok first run is:

Here's the first run:

    C:\Users\john\Desktop\amd64>diskspd -b4K -t2 -r -o32 -d10 -Sh testfile.dat

    Command Line: diskspd -b4K -t2 -r -o32 -d10 -Sh testfile.dat
    
    Input parameters:
    
            timespan:   1
            -------------
            duration: 10s
            warm up time: 5s
            cool down time: 0s
            random seed: 0
            path: 'testfile.dat'
                    think time: 0ms
                    burst size: 0
                    software cache disabled
                    hardware write cache disabled, writethrough on
                    performing read test
                    block size: 4096
                    using random I/O (alignment: 4096)
                    number of outstanding I/O operations: 32
                    thread stride size: 0
                    threads per file: 2
                    using I/O Completion Ports
                    IO priority: normal
    
    System information:
    
            computer name: DESKTOP-SJ5N5IK
            start time: 2019/12/10 20:53:15 UTC
    
    Results for timespan 1:
    *******************************************************************************
    
    actual test time:       10.02s
    thread count:           2
    proc count:             2
    
    CPU |  Usage |  User  |  Kernel |  Idle
    -------------------------------------------
       0|  97.66%|   6.40%|   91.26%|   2.34%
       1|  97.82%|   0.16%|   97.66%|   2.18%
    -------------------------------------------
    avg.|  97.74%|   3.28%|   94.46%|   2.26%
    
    Total IO
    thread |       bytes     |     I/Os     |    MiB/s   |  I/O per s |  file
    ------------------------------------------------------------------------------
         0 |       300134400 |        73275 |      28.58 |    7316.26 | testfile.dat (8192KiB)
         1 |        61763584 |        15079 |       5.88 |    1505.59 | testfile.dat (8192KiB)
    ------------------------------------------------------------------------------
    total:         361897984 |        88354 |      34.46 |    8821.85
    
    Read IO
    thread |       bytes     |     I/Os     |    MiB/s   |  I/O per s |  file
    ------------------------------------------------------------------------------
         0 |       300134400 |        73275 |      28.58 |    7316.26 | testfile.dat (8192KiB)
         1 |        61763584 |        15079 |       5.88 |    1505.59 | testfile.dat (8192KiB)
    ------------------------------------------------------------------------------
    total:         361897984 |        88354 |      34.46 |    8821.85
    
    Write IO
    thread |       bytes     |     I/Os     |    MiB/s   |  I/O per s |  file
    ------------------------------------------------------------------------------
         0 |               0 |            0 |       0.00 |       0.00 | testfile.dat (8192KiB)
         1 |               0 |            0 |       0.00 |       0.00 | testfile.dat (8192KiB)
    ------------------------------------------------------------------------------
    total:                 0 |            0 |       0.00 |       0.00


Ok, so now I'm installing the [virtio Windows
drivers](https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html#virtio-win-direct-downloads).
I've mounted the iso and install the qemu guest agent, viostor and vioscsi.
After rebooting, Windows won't boot.  Let's try [this
workaround](https://superuser.com/a/1253728).  Didn't work.  Maybe I need to
install all the virtio drivers.  [Adding a new virtio drive and then switching
the boot drive over](https://superuser.com/a/1095112) worked.

Now let's rerun the test above. Wow!


    C:\Users\john\Desktop\amd64>diskspd.exe -b4K -t2 -r -o32 -d10 -Sh testfile.dat
    
    Command Line: diskspd.exe -b4K -t2 -r -o32 -d10 -Sh testfile.dat
    
    Input parameters:
    
            timespan:   1
            -------------
            duration: 10s
            warm up time: 5s
            cool down time: 0s
            random seed: 0
            path: 'testfile.dat'
                    think time: 0ms
                    burst size: 0
                    software cache disabled
                    hardware write cache disabled, writethrough on
                    performing read test
                    block size: 4096
                    using random I/O (alignment: 4096)
                    number of outstanding I/O operations: 32
                    thread stride size: 0
                    threads per file: 2
                    using I/O Completion Ports
                    IO priority: normal
    
    System information:
    
            computer name: DESKTOP-SJ5N5IK
            start time: 2019/12/10 21:38:08 UTC
    
    Results for timespan 1:
    *******************************************************************************
    
    actual test time:       10.02s
    thread count:           2
    proc count:             2
    
    CPU |  Usage |  User  |  Kernel |  Idle
    -------------------------------------------
       0| 100.00%|   4.68%|   95.32%|   0.00%
       1| 100.00%|   3.12%|   96.88%|   0.00%
    -------------------------------------------
    avg.| 100.00%|   3.90%|   96.10%|   0.00%
    
    Total IO
    thread |       bytes     |     I/Os     |    MiB/s   |  I/O per s |  file
    ------------------------------------------------------------------------------
         0 |       699727872 |       170832 |      66.63 |   17056.26 | testfile.dat (8192KiB)
         1 |       851058688 |       207778 |      81.04 |   20745.03 | testfile.dat (8192KiB)
    ------------------------------------------------------------------------------
    total:        1550786560 |       378610 |     147.66 |   37801.29
    
    Read IO
    thread |       bytes     |     I/Os     |    MiB/s   |  I/O per s |  file
    ------------------------------------------------------------------------------
         0 |       699727872 |       170832 |      66.63 |   17056.26 | testfile.dat (8192KiB)
         1 |       851058688 |       207778 |      81.04 |   20745.03 | testfile.dat (8192KiB)
    ------------------------------------------------------------------------------
    total:        1550786560 |       378610 |     147.66 |   37801.29
    
    Write IO
    thread |       bytes     |     I/Os     |    MiB/s   |  I/O per s |  file
    ------------------------------------------------------------------------------
         0 |               0 |            0 |       0.00 |       0.00 | testfile.dat (8192KiB)
         1 |               0 |            0 |       0.00 |       0.00 | testfile.dat (8192KiB)
    ------------------------------------------------------------------------------
    total:                 0 |            0 |       0.00 |       0.00


That's about 3.5X the performance.

Now let's install the spice guest tools for video performance.  Oh, that spice
guest tools installer installs all the virtio stuff too.  We should just do that
from now on. Ok so I also had to [add a spice channel] to get the auto resizing
working.
