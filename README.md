# linuxulator-steam-utils-standalone

This is an **experimental standalone version of [linuxulator-steam-utils (LSU)](https://github.com/shkhln/linuxulator-steam-utils)**. LSU provides workarounds for running the Linux Steam client on FreeBSD through Linuxulator. This fork is intended for a separately managed Linux root instead of the FreeBSD `linux-rl9-*` packages.

Standalone means that the repository is also a local FreeBSD port and does not depend on those packages. It does not bundle Steam, a Linux root, or the Linux libraries and compiler needed to build and run it. Compatibility with custom roots is experimental and has not been established for Void Linux.

## Requirements

- FreeBSD amd64 with 32-bit and 64-bit Linux compatibility enabled.
- A glibc-based Linux root at `/compat/linux`. Some paths are hard-coded, so other locations are not fully supported. It needs bash, 32-bit and 64-bit libraries, graphics and audio support, and a 32-bit loader. The runtime currently expects an RH-style multilib layout: 64-bit libraries in `usr/lib64` and 32-bit libraries in `usr/lib`. Void's usual `usr/lib` for 64-bit libraries does not meet this requirement without a compatible layout.
- A Linux compiler at `/compat/linux/bin/cc`, with headers and working `-m32` and `-m64` support. The port does not provision the root.
- Linux pseudo-filesystems mounted under the Linux root, writable `dev/shm`, `/etc/machine-id`, and `compat.linux.use_real_ifnames=1`.
- `nullfs` loaded, `security.bsd.unprivileged_chroot=1`, and `vfs.usermount=1`. These settings relax host security. Use a dedicated unprivileged, non-wheel account for Steam.

For AMD graphics, the Linux root also needs compatible Mesa drivers and Vulkan ICDs for the required architectures. A render device alone does not establish working graphics support.

## Build and install

This checkout is the port source. It builds from the local files rather than fetching a release archive. With a FreeBSD ports tree configured and the Linux root provisioned, run:

```sh
make install
```

Installation requires appropriate privileges. The port installs to `/usr/local/steam-utils` and provides `/usr/local/bin/steam`. Its native dependencies include Ruby, GNU tar, and Zenity. Manage Linux dependencies separately in the Linux root.

To build outside the port framework, run `make -f Makefile.build build`, then install with `make -f Makefile.build install`.

As the dedicated Steam user, run `/usr/local/steam-utils/bin/lsu-bootstrap`, then `steam`. Steam downloads and updates its own files. The browser uses an unprivileged chroot and Steam runtime libraries. Optional game compatibility tools are also installed and may require additional Steam runtimes, Proton, or FreeBSD Wine.

## Limitations

Steam's browser sandbox is disabled. Steam's pressure-vessel container runtime does not work. Game and controller support, streaming, VR, and anti-cheat are not guaranteed. Graphics and audio support depend on the Linux root and host configuration.
