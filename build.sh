#!/bin/bash

# https://github.com/danielguerra69/ubuntu-xrdp
# https://serverfault.com/questions/960648/use-makefile-to-copy-files-in-docker-multi-stage-builds
# docker run -it -p 3389:3389 --shm-size 2g debian:buster /bin/bash

set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

cd /tmp/

# Apply system updates
echo "==== Installing upgrades ===="
apt update && apt upgrade -y
echo "==== Installing basic packages ===="
apt install -y gnupg wget software-properties-common

# Add repos
echo "==== Adding repositories ===="
apt-add-repository contrib
apt-add-repository non-free

dpkg --add-architecture i386

wget -O- https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/opensuse-repo.gpg
apt-add-repository 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./'

wget -O- https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/winehq-repo.gpg
apt-add-repository "deb http://dl.winehq.org/wine-builds/debian/ buster main"

# Update and install required packages.
echo "===== Installing running packages ===="
apt update
apt install -y --install-recommends \
  supervisor \
  openbox \
  winehq-stable=6.0.1~buster-1 \
  pulseaudio \
  pavucontrol \
  htop \
  vim \
  xrdp \
  xorgxrdp

# Install wine-mono
cd /opt/wine-stable/share/wine
echo "==== Installing Wine mono ===="
mkdir mono

wget -P ./mono https://dl.winehq.org/wine/wine-mono/5.1.1/wine-mono-5.1.1-x86.msi

# Install wine-gecko
echo "==== Installing Wine gecko ===="
mkdir gecko
wget -P ./gecko http://dl.winehq.org/wine/wine-gecko/2.47.2/wine-gecko-2.47.2-x86.msi
wget -P ./gecko http://dl.winehq.org/wine/wine-gecko/2.47.2/wine-gecko-2.47.2-x86_64.msi

# Configure XRDP
echo "==== Setting up XRDP ===="
xrdpcfg='/etc/xrdp/xrdp.ini'
sed -i 's/^#EnableConsole=(false|true)$/EnableConsole=true/' ${xrdpcfg}
sed -i 's/^#ConsoleLevel=.+$/ConsoleLevel=WARN/' ${xrdpcfg}

xvnc_line=$(grep -Fn '[Xvnc]' ${xrdpcfg} | cut -f 1 -d ':')
sed -i "${xvnc_line},$((${xvnc_line} + 6))s/^/#/" ${xrdpcfg}
vnc_line=$(grep -Fn '[vnc-any]' ${xrdpcfg} | cut -f 1 -d ':')
sed -i "${vnc_line},$((${vnc_line} + 6))s/^/#/" ${xrdpcfg}
neutrino_line=$(grep -Fn '[neutrinordp-any]' ${xrdpcfg} | cut -f 1 -d ':')
sed -i "${neutrino_line},$((${neutrino_line} + 6))s/^/#/" ${xrdpcfg}

# Add supervisor config
## Base config
echo "==== Setting up supervisord ===="
sed -i 's#\[supervisord\]#\[supervisord\]\nnodaemon=true\nuser=root#' /etc/supervisor/supervisord.conf
