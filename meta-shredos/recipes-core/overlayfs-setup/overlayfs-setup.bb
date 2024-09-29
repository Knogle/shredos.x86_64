SUMMARY = "OverlayFS setup for writable root filesystem"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://overlayfs-setup.sh \
           file://overlayfs.service"

inherit systemd

SYSTEMD_SERVICE_${PN} = "overlayfs.service"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/overlayfs-setup.sh ${D}${sbindir}/overlayfs-setup.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/overlayfs.service ${D}${systemd_system_unitdir}/overlayfs.service
}
