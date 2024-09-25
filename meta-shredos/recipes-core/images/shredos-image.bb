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
"

IMAGE_FEATURES += "splash"

# Include any other packages or configurations
