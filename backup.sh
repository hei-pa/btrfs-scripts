#!/bin/bash

set -e
set -o pipefail

SOURCE_UUID=$1
DESTINATION_UUID=$2

TARGET=$3
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

SOURCE_MOUNTPOINT=$(findmnt -nr -o TARGET -S UUID=$SOURCE_UUID)
DESTINATION_MOUNTPOINT=$(findmnt -nr -o TARGET -S UUID=$DESTINATION_UUID)

# Make sure the path exists
mkdir -p $SOURCE_MOUNTPOINT/.snapshots/$TARGET

# Create the snapshot and sync
/usr/bin/btrfs subvolume snapshot -r $SOURCE_MOUNTPOINT/$TARGET $SOURCE_MOUNTPOINT/.snapshots/$TARGET/$TARGET@$TIMESTAMP
/usr/bin/sync

## Snapshot is taken and will be send now ...

# Make sure the path exists
mkdir -p $DESTINATION_MOUNTPOINT/$TARGET

if [ -e $SOURCE_MOUNTPOINT/.snapshots/$TARGET/last ];
then

	echo "Send incremental snapshot"
	/usr/bin/btrfs send -vvv -p $SOURCE_MOUNTPOINT/.snapshots/$TARGET/last $SOURCE_MOUNTPOINT/.snapshots/$TARGET/$TARGET@$TIMESTAMP | /usr/bin/btrfs receive -vvv $DESTINATION_MOUNTPOINT/$TARGET/

else

	echo "Send full snapshot"
    /usr/bin/btrfs send -vvv $SOURCE_MOUNTPOINT/.snapshots/$TARGET/$TARGET@$TIMESTAMP | /usr/bin/btrfs receive -vvv $DESTINATION_MOUNTPOINT/$TARGET/

fi

# create the source 'last' link to reference
/usr/bin/rm -f $SOURCE_MOUNTPOINT/.snapshots/$TARGET/last
/usr/bin/ln -s $SOURCE_MOUNTPOINT/.snapshots/$TARGET/$TARGET@$TIMESTAMP $SOURCE_MOUNTPOINT/.snapshots/$TARGET/last

# create the destination 'last' link to reference
/usr/bin/rm -f $DESTINATION_MOUNTPOINT/$TARGET/last
/usr/bin/ln -s $DESTINATION_MOUNTPOINT/$TARGET/$TARGET@$TIMESTAMP $DESTINATION_MOUNTPOINT/$TARGET/last

