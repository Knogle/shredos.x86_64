DESCRIPTION = "Secure disk wiping utility derived from dwipe"
HOMEPAGE = "https://github.com/PartialVolume/nwipe"
LICENSE = "GPL-3.0-or-later"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRC_URI = "git://github.com/PartialVolume/nwipe.git;branch=master;protocol=https"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

inherit autotools pkgconfig

DEPENDS = "ncurses parted libconfig openssl"

# If you need to pass any additional flags
# EXTRA_OECONF += ""

# Ensure pkg-config is available
DEPENDS += "pkgconfig-native"

# If automake and autoconf are needed explicitly
# DEPENDS += "automake-native autoconf-native"

# Remove any static libraries if not needed
# EXTRA_OECONF += "--disable-static"
