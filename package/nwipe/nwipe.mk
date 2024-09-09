################################################################################
#
# nwipe
#
################################################################################

# Verwende das Submodul unter external/nwipe auf der aes-ctr Branch
NWIPE_VERSION = aes-ctr
NWIPE_SITE = NO_SITE
NWIPE_DEPENDENCIES = ncurses parted dmidecode coreutils

# Der Pfad, in dem das Submodul initialisiert wurde
NWIPE_SUBMODULE_PATH = $(TOPDIR)/external/nwipe

define NWIPE_INITSH
	(cd $(NWIPE_SUBMODULE_PATH) && cp ../../../package/nwipe/002-nwipe-banner-patch.sh $(NWIPE_SUBMODULE_PATH) && ./002-nwipe-banner-patch.sh && PATH="../../host/bin:${PATH}" ./autogen.sh);
endef

NWIPE_POST_PATCH_HOOKS += NWIPE_INITSH

# Deaktiviere den Download-Schritt
define DOWNLOAD_NWIPE
	true
endef

# Kopiere den Quellcode aus dem Submodul an den Build-Pfad
define NWIPE_EXTRACT_CMDS
	rsync -a $(NWIPE_SUBMODULE_PATH)/ $(@D)/
endef

$(eval $(autotools-package))

