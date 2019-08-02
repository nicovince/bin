#!/bin/bash
OUT_DIR=output
BUILD_DIR=$(find $(pwd) -maxdepth 2 -name build)

function filter_host_pkgs()
{
  find ${BUILD_DIR} -maxdepth 1 -mindepth 1 | grep -v "host-"
}


if [ -z ${BUILD_DIR} ]; then
  echo "Build dir not found"
  exit 1
fi

TARGET_PKGS=$(filter_host_pkgs)
rm -Rf ${TARGET_PKGS}
