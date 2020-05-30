#!/usr/bin/env bash

set -eu

flutter --version
echo

FLUTTER_VERSION=`flutter --version | head -n 1 | awk '{ print $2 }'`
URL="https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

curl --head $URL

echo "ENV FLUTTER_URL \"$URL\""
gsed -i -e "s%ENV FLUTTER_URL.*$%ENV FLUTTER_URL \"$URL\"%" Dockerfile
