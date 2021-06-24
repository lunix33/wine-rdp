#!/bin/bash

set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

echo "==== Install common utilities ===="
apt update
apt install -y \
  software-properties-common \
  build-essential \
  git
add-apt-repository "deb http://deb.debian.org/debian buster-backports main"
apt update
apt install -y checkinstall

mkdir /build
