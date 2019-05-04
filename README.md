# exodus-linux-installer

A bash script for downloading/installing/uninstalling [Exodus][1] on Linux. This
repository is based on [ExodusMovement/exodus-linux-installer][2]. The main
difference is that support for the eden version of exodus has been removed and
the whole script has received samll tweaks here and there. It also creates a
`.desktop` file and downloads the app icon from this repository.

All changes have been tested on Ubuntu 18.10 only. By default this script
installs the app in the `/usr/local` path. If you need it to be in `/usr/` or
somehwere else, just update the `EXODUS_LOCATION` variable at the top of the
script.

## Install

```bash
sudo wget -O /usr/local/bin/exodus-installer https://raw.githubusercontent.com/TheLevti/exodus-linux-installer/master/exodus-installer.sh
sudo chmod +x /usr/local/bin/exodus-installer
```

## Usage

Check if exodus is already installed:

```bash
exodus-installer check
```

Install specific version:

```bash
exodus-installer install 19.4.26
```

Install from zip archive:

```bash
exodus-installer install ~/Downloads/exodus-linux-x64-19.4.26.zip
```

Uninstall currently installed version:

```bash
exodus-installer uninstall
```

# LICENSE

MIT

[1]: http://exodus.io/
[2]: https://github.com/ExodusMovement/exodus-linux-installer
