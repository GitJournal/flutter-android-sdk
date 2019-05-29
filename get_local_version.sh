#!/usr/bin/env bash

set -eu

flutter --version
echo

FLUTTER_VERSION=`flutter --version | head -n 1 | awk '{ print $2 }'`
URL="https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v${FLUTTER_VERSION}-stable.tar.xz"

set -x
curl --head $URL

