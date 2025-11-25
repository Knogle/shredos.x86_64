################################################################################
#
# nwipe
#
################################################################################

# Select the Git reference based on the Kconfig choice.
ifeq ($(BR2_PACKAGE_NWIPE_VERSION_STABLE),y)
NWIPE_VERSION = 051e1aa
else ifeq ($(BR2_PACKAGE_NWIPE_VERSION_GIT_REVISION),y)
NWIPE_VERSION = $(call qstrip,$(BR2_PACKAGE_NWIPE_GIT_REVISION))
else
# Fallback – should not happen because the choice enforces exactly one option
NWIPE_VERSION = 051e1aa
endif

# Default Git repository URL (never empty).
NWIPE_SITE = https://github.com/martijnvanbrummelen/nwipe.git
ifneq ($(call qstrip,$(BR2_PACKAGE_NWIPE_SITE)),)
NWIPE_SITE = $(call qstrip,$(BR2_PACKAGE_NWIPE_SITE))
endif

NWIPE_SITE_METHOD = git

NWIPE_DEPENDENCIES = ncurses parted dmidecode coreutils libconfig

define NWIPE_INITSH
	(cd $(@D) && \
		cp ../../../package/nwipe/002-nwipe-banner-patch.sh . && \
		./002-nwipe-banner-patch.sh && \
		PATH="../../host/bin:${PATH}" ./autogen.sh)
endef

NWIPE_POST_PATCH_HOOKS += NWIPE_INITSH

$(eval $(autotools-package))

