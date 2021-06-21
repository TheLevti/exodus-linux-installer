#!/usr/bin/env bash
#
# Copyright 2019 Petr Levtonov <petr@levtonov.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Global variables
#
INSTALLER_VERSION=1.0.0
PROCESSOR="x64"
EXODUS_BIN=exodus
EXODUS_LOCATION=/usr/local/

if [ $EUID -ne 0 ]; then
    SUDO=sudo
fi

# Generate a base file name, with eden infix, processor and version.
#
exodus_filename() {
    echo 'exodus-linux-'${PROCESSOR}'-'$1'.zip'
}

# Generate the download URL
# This can change, so we have to make sure this is "up to date"
#
exodus_download_url() {
    echo 'https://downloads.exodus.com/releases/'$1
}

# Generate the download URL for the svg icon.
#
exodus_svg_download_url()
{
    echo 'https://raw.githubusercontent.com/TheLevti/exodus-linux-installer/master/exodus.svg'
}

# Generate content for the desktop file.
#
exodus_desktop_contents()
{
    cat << EOF
[Desktop Entry]
Type=Application
Version=${1}
Name=Exodus
GenericName=Wallet
NoDisplay=false
Comment=Control Your Wealth. Secure, Manage, and Exchange your blockchain assets in one wallet.
Icon=${EXODUS_LOCATION}share/icons/hicolor/scalable/apps/${EXODUS_BIN}.svg
Hidden=false
Exec=${EXODUS_BIN}
Terminal=false
Categories=Finance;Network
Keywords=Crypto;Cryptocurrency;Currency;Wallet;Bitcoin;Ethereum;XRP;Exodus

EOF
}

# Generate the download target on disk
#
exodus_download_target() {
    mkdir -p $HOME/Downloads
    echo $HOME'/Downloads/'$1
}

# Download the Exodus payload from the server, but only
# download if we don't have it on disk already (-c option)
#
exodus_download() {
    wget -v -c -O $2 $1
}

# Download and check the exodus package to verify SHA hash
#
exodus_verify_hashes() {
    gpg --list-public-keys --with-colons --fixed-list-mode --with-fingerprint \
        | grep -q '^fpr:::::::::4CE260E8D65DF43CE88D25F212DC27133D25FAFA:$'
    FINGERPRINT1=$?
    gpg --list-public-keys --with-colons --fixed-list-mode --with-fingerprint \
        | grep -q '^fpr:::::::::4CE260E8D65DF43CE88D25F212DC27133D25FAFA:$'
    FINGERPRINT2=$?

    # If public keys do not exist, import them first.
    if  [ $FINGERPRINT1 -ne 0 ] || [ $FINGERPRINT2 -ne 0 ]
    then
        curl https://keybase.io/exodusmovement/pgp_keys.asc | gpg --import
        if ! [ $? -eq 0 ]; then
            return 1
        fi

        curl https://keybase.io/jprichardson/pgp_keys.asc | gpg --import
        if ! [ $? -eq 0 ]; then
            return 1
        fi
    fi

    local HASHES=`exodus_download_url hashes-exodus-$1.txt`
    curl -s $HASHES | gpg --verify
    if ! [ $? -eq 0 ]; then
        return 1
    fi
    filename=`exodus_filename $1`
    from_hash=`curl -s $HASHES | grep $filename | perl -lane 'print $F[0]'`
    to_hash=`sha256sum $2 | perl -lane 'print $F[0]'`
    test "$from_hash" == "$to_hash"
    return $?
}

# Install the exodus package to the /opt folder
#
exodus_install() {
    if [ "$SUDO" != "" ]; then
        echo "Running commands with SUDO..."
    fi

    # extract files & create link
    $SUDO unzip -d /opt/ $1
    $SUDO mv /opt/Exodus-linux-${PROCESSOR} /opt/exodus
    $SUDO ln -s -f /opt/exodus/Exodus ${EXODUS_LOCATION}bin/${EXODUS_BIN}

    # Create desktop file and install icon.
    local EXODUS_VERSION=`${EXODUS_BIN} --version`
    local EXODUS_DESKTOP=`exodus_desktop_contents ${EXODUS_VERSION}`

    $SUDO mkdir -p ${EXODUS_LOCATION}share/applications
    $SUDO printf "%s" "${EXODUS_DESKTOP}" | \
        $SUDO tee ${EXODUS_LOCATION}share/applications/${EXODUS_BIN}.desktop > \
        /dev/null

    # Add icon
    $SUDO mkdir -p ${EXODUS_LOCATION}share/icons/hicolor/scalable/apps
    $SUDO wget -v -c -O \
        ${EXODUS_LOCATION}share/icons/hicolor/scalable/apps/${EXODUS_BIN}.svg \
        $(exodus_svg_download_url)

    # Update icon cache
    $SUDO gtk-update-icon-cache -f /usr/share/icons/hicolor > /dev/null 2>&1

    # Register application
    $SUDO update-desktop-database > /dev/null 2>&1
}

