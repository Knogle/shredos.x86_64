################################################################################
#
# nwipe
#
################################################################################

# Select the Git reference based on the Kconfig choice.
# We only use the custom string when the corresponding bool is enabled,
# similar to how coreboot handles the SeaBIOS git revision option.
ifeq ($(BR2_PACKAGE_NWIPE_VERSION_STABLE),y)
NWIPE_VERSION = 051e1aa
else ifeq ($(BR2_PACKAGE_NWIPE_VERSION_MASTER),y)
NWIPE_VERSION = master
else ifeq ($(BR2_PACKAGE_NWIPE_VERSION_GIT_REVISION),y)
NWIPE_VERSION = $(call qstrip,$(BR2_PACKAGE_NWIPE_GIT_REVISION))
else
# Fallback – should not happen because the choice enforces exactly one option
NWIPE_VERSION = 051e1aa
endif

# Default Git repository URL. This ensures NWIPE_SITE is never empty,
# even if BR2_PACKAGE_NWIPE_SITE is not set in the configuration.
NWIPE_SITE = https://github.com/martijnvanbrummelen/nwipe.git

# If the Kconfig variable is non-empty, override the default.
ifneq ($(call qstrip,$(BR2_PACKAGE_NWIPE_SITE)),)
NWIPE_SITE = $(call qstrip,$(BR2_PACKAGE_NWIPE_SITE))
endif

NWIPE_SITE_METHOD = git

# Runtime and build-time dependencies for nwipe.
NWIPE_DEPENDENCIES = ncurses parted dmidecode coreutils libconfig

# Post-patch hook:
#  - copy the banner patch script into the source tree
#  - run the script
#  - run autogen.sh with the proper host PATH before configure/make.
define NWIPE_INITSH
	(cd $(@D) && \
		cp ../../../package/nwipe/002-nwipe-banner-patch.sh . && \
		./002-nwipe-banner-patch.sh && \
		PATH="../../host/bin:${PATH}" ./autogen.sh)
endef

NWIPE_POST_PATCH_HOOKS += NWIPE_INITSH

# Use the generic autotools infrastructure provided by Buildroot.
$(eval $(autotools-package))

