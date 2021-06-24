#!/bin/bash

# This script starts the wine prefix on login (except for root).

if [ "${USER}" != "root" ]; then
  wineboot
fi
