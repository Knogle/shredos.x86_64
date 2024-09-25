# ShredOS Yocto Build Instructions

## Introduction

**ShredOS** is a small, bootable GNU/Linux distribution that boots straight into `nwipe`, a utility derived from `dwipe` that securely erases disks using a variety of recognized methods. This project provides a Yocto-based build environment to create a ShredOS image, allowing for customizable and reproducible builds suitable for various hardware platforms.

By using the Yocto Project, you gain the flexibility to tailor the ShredOS image to your specific needs, including adding or removing packages, customizing configurations, and supporting different hardware architectures.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setting Up the Build Environment](#setting-up-the-build-environment)
- [Building the ShredOS Image](#building-the-shredos-image)
- [Deploying and Testing the Image](#deploying-and-testing-the-image)
- [Customizing the Build](#customizing-the-build)
- [Directory Structure](#directory-structure)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Features

- **Secure Disk Erasure**: Boots directly into `nwipe` for secure disk wiping.
- **Customizable**: Easily add or remove packages and configurations using Yocto recipes.
- **Reproducible Builds**: Consistent build environment ensures the same output across different systems.
- **Support for x86_64 Architecture**: Targets generic x86_64 hardware.

## Prerequisites

### Host System Requirements

- **Operating System**: A Linux distribution is recommended (e.g., Ubuntu, Debian, Fedora).
- **Storage**: At least 100 GB of free disk space.
- **Memory**: Minimum 8 GB RAM; 16 GB or more recommended for faster builds.
- **Internet Connection**: Required to fetch source code and dependencies.

### Required Host Packages

Ensure the following packages are installed on your build host:

- `git`
- `gcc`
- `g++`
- `make`
- `build-essential`
- `chrpath`
- `diffstat`
- `texinfo`
- `python3`
- `python3-pip`
- `python3-pexpect`
- `xz-utils`
- `debianutils`
- `iputils-ping`
- `libsdl1.2-dev` (for QEMU)
- `xterm`
- `curl`
- `wget`
- `unzip`

**Note**: Package names may vary depending on your Linux distribution.

### Additional Dependencies

- **Git Large File Storage (LFS)**: If your project uses LFS.

## Setting Up the Build Environment

### 1. Clone the Poky Repository

Poky is the reference distribution of the Yocto Project.

```bash
git clone git://git.yoctoproject.org/poky.git
cd poky
git checkout kirkstone  # Use the desired Yocto release branch
```

**Note**: Replace `kirkstone` with the desired branch (e.g., `dunfell`, `hardknott`, or `master`).

### 2. Clone the meta-openembedded Layer

```bash
cd ..
git clone git://git.openembedded.org/meta-openembedded.git
cd meta-openembedded
git checkout kirkstone  # Ensure the branch matches Poky
cd ..
```

### 3. Clone the meta-shredos Layer

```bash
git clone <your-repo-url> meta-shredos
```

Replace `<your-repo-url>` with the URL of your `meta-shredos` repository.

### 4. Set Up the Build Environment

Initialize the build environment using the `oe-init-build-env` script provided by Poky:

```bash
source poky/oe-init-build-env
```

This will create and switch you into the `build/` directory.

### 5. Configure Build Options

#### Copy Sample Configuration Files

Copy the sample configuration files from the `meta-shredos` layer:

```bash
cp ../meta-shredos/conf/local.conf.sample conf/local.conf
cp ../meta-shredos/conf/bblayers.conf.sample conf/bblayers.conf
```

#### Update `bblayers.conf`

Ensure that `bblayers.conf` includes the correct paths to your layers:

```conf
BBLAYERS ?= " \
  ${TOPDIR}/../poky/meta \
  ${TOPDIR}/../poky/meta-poky \
  ${TOPDIR}/../poky/meta-yocto-bsp \
  ${TOPDIR}/../meta-openembedded/meta-oe \
  ${TOPDIR}/../meta-openembedded/meta-python \
  ${TOPDIR}/../meta-openembedded/meta-networking \
  ${TOPDIR}/../meta-shredos \
"
```

#### Update `local.conf`

You can customize `local.conf` as needed. Key settings include:

- **MACHINE**: Ensure it is set to `genericx86-64`.
- **DISTRO**: You can leave it as `poky` or customize as needed.
- **IMAGE_FSTYPES**: Specify the desired image format (e.g., `iso`, `hddimg`).

Example snippet from `local.conf`:

```conf
MACHINE ?= "genericx86-64"
DISTRO ?= "poky"
PACKAGE_CLASSES ?= "package_deb"
EXTRA_IMAGE_FEATURES ?= "debug-tweaks"
```

## Building the ShredOS Image

Run the following command to build the ShredOS image:

```bash
bitbake shredos-image
```

**Notes:**

- The first build may take several hours as it downloads and compiles all required packages.
- Subsequent builds will be faster due to caching.

## Deploying and Testing the Image

### Locate the Generated Image

After the build completes, the image will be located in:

```
build/tmp/deploy/images/genericx86-64/shredos-image-genericx86-64.hddimg
```

or

```
build/tmp/deploy/images/genericx86-64/shredos-image-genericx86-64.iso
```

### Testing with QEMU

You can test the image using QEMU:

```bash
runqemu core-image-minimal
```

**Note:** Adjust the command to specify the correct image if needed.

### Writing the Image to a USB Drive

To deploy ShredOS on physical hardware:

1. Insert a USB drive (all data on it will be erased).
2. Identify the device node (e.g., `/dev/sdX`).

   **Warning:** Be very careful to choose the correct device.

3. Use `dd` to write the image:

   ```bash
   sudo dd if=build/tmp/deploy/images/genericx86-64/shredos-image-genericx86-64.hddimg of=/dev/sdX bs=4M && sync
   ```

4. Boot the target machine from the USB drive.

## Customizing the Build

### Adding or Removing Packages

Edit the `shredos-image.bb` recipe located in `meta-shredos/recipes-core/images/` to add or remove packages.

Example:

```bitbake
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
```

### Modifying Recipes

You can modify existing recipes or add new ones in the `meta-shredos` layer.

### Changing Kernel Configuration

If you need to customize the kernel:

1. Add a kernel recipe or append in `meta-shredos/recipes-kernel/linux/`.
2. Use configuration fragments to modify kernel settings.

## Directory Structure

```
shredos-yocto/
├── meta-shredos/
│   ├── conf/
│   │   ├── layer.conf
│   │   ├── local.conf.sample
│   │   └── bblayers.conf.sample
│   ├── recipes-core/
│   │   └── images/
│   │       └── shredos-image.bb
│   ├── recipes-extended/
│   │   └── nwipe/
│   │       └── nwipe_git.bb
│   ├── recipes-support/
│   │   └── libconfig/
│   │       └── libconfig_%.bbappend
│   └── README.md
├── poky/
│   ├── meta/
│   ├── meta-poky/
│   ├── meta-yocto-bsp/
│   └── ...
├── meta-openembedded/
│   ├── meta-oe/
│   ├── meta-python/
│   ├── meta-networking/
│   └── ...
└── build/
    ├── conf/
    ├── tmp/
    └── ...
```

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

- **ShredOS** is distributed under its respective licenses.
- **nwipe** is licensed under the GNU General Public License v3.0.

## Acknowledgments

- **Yocto Project**: For providing a powerful and flexible build system.
- **ShredOS and nwipe Developers**: For creating tools for secure disk wiping.
- **OpenEmbedded Community**: For maintaining meta layers and recipes.

## Support and Contributions

If you encounter issues or have suggestions for improvements:

- **Issues**: Submit an issue on the project's GitHub repository.
- **Contributions**: Pull requests are welcome. Please ensure code adheres to existing style conventions.

## Additional Resources

- **Yocto Project Documentation**: [https://www.yoctoproject.org/docs/](https://www.yoctoproject.org/docs/)
- **OpenEmbedded Layers Index**: [http://layers.openembedded.org/](http://layers.openembedded.org/)
- **ShredOS Project**: [https://github.com/PartialVolume/shredos.x86_64](https://github.com/PartialVolume/shredos.x86_64)
- **nwipe Utility**: [https://github.com/PartialVolume/nwipe](https://github.com/PartialVolume/nwipe)

---

*This README was generated to provide instructions on building and customizing the ShredOS image using the Yocto Project. For any discrepancies or updates, please refer to the latest documentation in the repository.*
