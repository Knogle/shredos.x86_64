DESCRIPTION = "ShredOS Image with nwipe utility"
LICENSE = "MIT"

inherit core-image

IMAGE_INSTALL += "\
  bash \
  busybox \
  e2fsprogs \
  hdparm \
  smartmontools \
  dmidecode \
  coreutils \
  nwipe \
  overlayfs-setup \
  lftp \
  wget \
  nwipe-launcher \
"

IMAGE_FEATURES += "splash"

# Include any other packages or configurations

# Systemd als Init-System festlegen
DISTRO_FEATURES:append = "usrmerge systemd"
VIRTUAL-RUNTIME_init_manager = "systemd"
VIRTUAL-RUNTIME_initscripts = ""
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"

# Read-only Root-Filesystem aktivieren
IMAGE_FEATURES += "read-only-rootfs"
