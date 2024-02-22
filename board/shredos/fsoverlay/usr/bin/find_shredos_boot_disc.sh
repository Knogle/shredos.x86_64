#!/bin/bash
#
# This program looks for any exfat or fat32 filesystems, it then
# examines the filesystem, looking for a kernel file or .img or .iso
# file that has the same version number as the booted ShredOS. Once
# the boot USB has been found this script outputs the drive name in 
# the following form, example being /dev/sdc etc
#
version=$(cat /etc/shredos/version.txt)
drive_dir="boot_tmp"
drive=""

# Create a directory to mount the USB stick onto.
test -d "$drive_dir"
    if [ $? != 0 ]
    then
        mkdir "$drive_dir"
    fi
#
# Search every disc on the system for a exfat or fat32 filesystem, mount each
# in turn and see if it could be our boot disc by examining the version on the
# disc against the booted version. Supports vanila ShredOS and Ventoy boot discs.
#
fdisk -l | grep -i "exfat\|fat16\|fat32" | awk '{print $1}' | while read drive ;
do
	mount $drive $drive_dir

	# Check for correct version of ShredOS on a vanilla ShredOS USB drive
	test -f "$drive_dir/boot/version.txt"
    	if [ $? == 0 ]
    	then
			version_on_USB=$(cat "$drive_dir/boot/version.txt")
			if [[ "$version" == "$version_on_USB" ]]
			then
				printf "$drive"
				umount $drive_dir
				break;
		fi
	fi

	# Check for correct version of a ShredOS .img or .iso  on a Ventoy USB drive
	test -f "$drive_dir/shredos-$version"*
        if [ $? == 0 ]
        then
		printf "$drive"
		umount $drive_dir
                break;  
        fi

	umount $drive_dir
done