# Check to see if Exodus is installed
#
exodus_is_installed() {
    which ${EXODUS_BIN} > /dev/null 2>&1
}

# Uninstall the application completely
#
exodus_uninstall() {
    if [ "$SUDO" != "" ]; then
        echo "Running commands with SUDO..."
    fi

    # remove app files
    $SUDO rm -f ${EXODUS_LOCATION}bin/${EXODUS_BIN}
    $SUDO rm -rf /opt/exodus
    $SUDO rm -f ${EXODUS_LOCATION}share/applications/${EXODUS_BIN}.desktop
    $SUDO rm -f \
        ${EXODUS_LOCATION}share/icons/hicolor/scalable/apps/${EXODUS_BIN}.svg

    # Update icon cache
    $SUDO gtk-update-icon-cache -f /usr/share/icons/hicolor > /dev/null 2>&1

    # Drop application
    $SUDO update-desktop-database > /dev/null 2>&1
}

# Do the actual installation procedure, calling the above functions when needed.
#
# This function detects the command line arguments and verifies they are correct.
# Then each case is run according to the arguments. What this does is:
#
# 1) download the version specified from Exodus' servers (if version specified
#                                                         otherwise, use supplied filename)
# 2) check the integrity of the archive
# 3) check for root privileges (use sudo)
# 4) install the app
#
# Or, we can uninstall the app from the harddrive (root privs needed)
#
# Or, we can check to see if Exodus is installed.
#
exodus_installer() {
    if [ $# -lt 1 ]; then
        $0 --help
        return 0
    fi

    local COMMAND
    COMMAND=$1
    shift

    case $COMMAND in
        'help' | '--help' )
      cat << EOF

Exodus installer v$INSTALLER_VERSION

Usage:

  $0 --help                 Print this message
  $0 install <version|file> Install Exodus from <file> or download and install <version>
  $0 check                  Check that Exodus is installed and print installed version
  $0 uninstall              Remove Exodus

Example:

  $0 install ~/Downloads/exodus-linux-x64-19.4.26.zip Install Exodus 19.4.26 from file
  $0 install 19.4.26                                  Download and install Exodus 19.4.26

EOF
        ;;
        'install' | 'i' )
            if [ $# -ne 1 ]; then
                >&2 $0 --help
                return 127
            fi

            if exodus_is_installed; then
                >&2 echo 'Exodus already installed.'
                return 1
            fi

            local EXODUS_PKG
            if [[ $# -eq 1 && -f $1 ]]; then
                EXODUS_PKG=$1
            else
                local EXODUS_FILENAME=`exodus_filename $1`
                EXODUS_PKG=`exodus_download_target ${EXODUS_FILENAME}`
                local EXODUS_URL=`exodus_download_url ${EXODUS_FILENAME}`
                exodus_download $EXODUS_URL $EXODUS_PKG
                if [ $? -ne 0 ]; then
                    return 1
                fi
            fi

            if ! exodus_verify_hashes $1 $EXODUS_PKG; then
                echo "$EXODUS_PKG has failed the hashing checksum! Aborting installation!"
                return 1
            fi

            if ! unzip -t $EXODUS_PKG > /dev/null; then
                echo "$EXODUS_PKG failed the SHA check, and is a corrupt file! Please remove and redownload!"
                return 1
            fi

            exodus_install $EXODUS_PKG
            return $?
        ;;
        'check' )
            if [ $# -ne 0 ]; then
                >&2 $0 --help
                return 127
            fi

            exodus_is_installed
            if [ $? -eq 1 ]; then
                echo 'Exodus is not installed.'
            else
                echo 'Exodus is installed. Version: '`${EXODUS_BIN} --version`
            fi
        ;;
        'uninstall' )
            if [ $# -ne 0 ]; then
                >&2 $0 --help
                return 127
            fi

            exodus_uninstall
            return $?
        ;;
        * )
            >&2 $0 --help
            return 127
        ;;
    esac
}

# pass arguments to main function
#
exodus_installer $@
