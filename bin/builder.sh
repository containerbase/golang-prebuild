#!/bin/bash

set -e

# shellcheck source=/dev/null
. /usr/local/containerbase/util.sh

# trim leading v
TOOL_VERSION=${1#v}

NAME=golang
ARCH=$(uname -p)
farch=amd64

if [[ "$ARCH" = "aarch64" ]]; then
  farch=arm64
fi

if [[ "${DEBUG}" == "true" ]]; then
  set -x
fi

SEMVER_REGEX="^(0|[1-9][0-9]*)(\.(0|[1-9][0-9]*))(\.(0|[1-9][0-9]*))$"

function check_semver () {
  if [[ ! "${1}" =~ ${SEMVER_REGEX} ]]; then
    echo "Not a semver like version - aborting: ${1}" >&2
    exit 1
  fi
  export MAJOR=${BASH_REMATCH[1]}
  export MINOR=${BASH_REMATCH[3]}
  export PATCH=${BASH_REMATCH[5]}
}

check_semver "${TOOL_VERSION}"

echo "Building ${NAME} ${TOOL_VERSION} for ${ARCH}"

# fix version, only for go 1.20 and below
fversion=${TOOL_VERSION}
if [[ ($MAJOR -lt 1 || ($MAJOR -eq 1 && $MINOR -lt 21)) && "${PATCH}" == "0" ]]; then
  fversion="${MAJOR}.${MINOR}"
fi


expected_checksum=$(jq -r ".[] | select(.version == \"go${fversion}\") | .files[] | select(.os == \"linux\" and .arch == \"${farch}\") | .sha256" < /usr/local/golang/versions.json)
file=$(get_from_url \
    "https://dl.google.com/go/go${fversion}.linux-${farch}.tar.gz" \
    "golang-v${TOOL_VERSION}-linux-${farch}.tar.xz" \
    "${expected_checksum}" \
    "sha256sum" )

if [[ "$file" == "" ]]; then
  echo "Download error"
  exit 1
fi

mkdir "/usr/local/${NAME}/${TOOL_VERSION}"
tar -C "/usr/local/${NAME}/${TOOL_VERSION}" --strip 1 -xf "${file}"

echo "------------------------"
echo "Testing ${NAME} ${TOOL_VERSION} for ${ARCH}"
"/usr/local/${NAME}/${TOOL_VERSION}/bin/go" version
"/usr/local/${NAME}/${TOOL_VERSION}/bin/go" env

echo "------------------------"
echo "Compressing ${NAME} ${TOOL_VERSION} for ${ARCH}"
tar -cJf "/cache/${NAME}-${TOOL_VERSION}-${ARCH}.tar.xz" -C "/usr/local/${NAME}" "${TOOL_VERSION}"
