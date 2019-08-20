#!/bin/bash
# Turn a Clonezilla Live USB drive into a genesis drive

set -e
set -o pipefail

DRIVE=$1

test -z "$DRIVE" && { echo "error: must provide a drive(ex: /dev/sdb)" >&2; exit 1; }

TRAN=$(lsblk -So NAME,TRAN | grep $(basename $DRIVE) | awk '{ print $2 '})
test -z "$TRAN" && { echo "error: failed to get drive transport" >&2; exit 2; }
if [ "$TRAN" != "usb" ]; then
	echo "error: it looks like $DRIVE isn't a USB drive" >&2
	exit 2
fi

PART=${DRIVE}1

test $(sudo fatlabel $PART | tail -n1) != "GENESISDRV" && { echo "error:
this drive isn't labeled GENESISDRV" >&2; exit 3; }

echo "mounting filesystem using GIO(gvfs)"
MOUNTPOINT=$(gio mount --device=$PART | awk '{ print $4 }')
test -z "$MOUNTPOINT" && { echo "error: failed find mountpoint" >&2; exit 3; }
