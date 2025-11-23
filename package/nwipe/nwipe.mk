################################################################################
#
# nwipe
#
################################################################################

NWIPE_VERSION = $(call qstrip,$(BR2_PACKAGE_NWIPE_GIT_REF))

NWIPE_SITE = https://github.com/martijnvanbrummelen/nwipe
NWIPE_SITE_METHOD = git

NWIPE_DEPENDENCIES = ncurses parted dmidecode coreutils libconfig

define NWIPE_INITSH
	(cd $(@D) && cp ../../../package/nwipe/002-nwipe-banner-patch.sh $(@D) \
		&& ./002-nwipe-banner-patch.sh \
		&& PATH="../../host/bin:${PATH}" ./autogen.sh);
endef

NWIPE_POST_PATCH_HOOKS += NWIPE_INITSH

$(eval $(autotools-package))

