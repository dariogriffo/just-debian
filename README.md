![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/just-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/just-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/just-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/just-debian?display_date=published_at)

<h1>
   <p align="center">
     <a href="https://just.systems/"><img src="https://github.com/casey/just/raw/master/logo.png" alt="just Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/just-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>just for Debian
   </p>
</h1>
<p align="center">
 A handy way to save and run project-specific commands.
</p>

# just for Debian

This repository contains build scripts to produce the _unofficial_ Debian packages
(.deb) for [just](https://github.com/casey/just/) hosted at [deb.griffo.io](https://deb.griffo.io)

<p align="center">
⭐⭐⭐ Love using just on Debian? Show your support by starring this repo or [subscribing](https://buy.stripe.com/aFa28q8hr0lRdlm4a2enS01) — from 1 October 2026, apt access requires a yearly subscription. ⭐⭐⭐
</p>

Currently supported Debian distros are:
- Bookworm (v12)
- Trixie (v13)
- Forky (v14)
- Sid (testing)

Supported architectures:
- amd64 (x86_64) - All distributions
- arm64 (aarch64) - All distributions
- armel (ARM EABI) - All distributions
- armhf (ARM hard float) - All distributions
- riscv64 (RISC-V 64-bit) - Trixie, Forky, Sid only
- loong64 (LoongArch 64-bit) - Trixie, Forky, Sid only

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the just source code, see
[just](https://github.com/casey/just/).

Each package installs:
- `/usr/bin/just`
- shell completions for bash, fish and zsh
- the `just.1` man page
- upstream and Debian changelogs, and the copyright file

## Install/Update

📖 **Step-by-step install guide:** [Debian](https://deb.griffo.io/install-latest-just-in-debian.html) · [Ubuntu](https://deb.griffo.io/install-latest-just-in-ubuntu.html)

### The Debian way

> ⚠️ **From 1 October 2026, apt access requires a yearly subscription**
> ([deb.griffo.io](https://deb.griffo.io)). To use this tool for free, download
> the .deb from the [Releases](https://github.com/dariogriffo/just-debian/releases) page
> and install it manually (see below).

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb.griffo.io.gpg
echo "deb [signed-by=/etc/apt/keyrings/deb.griffo.io.gpg] https://deb.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/deb.griffo.io.list
sudo apt update
sudo apt install -y just
```

### Manual Installation

1. Download the .deb package for your Debian version available on
   the [Releases](https://github.com/dariogriffo/just-debian/releases) page.
2. Install the downloaded .deb package.

```sh
sudo dpkg -i <filename>.deb
```

## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <just_version> <build_version> <architecture>
# Example: ./build.sh 1.56.0 1 arm64
```

### Build for all architectures
```sh
./build.sh <just_version> <build_version> all
# Example: ./build.sh 1.56.0 1 all
```

## Disclaimer

- This repo is not open for issues related to just. This repo is only for _unofficial_ Debian packaging.
