# linuxulator-steam-utils-anydistro

An experimental standalone version of [linuxulator-steam-utils](https://github.com/shkhln/linuxulator-steam-utils) (LSU), intended to run Linux Steam on FreeBSD with a separately managed Linux root instead of the FreeBSD linux-rl9 packages. This repository is also a local FreeBSD port. It does not bundle Steam or a Linux root, and custom distributions including Void have not been tested end to end.

## Requirements

FreeBSD amd64 with 32-bit and 64-bit Linux compatibility enabled, and a glibc-based Linux root at /compat/linux. The root needs bash, 32-bit and 64-bit libraries, graphics and audio support, and a 32-bit loader. LSU detects 32-bit libraries in usr/lib32 or usr/lib and expects 64-bit libraries in usr/lib64. Other Linux root locations are not fully supported.

Building also requires a Linux compiler at /compat/linux/bin/cc with development headers and working -m32 and -m64 support. On Void, gcc-multilib, glibc-devel-32bit and libgcc-devel-32bit provide the required toolchain components. The port does not install Linux dependencies.

Mount the Linux pseudo-filesystems, ensure the Linux root's dev/shm is writable and /etc/machine-id exists, and set these sysctls to 1:

- compat.linux.use_real_ifnames
- security.bsd.unprivileged_chroot
- vfs.usermount

Load nullfs as well. Unprivileged chroot and mounts relax host security, so use a dedicated non-wheel user for Steam. AMD graphics also require compatible Mesa drivers and Vulkan ICDs.

## Installation

With a FreeBSD ports tree configured and the Linux root provisioned, build and install from this checkout:

```sh
make build
sudo make install
```

The port installs native dependencies, including Ruby, GNU tar and Zenity, and places LSU in /usr/local/steam-utils. As the dedicated Steam user, run:

```sh
/usr/local/steam-utils/bin/lsu-bootstrap
steam
```

Steam downloads and updates its own files. The browser uses an unprivileged chroot and Steam runtime libraries. The included game compatibility tools may require additional Steam runtimes, Proton or FreeBSD Wine.

Steam's browser sandbox is disabled and pressure-vessel does not work. Game and controller support, streaming, VR and anti-cheat are not guaranteed.
