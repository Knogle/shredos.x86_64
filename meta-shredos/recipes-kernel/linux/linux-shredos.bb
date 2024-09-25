DESCRIPTION = "Custom Linux kernel for ShredOS"
LICENSE = "GPL-2.0"

inherit kernel

SRC_URI = "git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git;branch=linux-5.10.y;protocol=https"

SRCREV = "${AUTOREV}"

KERNEL_CONFIG_FRAGMENTS = "file://defconfig"

# If you have patches
# SRC_URI += "file://0001-custom-patch.patch"

# Specify any additional kernel configurations
