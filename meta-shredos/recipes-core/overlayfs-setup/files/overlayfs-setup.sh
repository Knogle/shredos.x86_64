#!/bin/sh -e

# Mount tmpfs on /mnt
mount -t tmpfs tmpfs /mnt

# Create necessary directories
mkdir -p /mnt/lower
mkdir -p /mnt/upper
mkdir -p /mnt/work

# Move the current root to lower
mount --move / /mnt/lower

# Mount tmpfs for upper
mount -t tmpfs tmpfs /mnt/upper

# Set up OverlayFS
mount -t overlay overlay -o lowerdir=/mnt/lower,upperdir=/mnt/upper,workdir=/mnt/work /

# Remount necessary filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -t devpts devpts /dev/pts
