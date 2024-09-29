SUMMARY = "Launcher script for nwipe"
LICENSE = "GPL-3.0-or-later"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0-only;md5=c79ff39f19dfec6d293b95dea7b07891"

SRC_URI = "file://nwipe_launcher.sh \
           file://nwipe-launcher.service"

inherit systemd

SYSTEMD_SERVICE_${PN} = "nwipe-launcher.service"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/nwipe_launcher.sh ${D}${bindir}/nwipe_launcher.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/nwipe-launcher.service ${D}${systemd_system_unitdir}/nwipe-launcher.service
}
