################################################################################
#
# nwipe
#
################################################################################

ifeq ($(BR2_PACKAGE_NWIPE_VERSION_GIT),y)

# Use values from menuconfig for the Git repository URL, branch, and commit
NWIPE_REPO_URL = $(call qstrip,$(BR2_PACKAGE_NWIPE_REPO_URL))
NWIPE_BRANCH = $(call qstrip,$(BR2_PACKAGE_NWIPE_BRANCH))
NWIPE_COMMIT = $(call qstrip,$(BR2_PACKAGE_NWIPE_COMMIT))
NWIPE_SITE = NO_SITE
NWIPE_DEPENDENCIES = ncurses parted dmidecode coreutils

# The path for git init
NWIPE_SUBMODULE_PATH = $(TOPDIR)/external/nwipe

define NWIPE_INITSH
	(cd $(NWIPE_SUBMODULE_PATH) && cp ../../../package/nwipe/003-nwipe-banner-patch.sh $(NWIPE_SUBMODULE_PATH) && ./003-nwipe-banner-patch.sh && PATH="../../host/bin:${PATH}" ./autogen.sh);
endef

NWIPE_POST_PATCH_HOOKS += NWIPE_INITSH

# Disables download procedure
define DOWNLOAD_NWIPE
	true
endef

# Git clone with specified branch, commit, and repository URL
define NWIPE_CLONE_CMDS
	if [ ! -d $(NWIPE_SUBMODULE_PATH) ]; then \
		git submodule update --init --recursive; \
		git clone --branch $(NWIPE_BRANCH) $(NWIPE_REPO_URL) $(NWIPE_SUBMODULE_PATH); \
	fi; \
	(cd $(NWIPE_SUBMODULE_PATH) && git fetch && git checkout $(NWIPE_COMMIT));
endef

NWIPE_PRE_CONFIGURE_HOOKS += NWIPE_CLONE_CMDS

# Copies the source out of the source path
define NWIPE_EXTRACT_CMDS
	rsync -a $(NWIPE_SUBMODULE_PATH)/ $(@D)/
endef

else # BR2_PACKAGE_NWIPE_VERSION_RELEASE is selected

# Use release version
NWIPE_VERSION = v0.37
NWIPE_SITE = $(call github,martijnvanbrummelen,nwipe,$(NWIPE_VERSION))
NWIPE_DEPENDENCIES = ncurses parted dmidecode coreutils

define NWIPE_INITSH
	(cd $(@D) && cp ../../../package/nwipe/002-nwipe-banner-patch.sh $(@D) && ./002-nwipe-banner-patch.sh && PATH="../../host/bin:${PATH}" ./autogen.sh);
endef

NWIPE_POST_PATCH_HOOKS += NWIPE_INITSH

endif

$(eval $(autotools-package))

