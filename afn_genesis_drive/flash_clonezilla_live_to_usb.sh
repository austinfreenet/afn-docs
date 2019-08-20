#!/bin/bash

set -e
set -o pipefail

ZIPFILE=$1
DRIVE=$2

test -z "$ZIPFILE" && { echo "error: must provide a zipfile" >&2; exit 1; }
test -z "$DRIVE" && { echo "error: must provide a drive(ex: /dev/sdb)" >&2; exit 1; }

TRAN=$(lsblk -So NAME,TRAN | grep $(basename $DRIVE) | awk '{ print $2 '})
test -z "$TRAN" && { echo "error: failed to get drive transport" >&2; exit 2; }
if [ "$TRAN" != "usb" ]; then
	echo "error: it looks like $DRIVE isn't a USB drive" >&2
	exit 2
fi

echo "creating partition on $DRIVE"
sudo sfdisk $DRIVE < usb.sfdisk
PART=${DRIVE}1

echo "waiting for disk scanning to complete"
timeout 5 bash -c "while ! [ -e $PART ]; do sleep 0.200; done" 

echo "formatting filesystem $PART"
sudo mkfs.vfat -F 32 -n GENESISDRV $PART

echo "waiting for filesystem label"
timeout 5 bash -c "while [ $(sudo fatlabel $PART | tail -n1) != "GENESISDRV" ]; do sleep 0.200; done"

echo "mounting filesystem using GIO(gvfs)"
MOUNTPOINT=$(gio mount --device=$PART | awk '{ print $4 }')
test -z "$MOUNTPOINT" && { echo "error: failed find mountpoint" >&2; exit 3; }

echo "unzipping $ZIPFILE to $MOUNTPOINT"
unzip $ZIPFILE -d $MOUNTPOINT

echo "making $DRIVE bootable"
sudo bash $MOUNTPOINT/utils/linux/makeboot.sh -b $PART

echo "unmounting $MOUNTPOINT"
gio mount -u $MOUNTPOINT
