#!/bin/bash

set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

CWD=$(pwd)
PULSE_VERS=12.2-4+deb10u1
PULSE_DIR=${CWD}/pulseaudio-12.2

SINK_TAG=v0.5

echo "==== Installing dependancies ===="
add-apt-repository -s http://deb.debian.org/debian
apt update
apt install -y \
  libpulse-dev=${PULSE_VERS} \
  pulseaudio=${PULSE_VERS}
apt build-dep -y pulseaudio=${PULSE_VERS}

echo "==== Getting sources ===="
apt source -y pulseaudio=${PULSE_VERS}
git clone --depth 1 --branch ${SINK_TAG} https://github.com/neutrinolabs/pulseaudio-module-xrdp.git

echo "==== Building Pulseaudio ===="
cd ${PULSE_DIR}
./configure

echo "==== Building sink module ===="
cd ${CWD}/pulseaudio-module-xrdp
./bootstrap
./configure PULSE_DIR=${PULSE_DIR}
make

echo "==== Create artifact ===="
mkdir -p /build/pulse
mv src/.libs/*.so /build/pulse
