# exodus-linux-installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)][3]

A bash script for downloading/installing/uninstalling [Exodus Wallet][1] on
Linux. This repository is based on [ExodusMovement/exodus-linux-installer][2].
The main difference is that support for the eden version of exodus has been
removed and the whole script has received samll tweaks here and there. It also
creates a `.desktop` file and downloads the app icon from this repository.

All changes have been tested on Ubuntu 18.10 only. By default this script
installs the app in the `/usr/local` path. If you need it to be in `/usr/` or
somehwere else, just update the `EXODUS_LOCATION` variable at the top of the
script.

----

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

## License

[The MIT License][3]

Copyright 2019 Petr Levtonov <petr@levtonov.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[1]: https://exodus.io/
[2]: https://github.com/ExodusMovement/exodus-linux-installer
[3]: https://raw.githubusercontent.com/TheLevti/exodus-linux-installer/master/LICENSE
